#!/usr/bin/env bash
set -euxo pipefail


target="${1:-dry-activate}"
cmd='nixos-rebuild --flake '.?submodules=1' --use-remote-sudo'

deploy() {
	$cmd --target-host "$1" "$target"
}

hosts=(
	taiyi.nevi.network
	athebyne.nevi.network
	funi.nevi.network
	giausar.proxy.nevi.network
	alrakis.proxy.nevi.network
)

for host in "${hosts[@]}"; do
	deploy "$host" &
done

wait
