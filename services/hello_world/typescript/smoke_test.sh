#!/usr/bin/env bash
set -euo pipefail

node_bin="$1"
entry_file="$2"
output="$("$node_bin" "$entry_file")"

if [[ "$output" != "hello from typescript" ]]; then
  echo "unexpected output: $output" >&2
  exit 1
fi
