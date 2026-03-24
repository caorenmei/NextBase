# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG APT_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG GO_DOWNLOAD_URL=https://go.dev/dl/go1.23.6.linux-amd64.tar.gz
ARG RUSTUP_DIST_SERVER=https://static.rust-lang.org
ARG RUSTUP_UPDATE_ROOT=https://static.rust-lang.org/rustup
ARG RUST_VERSION=1.83.0

ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
ENV RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}
ENV RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="/usr/local/cargo/bin:/usr/local/go/bin:${PATH}"

RUN set -eux; \
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
        sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
        sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list.d/ubuntu.sources; \
    else \
        sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
        sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
    fi

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    set -eux; \
        retries=5; \
        for i in $(seq 1 $retries); do \
            apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 update && break; \
            echo "apt-get update failed, retry $i/$retries"; \
            sleep 5; \
        done; \
        apt-get install -y --no-install-recommends curl git unzip zip build-essential pkg-config libssl-dev ca-certificates nodejs npm; \
        npm install -g typescript; \
        rm -rf /var/lib/apt/lists/*

RUN curl -fsSL ${GO_DOWNLOAD_URL} -o /tmp/go.tgz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm -f /tmp/go.tgz

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain ${RUST_VERSION} --no-modify-path \
    && chmod -R a+rX /usr/local/rustup /usr/local/cargo

RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet \
    && ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet \
    && rm -f /tmp/dotnet-install.sh
ENV DOTNET_ROOT="/usr/share/dotnet"

RUN curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64 -o /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel
