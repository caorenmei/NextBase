# Dev Container 开发环境

## 适用范围
本文档对应以下实际文件：
- `.devcontainer/devcontainer.json`
- `.devcontainer/Dockerfile`
- `.devcontainer/devcontainer.schema.json`
- `.devcontainer/scripts/generate-proxy-env.sh`
- `.vscode/settings.json`
- `.bazelrc`

## 当前实现
### 容器基础镜像与工具
- 基础镜像：`mcr.microsoft.com/devcontainers/base:ubuntu`
- 容器内预装的基础工具仅包含 Bazel 运行和仓库维护所需最小集合：`bazel`（由 Bazelisk 提供）、`gh`、`curl`、`git`、`unzip`、`zip`、`build-essential`、`pkg-config`、`libssl-dev`、`ca-certificates`
- Go、Rust、.NET、Node.js、TypeScript、Clang 等语言工具链不在镜像中预装，统一由 Bazel 按 `MODULE.bazel` 下载和管理

### 代理策略
- Dev Container 默认不启用代理
- 只有在宿主环境设置了 `DEV_CONTAINER_USE_PROXY` 且其值非空时，`.devcontainer/scripts/generate-proxy-env.sh` 才会生成 `.devcontainer/proxy.env`
- `devcontainer.json` 通过 `--env-file .devcontainer/proxy.env` 注入可选代理变量
- `APT_MIRROR` 也是可选项，仅在传入时改写 Ubuntu 源
- GitHub Actions 不依赖这些代理变量，CI 路径默认走无代理模式

### 缓存与目录约定
`devcontainer.json` 通过命名卷挂载以下缓存目录：
- `/home/vscode/.cache/bazel`
- `/home/vscode/.cache/bazelisk`
- `/home/vscode/go/pkg/mod`
- `/home/vscode/.cache/go-build`
- `/home/vscode/.cargo/registry`
- `/home/vscode/.cargo/git`
- `/home/vscode/.nuget/packages`
- `/home/vscode/.npm`

`.bazelrc` 进一步固定了 Bazel 使用的关键路径：
- `--repository_cache=~/.cache/bazel/repository`
- `--disk_cache=~/.cache/bazel/disk`
- `--output_user_root=~/.cache/bazel/output_user_root`

说明：`devcontainer.json` 的 `mounts.target` 仍使用容器内绝对路径（如 `/home/vscode/.cache/bazel`），这是 Docker 挂载语义要求（目标必须是容器内绝对路径），不能改为相对路径。

### 编辑器排噪
`devcontainer.json` 与 `.vscode/settings.json` 共同约束了 VS Code 的排噪行为：
- 隐藏 `.bazel/`、`bazel-*` 软链接目录
- 隐藏 `bin/`、`obj/`、`dist/` 等常见构建产物目录
- 降低 Bazel 产物对索引、搜索和文件监听的干扰

### 启动后校验
`postCreateCommand` 当前只执行最小自检：
- `g++ --version | head -n 1`
- `bazel --version`
- `gh --version`

## 变更规则
- 修改 `.devcontainer/Dockerfile` 时，优先保持“最小预装工具”原则，不要把语言工具链重新装回镜像
- 修改缓存挂载时，要同时检查 `.bazelrc`、GitHub Actions 缓存挂载和 README 是否需要同步
- 修改代理逻辑时，要同时检查 `generate-proxy-env.sh`、`devcontainer.json`、`.bazelrc` 和 README
- 变更 VS Code 排噪规则时，要同步核对 `devcontainer.json` 与 `.vscode/settings.json`

## 常用验证
```bash
bazel --version
bazel build //...
bazel test //...
```

访问受限外网时，可使用宿主代理变量映射后再执行 Bazel：

```bash
export HTTP_PROXY="$HOST_HTTP_PROXY" HTTPS_PROXY="$HOST_HTTPS_PROXY"
export http_proxy="$HOST_HTTP_PROXY" https_proxy="$HOST_HTTPS_PROXY"
bazel build //...
bazel test //...
```