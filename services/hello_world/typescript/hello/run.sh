#!/usr/bin/env bash
set -euo pipefail

entry_file="$1"
config_file="$2"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

cp "$entry_file" "$work_dir/main.ts"
cp "$config_file" "$work_dir/tsconfig.json"
cd "$work_dir"
tsc --project tsconfig.json --outDir "$work_dir/dist"
node "$work_dir/dist/main.js"
