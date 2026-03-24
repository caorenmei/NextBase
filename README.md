# Monorepo: Container Dev + Bazel + Code Agent

## 设计目标
- 可复现：固定 Bazel 版本与 Bzlmod 锁文件，默认严格锁定依赖解析
- 快速启动：Dev Container 使用命名卷持久化 Bazel/Go/Rust/NuGet/NPM 缓存，减少重建后的重复下载
- 编辑器友好：默认隐藏 Bazel 软链接与构建产物目录，降低索引噪声
- 团队友好：共享最小 VS Code 配置，避免个人本地配置污染仓库
- 安全：默认仅提交源码与资源文件，构建产物和本地临时文件不入库

## 快速开始
1. 使用 Dev Container 打开仓库
2. 执行：
   - bazel run //services/hello_world/go/hello:hello
   - bazel run //services/hello_world/rust/hello:hello
   - bazel run //services/hello_world/cpp/hello:hello
   - bazel run //services/hello_world/csharp/hello:hello
   - bazel run //services/hello_world/typescript/hello:hello
   - bazel test //...

首次冷启动会下载依赖；后续重建容器时将复用命名卷缓存，速度显著提升。

## 验证方式（容器优先）
- 不依赖本机 Go/Rust/C++/Node.js/.NET/Bazel 安装
- 使用脚本在 Dev Container 镜像中执行：
   - powershell -ExecutionPolicy Bypass -File tools/scripts/verify.ps1
- 中国大陆网络建议：
   - 默认使用清华 Ubuntu 镜像
   - 默认尝试代理 http://host.docker.internal:1080
   - 可显式指定：
     - powershell -ExecutionPolicy Bypass -File tools/scripts/verify.ps1 -ProxyUrl "http://host.docker.internal:1080" -AptMirror "mirrors.tuna.tsinghua.edu.cn"

## Dev Container 环境变量
在使用 Dev Container 启动项目时，可以通过以下环境变量配置代理和 APT 源（可在宿主或 VS Code 启动前导出）：

- **DEV_CONTAINER_HTTP_PROXY**: http://host.docker.internal:1080
- **DEV_CONTAINER_HTTPS_PROXY**: http://host.docker.internal:1080
- **DEV_CONTAINER_NO_PROXY**: localhost,127.0.0.1,host.docker.internal
- **DEV_CONTAINER_APT_MIRROR**: mirrors.tuna.tsinghua.edu.cn

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

## Code Agent Skills
- Skills 放置于 `.skills/`，用于把仓库实践拆成按需加载的领域能力，而不是把所有规则都堆进全局说明。
- `development-environment`：处理 Dev Container、一致性、缓存加速、代理镜像与容器安全。
- `dependency-build`：处理 `BUILD.bazel`、`MODULE.bazel`、依赖图谱正确性、目标粒度与缓存命中率。
- `architecture-planning`：处理目录落点、跨目录依赖、服务与包边界，防止 Monorepo 演变成“大泥潭”。
- 这些 Skill 应与 `agent/agent-core.md` 配合使用：全局规则留在 core，任务域知识下沉到对应 Skill。

### 何时让 Agent 使用对应 Skill
- 涉及 `.devcontainer/`、`.bazelrc`、代理、缓存、镜像层、安全收敛时，优先使用 `development-environment`。
- 涉及 `BUILD.bazel`、`MODULE.bazel`、锁文件、构建性能与测试命令时，优先使用 `dependency-build`。
- 涉及新目录、新服务、新共享库、边界调整或跨目录依赖治理时，优先使用 `architecture-planning`。

### Skill 使用原则
- 先读 Skill，再形成最小变更方案。
- Skill 只提供任务域流程与检查清单，不替代实际验证。
- 涉及结构调整时，同时更新 BUILD、模块路径、CI/部署与文档。
