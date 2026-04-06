# Monorepo: Container Dev + Bazel + Code Agent

## 设计目标
- 可复现：固定 Bazel 版本与 Bzlmod 锁文件，默认严格锁定依赖解析
- 快速启动：Dev Container 使用命名卷持久化 Bazel/Go/Rust/NuGet/NPM 缓存，减少重建后的重复下载
- CI 一致：GitHub Actions 复用 Dev Container 构建路径，在无代理前提下使用缓存加速
- 编辑器友好：默认隐藏 Bazel 软链接与构建产物目录，降低索引噪声
- 团队友好：共享最小 VS Code 配置，避免个人本地配置污染仓库
- 安全：默认仅提交源码与资源文件，构建产物和本地临时文件不入库

## 快速开始
1. 使用 Dev Container 打开仓库
2. 执行：
   - bazel build //...
   - bazel test //...
   - bazel run //services/hello_world/csharp:hello
   - bazel run //services/hello_world/typescript:hello

首次冷启动会下载依赖；后续重建容器时将复用命名卷缓存，速度显著提升。

## 验证方式（容器优先）
- 不依赖本机 Go/Rust/C++/Node.js/.NET/Bazel 安装
- 使用 Bazel 原生命令作为首选：
   - bazel build //...
   - bazel test //...
- GitHub CI 默认不使用代理，直接基于公开网络拉取依赖并依赖缓存加速
- 中国大陆网络建议：
   - 代理为可选项，建议优先使用宿主环境变量 `HOST_HTTP_PROXY` 与 `HOST_HTTPS_PROXY`
   - 执行 Bazel 前可显式映射：
     - export HTTP_PROXY="$HOST_HTTP_PROXY" HTTPS_PROXY="$HOST_HTTPS_PROXY" http_proxy="$HOST_HTTP_PROXY" https_proxy="$HOST_HTTPS_PROXY"

## Dev Container 环境变量
在使用 Dev Container 启动项目时，可以通过以下环境变量配置代理和 APT 源（可在宿主或 VS Code 启动前导出）：

- **DEV_CONTAINER_USE_PROXY**: 设为任意非空值时才生成 `.devcontainer/proxy.env`
- **DEV_CONTAINER_HTTP_PROXY**: http://host.docker.internal:1080
- **DEV_CONTAINER_HTTPS_PROXY**: http://host.docker.internal:1080
- **DEV_CONTAINER_NO_PROXY**: localhost,127.0.0.1,host.docker.internal
- **DEV_CONTAINER_APT_MIRROR**: mirrors.tuna.tsinghua.edu.cn

在容器外直接执行 Bazel 命令时，也支持：
- **HOST_HTTP_PROXY**
- **HOST_HTTPS_PROXY**

## 缓存与重建加速
- Bazel 仓库缓存：`$HOME/.cache/bazel/repository`
- Bazel 磁盘缓存：`$HOME/.cache/bazel/disk`
- Bazel 输出根目录：`$HOME/.cache/bazel/output_user_root`
- Go/Rust/NuGet/NPM 缓存：通过 Dev Container `mounts` 持久化到命名卷
- Dev Container 镜像构建：已启用 BuildKit 缓存挂载（APT/NPM 与常见下载脚本/二进制），可显著减少重复下载

### 团队约定：BuildKit 加速构建
- 默认通过 Dev Containers 重建，使用 Docker BuildKit（Docker Desktop / 新版 Docker Engine 通常默认开启）
- 手动构建时建议显式开启：`DOCKER_BUILDKIT=1 docker build -f .devcontainer/Dockerfile .`
- 如需查看详细构建过程可加：`--progress=plain`
- 当下载内容异常或怀疑缓存污染时，可先执行 `docker builder prune`（会清理 BuildKit 构建缓存）再重建

如果需要清理缓存并做一次完全冷启动，可在宿主机执行：
- `docker volume rm nextbase-bazel-cache nextbase-bazelisk-cache nextbase-go-mod-cache nextbase-go-build-cache nextbase-cargo-registry-cache nextbase-cargo-git-cache nextbase-nuget-cache nextbase-npm-cache`

示例（Windows PowerShell）:
```powershell
setx DEV_CONTAINER_HTTP_PROXY "http://host.docker.internal:1080"
setx DEV_CONTAINER_HTTPS_PROXY "http://host.docker.internal:1080"
setx DEV_CONTAINER_NO_PROXY "localhost,127.0.0.1,host.docker.internal"
setx DEV_CONTAINER_APT_MIRROR "mirrors.tuna.tsinghua.edu.cn"
```

重启 VS Code（确保 Dev Containers 扩展读取到新的宿主环境变量），然后使用 `Dev Containers: Reopen in Container` 来重建/启动容器。

## 目录
- services: 按 Domain（业务域）组织的可部署服务/应用（示例：hello_world / billing / user）
- hello_world 目前包含 go、rust、cpp、csharp、typescript 五个示例服务
- hello_world 语言目录实践：
   - cpp: `src/` 与 `tests/` 分离
   - csharp: 源码位于 `src/`，`bin/`/`obj/` 仅为本地产物
   - typescript: 入口位于 `src/`
   - go: 入口位于 `cmd/hello/`
   - rust: 入口位于 `src/`
- packages: 可复用包
- tools: 工具与脚本
- bazel: Bazel 公共宏与规则封装
- agent: Code Agent 统一规则

## 规则与文档映射
- `agent/agent-core.md`：Agent 工作流、最小改动原则、Monorepo 基础约束。
- `docs/devcontainer.md`：`.devcontainer/`、容器启动、代理开关、缓存卷、编辑器排噪。
- `docs/toolchains.md`：`.bazelversion`、`MODULE.bazel`、`.bazelrc`、多语言工具链与 Bazel 命令。
- `docs/monorepo.md`：目录落点、服务示例布局、依赖边界、命名与提交流程。
- `docs/ci.md`：`.github/workflows/ci.yml` 的执行路径、缓存策略与变更约束。

## 文档同步约定
- 修改 `.devcontainer/`、`.bazelrc`、`.bazelversion`、`MODULE.bazel`、`.github/workflows/ci.yml`、`.editorconfig`、`.gitignore` 时，必须同步更新对应文档。
- README 只保留总览和入口；具体规则以 `agent/agent-core.md` 与 `docs/` 下对应文档为准。
- 文档描述必须以仓库当前实现为准，不保留未落地的“规划态规则”。
