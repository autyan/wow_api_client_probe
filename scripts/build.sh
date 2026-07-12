#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/dist/apiRefersher"

rm -rf "$OUT"
mkdir -p "$OUT"
cp "$ROOT/src/apiRefersher/apiRefersher.toc" "$OUT/apiRefersher.toc"
cp "$ROOT/src/apiRefersher/Contracts.lua" "$OUT/Contracts.lua"
cp "$ROOT/src/apiRefersher/apiRefersher.lua" "$OUT/apiRefersher.lua"

echo "built $OUT"
