FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USE_PROXY
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG APT_MIRROR

ENV PATH="/usr/local/bin:${PATH}"

# 配置APT源和代理
RUN set -eux; \
    if [ -n "${USE_PROXY:-}" ] && [ -n "${APT_MIRROR:-}" ]; then \
        SOURCES_FILE="/etc/apt/sources.list"; \
        [ -f /etc/apt/sources.list.d/ubuntu.sources ] && SOURCES_FILE="/etc/apt/sources.list.d/ubuntu.sources"; \
        sed -i "s|http://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" ${SOURCES_FILE}; \
        sed -i "s|http://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" ${SOURCES_FILE}; \
        sed -i "s|https://archive.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" ${SOURCES_FILE}; \
        sed -i "s|https://security.ubuntu.com/ubuntu/|https://${APT_MIRROR}/ubuntu/|g" ${SOURCES_FILE}; \
        printf \
            'Acquire::http::Proxy::%s DIRECT;\n' \
            'Acquire::https::Proxy::%s DIRECT;\n' \
            "${APT_MIRROR}" "${APT_MIRROR}" > /etc/apt/apt.conf.d/99no-proxy; \
    fi

# 安装系统依赖和基础工具
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.npm,sharing=locked \
    --mount=type=cache,target=/tmp/buildkit-downloads,sharing=locked \
    set -eux; \
    # 安装APT包（仅保留 Bazel 运行必需的最小依赖，所有开发工具链由 Bazel 管理）
    retries=5; \
    for i in $(seq 1 $retries); do \
        apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 update && break; \
        echo "apt-get update failed, retry $i/$retries"; \
        sleep 5; \
    done; \
    apt-get install -y --no-install-recommends \
        curl git gh unzip zip build-essential pkg-config libssl-dev ca-certificates; \
    \
    # 安装 Bazelisk（Bazel 版本管理器）
    BAZELISK_BIN=/tmp/buildkit-downloads/bazelisk-linux-amd64; \
    if [ ! -s "${BAZELISK_BIN}" ]; then \
        curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64 -o "${BAZELISK_BIN}"; \
    fi; \
    cp "${BAZELISK_BIN}" /usr/local/bin/bazel; \
    chmod +x /usr/local/bin/bazel; \
    \
    # 清理APT缓存
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# 创建缓存目录并设置权限
RUN set -eux; \
    install -d -o vscode -g vscode \
        /home/vscode/.cache \
        /home/vscode/.cache/bazel \
        /home/vscode/.cache/bazelisk \
        /home/vscode/.cache/bazelisk/downloads \
        /home/vscode/.npm; \
    chown -R vscode:vscode /home/vscode/.cache /home/vscode/.npm
