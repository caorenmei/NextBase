FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG APT_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG GO_DOWNLOAD_URL=https://go.dev/dl/go1.23.6.linux-amd64.tar.gz
ARG RUSTUP_DIST_SERVER=https://rsproxy.cn
ARG RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup

ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}
ENV RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}
ENV RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}

RUN set -eux; \
    sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list; \
    sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" /etc/apt/sources.list

RUN set -eux; \
        retries=5; \
        for i in $(seq 1 $retries); do \
            apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 update && break; \
            echo "apt-get update failed, retry $i/$retries"; \
            sleep 5; \
        done; \
        apt-get install -y --no-install-recommends curl git unzip zip build-essential pkg-config libssl-dev ca-certificates; \
        rm -rf /var/lib/apt/lists/*

RUN curl -fsSL ${GO_DOWNLOAD_URL} -o /tmp/go.tgz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm -f /tmp/go.tgz
ENV PATH="/usr/local/go/bin:${PATH}"

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64 -o /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel
