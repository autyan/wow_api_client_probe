#!/usr/bin/env bash
set -euo pipefail

OLD="${1:?usage: scripts/diff-snapshots.sh <old.snapshot> <new.snapshot>}"
NEW="${2:?usage: scripts/diff-snapshots.sh <old.snapshot> <new.snapshot>}"

diff -u "$OLD" "$NEW"
