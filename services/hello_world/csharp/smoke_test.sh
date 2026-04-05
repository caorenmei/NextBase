#!/usr/bin/env bash
set -euo pipefail

project_file="$1"
if [[ ! -f "$project_file" && "$project_file" != /* ]] && [[ -n "${TEST_SRCDIR:-}" ]] && [[ -n "${TEST_WORKSPACE:-}" ]]; then
  project_file="$TEST_SRCDIR/$TEST_WORKSPACE/$project_file"
fi
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
export HOME="$work_dir/home"
export DOTNET_CLI_HOME="$HOME"
mkdir -p "$HOME"

dotnet build \
  "$project_file" \
  --nologo \
  --output "$work_dir/out" \
  -p:BaseIntermediateOutputPath="$work_dir/obj/"

output="$(dotnet "$work_dir/out/hello.dll")"

if ! grep -q "hello from c#" <<<"$output"; then
  echo "unexpected output: $output" >&2
  exit 1
fi
