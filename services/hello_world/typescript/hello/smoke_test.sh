#!/usr/bin/env bash
set -euo pipefail

entry_file="$1"
config_file="$2"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

mkdir -p "$work_dir/src"
cp "$entry_file" "$work_dir/src/main.ts"
cp "$config_file" "$work_dir/tsconfig.json"
cd "$work_dir"
tsc --project tsconfig.json --outDir "$work_dir/dist"
output="$(node "$work_dir/dist/main.js")"

if [[ "$output" != "hello from typescript" ]]; then
  echo "unexpected output: $output" >&2
  exit 1
fi
