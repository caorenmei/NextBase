#!/usr/bin/env bash
set -euo pipefail

out_file=".devcontainer/proxy.env"
mkdir -p "$(dirname "$out_file")"
: > "$out_file"

if [[ -n "${DEV_CONTAINER_USE_PROXY:-}" ]]; then
  {
    [[ -n "${DEV_CONTAINER_HTTP_PROXY:-}" ]] && printf 'HTTP_PROXY=%s\n' "$DEV_CONTAINER_HTTP_PROXY"
    [[ -n "${DEV_CONTAINER_HTTPS_PROXY:-}" ]] && printf 'HTTPS_PROXY=%s\n' "$DEV_CONTAINER_HTTPS_PROXY"
    [[ -n "${DEV_CONTAINER_NO_PROXY:-}" ]] && printf 'NO_PROXY=%s\n' "$DEV_CONTAINER_NO_PROXY"
    [[ -n "${DEV_CONTAINER_APT_MIRROR:-}" ]] && printf 'APT_MIRROR=%s\n' "$DEV_CONTAINER_APT_MIRROR"
  } >> "$out_file"
fi
