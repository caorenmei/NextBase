# Monorepo 规范

## 适用范围
本文档描述当前仓库已经落地的结构规则，不描述尚未实现的模板化约束。

## 当前目录结构
当前顶层目录和职责如下：

```text
.
├── agent/        # Agent 统一规则入口
├── bazel/        # Bazel 公共宏与规则封装
├── docs/         # 仓库规则与操作文档
├── packages/     # 预留给可复用包，当前语言示例尚未落入此目录
├── services/     # 可部署服务示例
└── tools/        # 验证脚本与工程工具
```

根目录同时保留以下关键文件：
- `.bazelrc`、`.bazelversion`、`MODULE.bazel`、`MODULE.bazel.lock`：构建系统配置
- `.editorconfig`、`.gitignore`、`.vscode/settings.json`：仓库级编辑和忽略规则
- `AGENTS.md`、`CLAUDE.md`、`copilot-instructions.md`：Agent 入口与补充说明
- `.github/workflows/ci.yml`：GitHub CI 执行规则

## services 目录规则
### 当前实际布局
当前仅落地一个业务域 `hello_world`，其下按语言拆分示例服务：
- `services/hello_world/go`
- `services/hello_world/rust`
- `services/hello_world/cpp`
- `services/hello_world/csharp`
- `services/hello_world/typescript`

### 各语言目录约定
- Go：入口位于 `cmd/hello/main.go`，测试位于 `cmd/hello/main_test.go`
- Rust：入口位于 `src/main.rs`，测试位于 `src/main_test.rs`
- C++：源码位于 `src/main.cc`，测试位于 `tests/main_test.cc`
- C#：源码位于 `src/Program.cs`，`bin/` 和 `obj/` 视为本地产物，不入库
- TypeScript：源码位于 `src/main.ts`，通过 `tsconfig.json` 和 Bazel `genrule` 产出 `main.js`

### BUILD 文件规则
- 每个语言示例目录使用 `BUILD.bazel`
- 当前可执行目标统一命名为 `hello`
- 当前测试目标统一命名为 `hello_test`
- Bazel 标签必须使用仓库相对标签，例如 `//services/hello_world/go:hello`

## packages 与 tools
- `packages/` 当前保留为空目录，用于后续沉淀跨域复用库；新增内容前需要先确认确实存在复用场景
- `tools/scripts/verify.ps1` 是当前仓库的容器化验证入口
- `bazel/` 用于存放后续需要抽取的公共规则；当前 hello_world 示例直接使用官方 rules

## 依赖规则
这些规则来自 `agent/agent-core.md`，也是当前仓库必须遵守的基础约束：
- 优先显式直接依赖，避免过宽聚合依赖
- 跨目录依赖需说明原因
- 新增依赖优先通过仓库统一构建系统管理
- 服务跨域依赖通过公共包或 API 暴露，避免反向依赖

当前仓库还没有复杂跨目录代码依赖，因此文档不额外引入未落地的依赖分层模型。

## 提交与忽略规则
- 构建产物、IDE 本地文件、临时文件必须通过 `.gitignore` 排除，不提交到版本库
- `.gitignore` 当前重点忽略：`.bazel/`、`bazel-*`、`bin/`、`obj/`、`dist/`、`.nuget/`、`.npm/`、`.pnpm-store/`、`.devcontainer/proxy.env`
- `.vscode/settings.json` 默认隐藏 Bazel 产物目录和常见构建输出目录
- `.editorconfig` 统一使用 `utf-8` 和 `lf`；Go 文件使用 tab，其余代码文件使用去尾空格规则

## 变更规则
- 新增顶层目录前，优先评估能否落在现有 `services/`、`packages/`、`tools/`、`docs/`、`bazel/`、`agent/` 下
- 调整服务布局时，需要同步更新 `BUILD.bazel`、README、相关文档和 CI 命令
- 如果把共享逻辑从 `services/` 抽出到 `packages/`，必须同时补齐依赖标签和验证命令

## 常用验证
```bash
bazel build //...
bazel test //...
bazel run //services/hello_world/go:hello
bazel run //services/hello_world/rust:hello
bazel run //services/hello_world/cpp:hello
bazel run //services/hello_world/csharp:hello
bazel run //services/hello_world/typescript:hello
```