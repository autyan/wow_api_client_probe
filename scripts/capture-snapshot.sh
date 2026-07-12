#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAVED_VARIABLES="${1:?usage: scripts/capture-snapshot.sh <apiRefersher.lua> [flavor]}"
FLAVOR="${2:-tbc-anniversary-cn}"
KEY="$(lua "$ROOT/scripts/export-snapshot.lua" "$SAVED_VARIABLES" --key)"
SAFE_KEY="$(printf '%s' "$KEY" | tr -cs 'A-Za-z0-9._-' '_')"
OUT_DIR="$ROOT/snapshots/$FLAVOR"
OUT="$OUT_DIR/$SAFE_KEY.snapshot"

mkdir -p "$OUT_DIR"
lua "$ROOT/scripts/export-snapshot.lua" "$SAVED_VARIABLES" > "$OUT"
echo "$OUT"
