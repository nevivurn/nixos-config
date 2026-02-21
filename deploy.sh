#!/usr/bin/env bash
set -euxo pipefail


target="${1:-dry-activate}"
cmd='nixos-rebuild --flake '.?submodules=1' --sudo'

deploy() {
	$cmd --target-host "$1" "$target"
}

hosts=(
	taiyi.nevi.network
	athebyne.inf.nevi.network
	giausar.prx.nevi.network
	alrakis.prx.nevi.network
)

for host in "${hosts[@]}"; do
	deploy "$host" &
done

wait
