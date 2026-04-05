# GitHub CI 规范

## 适用范围
本文档对应以下实际文件：
- `.github/workflows/ci.yml`
- `.devcontainer/Dockerfile`
- `.bazelrc`
- `tools/scripts/verify.ps1`

## 当前 CI 目标
GitHub Actions 只做一件事：在与 Dev Container 尽量一致的容器环境中完成全量构建、测试和 hello_world 烟测。

当前触发条件：
- `pull_request`
- `push` 到 `main`

## 当前执行路径
CI 的 `container-verify` job 采用如下顺序：
1. 检出代码
2. 初始化 Docker Buildx
3. 恢复 Bazel 与 Bazelisk 缓存目录
4. 使用 `.devcontainer/Dockerfile` 构建 `nextbase-dev:ci` 镜像
5. 在容器内执行：
   - `bazel build //...`
   - `bazel test //...`

## 网络与代理规则
- GitHub Actions 默认不使用代理
- 工作流不再依赖仓库变量中的 `HTTP_PROXY`、`HTTPS_PROXY`、`NO_PROXY`、`APT_MIRROR`
- 如果未来确实要为 CI 单独引入镜像源或代理，必须给出明确的网络约束理由，并同步更新本文档、README 和本地验证脚本

## 缓存策略
### Docker 层缓存
- 使用 Buildx 和 `docker/build-push-action`
- 通过 GitHub Actions Cache Backend 持久化 Docker 构建层
- 目的：减少 Dev Container 镜像重复构建时的 APT 与 Bazelisk 下载成本

### Bazel 运行时缓存
- 通过 `actions/cache` 持久化 runner 上的缓存目录
- 再把这些目录 bind mount 到容器内的 `/home/vscode` 缓存路径
- 当前缓存目录与 `devcontainer.json` 保持一致：
  - `/home/vscode/.cache/bazel`
  - `/home/vscode/.cache/bazelisk`
  - `/home/vscode/go/pkg/mod`
  - `/home/vscode/.cache/go-build`
  - `/home/vscode/.cargo/registry`
  - `/home/vscode/.cargo/git`
  - `/home/vscode/.nuget/packages`
  - `/home/vscode/.npm`

## 变更规则
- 修改 `.github/workflows/ci.yml` 时，优先保持“容器内验证”这一主路径，不要拆成与 Dev Container 完全不同的另一套安装脚本
- 修改 `.bazelrc` 缓存路径时，必须同步调整 CI 的挂载目录
- 修改 `.devcontainer/Dockerfile` 时，要同时确认 BuildKit 缓存仍然可用
- 增加新的服务或语言示例时，需要决定是否纳入烟测列表；如果纳入，README 和本文档都要同步更新

## 与本地验证的关系
- 本地优先使用 `tools/scripts/verify.ps1`
- CI 与本地都走容器化验证，但本地脚本保留可选代理和镜像源参数，CI 不保留