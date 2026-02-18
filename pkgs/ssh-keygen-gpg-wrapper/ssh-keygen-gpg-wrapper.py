#!/usr/bin/env python3

"""
ssh-sign-wrapper - Transparent ssh-keygen wrapper enabling SSH certificate
signing with gpg-agent.

gpg-agent cannot handle certificate key blobs in SSH_AGENTC_SIGN_REQUEST
(GnuPG T1756, T5041). This wrapper intercepts 'ssh-keygen -Y sign'
invocations where the signing key is a certificate and:

  1. Extracts the plain public key from the certificate
  2. Signs via the agent using the plain key
  3. Patches the SSHSIG output to embed the full certificate

The signature remains valid because the publickey field in the SSHSIG
format is not part of the signed data.

For all other invocations, this wrapper execs the real ssh-keygen unchanged.

Configuration:
  git config gpg.ssh.program /path/to/ssh-sign-wrapper
  SSH_KEYGEN=/usr/bin/ssh-keygen  # optional: override ssh-keygen path

This script was vibecoded
"""

import base64
import os
import struct
import subprocess
import sys
import tempfile
import textwrap

SSH_KEYGEN = os.environ.get("SSH_KEYGEN", "ssh-keygen")

_CERT_SUFFIX = "-cert-v01@openssh.com"

# Number of public key fields after the nonce in each certificate type.
_KEY_FIELDS = {
    "ssh-ed25519": 1,                         # pk
    "ssh-rsa": 2,                             # e, n
    "ssh-dss": 4,                             # p, q, g, y
    "ecdsa-sha2-nistp256": 2,                 # identifier, Q
    "ecdsa-sha2-nistp384": 2,
    "ecdsa-sha2-nistp521": 2,
    "sk-ssh-ed25519@openssh.com": 2,          # pk, application
    "sk-ecdsa-sha2-nistp256@openssh.com": 3,  # identifier, Q, application
}


def _passthrough():
    """Replace this process with the real ssh-keygen, preserving all args."""
    os.execvp(SSH_KEYGEN, [SSH_KEYGEN] + sys.argv[1:])


def _read_ssh_string(data, offset):
    """Read an SSH wire-format string (uint32 length || bytes)."""
    if offset + 4 > len(data):
        raise ValueError(f"truncated data at offset {offset}")
    (length,) = struct.unpack(">I", data[offset : offset + 4])
    end = offset + 4 + length
    if end > len(data):
        raise ValueError(f"string at offset {offset} exceeds data")
    return data[offset + 4 : end], end


def _write_ssh_string(data):
    """Encode bytes as an SSH wire-format string."""
    return struct.pack(">I", len(data)) + data


def _cert_to_plain_type(cert_type):
    """Derive the plain key type name from a certificate type name.

    Handles both standard types (ssh-ed25519-cert-v01@openssh.com ->
    ssh-ed25519) and OpenSSH extension types
    (sk-ssh-ed25519-cert-v01@openssh.com -> sk-ssh-ed25519@openssh.com).
    """
    base = cert_type[: -len(_CERT_SUFFIX)]
    if base in _KEY_FIELDS:
        return base
    openssh_name = base + "@openssh.com"
    if openssh_name in _KEY_FIELDS:
        return openssh_name
    raise ValueError(f"unsupported certificate type: {cert_type}")


def _extract_plain_key(cert_blob):
    """Extract (plain_type, plain_key_blob) from a certificate blob."""
    offset = 0
    cert_type_bytes, offset = _read_ssh_string(cert_blob, offset)
    plain_type = _cert_to_plain_type(cert_type_bytes.decode("ascii"))
    n_fields = _KEY_FIELDS[plain_type]

    _, offset = _read_ssh_string(cert_blob, offset)  # skip nonce

    fields_start = offset
    for _ in range(n_fields):
        _, offset = _read_ssh_string(cert_blob, offset)

    plain_blob = _write_ssh_string(plain_type.encode("ascii"))
    plain_blob += cert_blob[fields_start:offset]
    return plain_type, plain_blob


def _patch_sshsig(sig_path, cert_blob):
    """Replace the publickey in an SSHSIG file with a certificate blob."""
    with open(sig_path) as f:
        lines = f.read().strip().splitlines()

    sig_data = base64.b64decode("".join(lines[1:-1]))

    # SSHSIG: magic(6) || version(4) || publickey(string) || rest
    offset = 6 + 4  # skip "SSHSIG" + version
    version_bytes = sig_data[6:10]
    _, offset = _read_ssh_string(sig_data, offset)  # skip old publickey

    new_data = b"SSHSIG" + version_bytes
    new_data += _write_ssh_string(cert_blob)
    new_data += sig_data[offset:]

    b64 = base64.b64encode(new_data).decode()
    with open(sig_path, "w") as f:
        f.write("-----BEGIN SSH SIGNATURE-----\n")
        f.write("\n".join(textwrap.wrap(b64, 70)))
        f.write("\n-----END SSH SIGNATURE-----\n")


def main():
    args = sys.argv[1:]

    # Only intercept "-Y sign" with a certificate key; everything else
    # passes through to the real ssh-keygen untouched.
    if "-Y" not in args:
        _passthrough()
    y_idx = args.index("-Y")
    if y_idx + 1 >= len(args) or args[y_idx + 1] != "sign":
        _passthrough()

    if "-f" not in args:
        _passthrough()
    f_idx = args.index("-f")
    if f_idx + 1 >= len(args):
        _passthrough()
    keyfile = args[f_idx + 1]

    try:
        with open(keyfile) as f:
            key_type = f.readline().split()[0]
        if not key_type.endswith(_CERT_SUFFIX):
            _passthrough()
    except (OSError, IndexError):
        _passthrough()

    # --- certificate signing path ---
    namespace = None
    extra_opts = []
    buffer_file = None

    i = 0
    while i < len(args):
        a = args[i]
        if a in ("-Y", "-f", "-n", "-O") and i + 1 < len(args):
            if a == "-n":
                namespace = args[i + 1]
            elif a == "-O":
                extra_opts += ["-O", args[i + 1]]
            i += 2
        elif a == "-U":
            i += 1
        else:
            buffer_file = a
            i += 1

    if not namespace or not buffer_file:
        _passthrough()

    cert_blob = base64.b64decode(open(keyfile).read().split()[1])
    plain_type, plain_blob = _extract_plain_key(cert_blob)

    with tempfile.TemporaryDirectory() as tmpdir:
        plain_pub = os.path.join(tmpdir, "plain.pub")
        with open(plain_pub, "w") as f:
            f.write(f"{plain_type} {base64.b64encode(plain_blob).decode()}\n")

        cmd = [
            SSH_KEYGEN, "-Y", "sign",
            "-n", namespace,
            "-f", plain_pub, "-U",
            *extra_opts,
            buffer_file,
        ]
        r = subprocess.run(cmd)
        if r.returncode != 0:
            sys.exit(r.returncode)

    _patch_sshsig(buffer_file + ".sig", cert_blob)


if __name__ == "__main__":
    main()
