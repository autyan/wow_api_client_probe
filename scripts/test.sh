#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

luac -p \
  "$ROOT/src/apiRefersher/Contracts.lua" \
  "$ROOT/src/apiRefersher/apiRefersher.lua" \
  "$ROOT/scripts/export-snapshot.lua"

lua "$ROOT/scripts/export-snapshot.lua" "$ROOT/tests/fixtures/apiRefersher.lua" > "$TMP"
grep -F $'META\tbuild\t68575' "$TMP" >/dev/null
grep -F $'FUNCTION\tC_Container.GetContainerNumSlots\t(containerIndex:BagIndex)->(numSlots:number)|runtime=function' "$TMP" >/dev/null
grep -F $'CONTRACT\taura-border-color\tPASS|AuraUtil.SetAuraBorderColor=function|An aura debuff-color implementation is available.' "$TMP" >/dev/null

lua "$ROOT/tests/addon_test.lua" "$ROOT"

"$ROOT/scripts/build.sh"
test -f "$ROOT/dist/apiRefersher/apiRefersher.toc"
echo "tests passed"
