FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USE_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG APT_MIRROR
ARG GO_DOWNLOAD_URL=https://go.dev/dl/go1.23.6.linux-amd64.tar.gz
ARG RUSTUP_DIST_SERVER=https://static.rust-lang.org
ARG RUSTUP_UPDATE_ROOT=https://static.rust-lang.org/rustup
ARG RUST_VERSION=1.83.0

ENV RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}
ENV RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="/usr/local/cargo/bin:/usr/local/go/bin:${PATH}"

RUN set -eux; \
    if [ -n "${USE_PROXY}" ] && [ -n "${APT_MIRROR}" ]; then \
        if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
            sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
            sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
            sed -i "s|https://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
            sed -i "s|https://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
        else \
            sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
            sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
            sed -i "s|https://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
            sed -i "s|https://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
        fi; \
        printf \
            'Acquire::http::Proxy::${APT_MIRROR} DIRECT;\n' \
            'Acquire::https::Proxy::${APT_MIRROR} DIRECT;\n' \
            > /etc/apt/apt.conf.d/99no-proxy; \
    fi

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.npm,sharing=locked \
    set -eux; \
        apt-config dump | grep -i Proxy && env | grep -i PROXY || true; \
        retries=5; \
        for i in $(seq 1 $retries); do \
            apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 update && break; \
            echo "apt-get update failed, retry $i/$retries"; \
            sleep 5; \
        done; \
        apt-get install -y --no-install-recommends curl git unzip zip build-essential pkg-config libssl-dev ca-certificates nodejs npm; \
        npm install -g typescript

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    set -eux; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends gh

RUN --mount=type=cache,target=/tmp/buildkit-downloads,sharing=locked \
    set -eux; \
    GO_TGZ=/tmp/buildkit-downloads/go.tgz; \
    if [ ! -s "${GO_TGZ}" ]; then \
        curl -fsSL ${GO_DOWNLOAD_URL} -o "${GO_TGZ}"; \
    fi; \
    rm -rf /usr/local/go; \
    tar -C /usr/local -xzf "${GO_TGZ}"

RUN --mount=type=cache,target=/tmp/buildkit-downloads,sharing=locked \
    set -eux; \
    RUSTUP_SCRIPT=/tmp/buildkit-downloads/sh.rustup.rs; \
    if [ ! -s "${RUSTUP_SCRIPT}" ]; then \
        curl -fsSL https://sh.rustup.rs -o "${RUSTUP_SCRIPT}"; \
    fi; \
    sh "${RUSTUP_SCRIPT}" -y --profile minimal --default-toolchain ${RUST_VERSION} --no-modify-path; \
    chmod -R a+rX /usr/local/rustup /usr/local/cargo

RUN --mount=type=cache,target=/tmp/buildkit-downloads,sharing=locked \
    set -eux; \
    DOTNET_SCRIPT=/tmp/buildkit-downloads/dotnet-install.sh; \
    if [ ! -s "${DOTNET_SCRIPT}" ]; then \
        curl -fsSL https://dot.net/v1/dotnet-install.sh -o "${DOTNET_SCRIPT}"; \
    fi; \
    bash "${DOTNET_SCRIPT}" --channel 8.0 --install-dir /usr/share/dotnet; \
    ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet
ENV DOTNET_ROOT="/usr/share/dotnet"

RUN --mount=type=cache,target=/tmp/buildkit-downloads,sharing=locked \
    set -eux; \
    BAZELISK_BIN=/tmp/buildkit-downloads/bazelisk-linux-amd64; \
    if [ ! -s "${BAZELISK_BIN}" ]; then \
        curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64 -o "${BAZELISK_BIN}"; \
    fi; \
    cp "${BAZELISK_BIN}" /usr/local/bin/bazel; \
    chmod +x /usr/local/bin/bazel
