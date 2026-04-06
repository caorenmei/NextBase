# AGENTS Instructions

## 参考文档
- 开发环境配置：[docs/devcontainer.md](docs/devcontainer.md)
- 工具链管理方案：[docs/toolchains.md](docs/toolchains.md)
- Monorepo 规范：[docs/monorepo.md](docs/monorepo.md)
- GitHub CI 规范：[docs/ci.md](docs/ci.md)

## 核心规则
### 工作流
1. 读取上下文与约束，优先遵循项目现有约定
2. 形成最小变更方案，保持最小改动
3. 先读后改、先测后交付，明确影响范围与回滚路径
4. 优先在 Dev Container 中执行验证
5. 输出包含：变更内容、验证结果、风险、后续建议
6. 先给最小可行方案，再给扩展方案
7. 明确标注假设与未验证项
8. 涉及 `.github/workflows/` 时，先核对 `docs/ci.md` 与本地验证路径的一致性
9. 访问受限外网时，优先使用宿主代理环境变量 `HOST_HTTP_PROXY` 与 `HOST_HTTPS_PROXY`，并映射为 `HTTP_PROXY`/`HTTPS_PROXY`（含小写变量）后再执行 Bazel 命令
10. 构建、运行、测试优先使用 Bazel 原生目标与规则，避免新增或依赖 `sh`/`ps1` 等非 Bazel 原生脚本作为主流程
11. 在必须使用脚本且允许替换的场景下，优先使用 Python 脚本替代 `sh`/`psl` 脚本以提升跨平台一致性

### Monorepo 约束
#### 目录结构
- `services/`: 按业务域组织可部署服务，格式：`services/<domain>/<service>/`
- `packages/`: 跨域复用库
- `tools/`: 工具与脚本
- 构建产物、IDE本地文件、临时文件需加入忽略规则，不提交到版本库

#### 依赖规则
- 优先显式直接依赖，避免过宽聚合依赖
- 跨目录依赖需说明原因
- 新增依赖优先通过仓库统一构建系统管理
- 服务跨域依赖通过公共包或API暴露，避免反向依赖