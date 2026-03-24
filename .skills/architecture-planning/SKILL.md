---
name: architecture-planning
description: Use when the task involves monorepo topology, directory placement, ownership boundaries, cross-package dependencies, or preventing architectural erosion.
---

# 架构规划

## 何时使用
- 新增或重组模块、服务、共享包或工具目录时。
- 需要定义所有者边界和依赖方向时。
- 需要防止 Monorepo 结构漂移和长期耦合时。
- 新代码落点不明确，需要做目录决策时。

## 规划原则
1. 先分类：可部署应用/服务、可复用包或工程工具。
2. 创建新结构前先定义所有者、消费者和验证路径。
3. 保持依赖方向稳定且易于推理。
4. 仅在确有多方复用时再下沉共享抽象。
5. 生成产物和本地临时输出不进入长期目录拓扑。

## 决策规则
- 优先选择符合既有约定的最小落点。
- 跨边界依赖必须给出明确理由。
- 除非既有域无法承载，否则避免新增顶层目录。
- 结构变更时同步更新构建元数据、CI 路径与文档。

## 反模式
- 以“临时”名义落地却长期无人治理。
- 共享层反向依赖具体服务实现。
- 工具目录不断堆积运行时业务逻辑。
- 仅为单一调用方提前抽象通用层。

## 输出要求
- 给出推荐与不推荐落点并说明理由。
- 说明边界与依赖方向影响。
- 区分已验证结论与规划假设。
- 若拓扑变更复杂，提供回滚策略。

## 补充说明
- 这个技能用于处理 Monorepo 拓扑、目录落点、所有权边界、跨包依赖和架构漂移。
- 新结构优先落在现有边界内，只有当前目录体系无法承载时才考虑扩展顶层目录。
- 中文说明放在正文里，帮助团队理解；`name` 和 `description` 保持英文，利于工具发现。

### 服务目录组织（`services`）

- **目标**：按 Domain（业务域）组织可部署服务/应用，保证所有权清晰、独立部署与边界明确。

- **推荐布局**：
  - `services/<domain>/<service>/...` — 每个 service 包含 `src/`, `deploy/`, `config/`, `tests/`, 以及 `README.md` 与 `OWNERS`。
  - 示例：`services/hello_world/hello/`、`services/billing/invoice/`、`services/user/auth/`。

- **命名约定**：domain 使用小写并用下划线或短横分隔（例如 `hello_world` 或 `hello-world`）；service 名称应能描述其职责。

- **所有权与文档**：每个 domain 应维护 `OWNERS` 文件并在 `README.md` 中说明边界、对外 API、主要消费者与维护流程。

- **依赖与共享规则**：
  - 跨 domain 依赖应通过 `packages/`（可复用库）或明确的服务 API 暴露，避免反向依赖。
  - domain 内的共享资源可放在 `services/<domain>/shared/`；真正跨域的共享库放在顶层 `packages/` 并说明使用者与向后兼容策略。

- **迁移指引（简要）**：
  1. 在 `services/<domain>/` 下创建目标目录并添加 `README.md` 与 `OWNERS`。
  2. 将源码、部署与配置迁入对应子目录。
  3. 更新构建元数据（BUILD/CI 目标）与依赖声明。
  4. 运行并修复单元/集成/烟雾测试。
  5. 提交 PR 并在变更说明中标明迁移影响与回滚步骤。

- **例外与边界情形**：infra、一次性脚本或工具应放在 `tools/`、`scripts/` 或 `infra/`，并在 `README` 记录为何不归入某个 domain。

- **验证与发布注意**：变更后必须更新 CI、构建目标与依赖图；确保 smoke tests 与关键集成链路通过。

以上规则并非教条：当存在明确的工程或业务理由时，可提出例外并在变更说明中说明理由与风险缓解措施。
