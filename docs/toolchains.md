# 工具链管理方案

## 核心原则
1. **版本统一**：所有开发者使用完全相同的工具链版本，避免"本地能跑"问题
2. **自动管理**：工具链由 Bazel 自动下载、配置和缓存，无需手动安装
3. **环境无关**：工具链版本与宿主环境和容器环境无关，完全由项目配置控制
4. **多语言支持**：统一管理所有语言的工具链，包括未来新增的语言
5. **最小依赖**：容器仅保留 Bazel 运行必需的最小依赖，所有开发工具都由 Bazel 管理

## 支持的语言与版本
所有工具链版本在 `MODULE.bazel` 中统一配置：

| 语言       | 版本          | 规则集                  | 状态       |
|------------|---------------|-------------------------|------------|
| Go         | 1.23.6        | `rules_go`              | ✅ 已配置  |
| Rust       | 1.83.0        | `rules_rust`            | ✅ 已配置  |
| C#/.NET    | 8.0.100       | `rules_dotnet`          | ✅ 已配置  |
| TypeScript | -             | `rules_ts` + `rules_nodejs` | ✅ 已配置 |
| Node.js    | 18.19.0       | `rules_nodejs`          | ✅ 已配置  |
| C/C++      | Clang 17.0.6  | `rules_cc` + `llvm_toolchain` | ✅ 已配置 |

## 使用方法
### 无需手动安装任何工具
所有开发工具（go、rustc、dotnet、node、tsc 等）都不需要在本地或容器中手动安装，Bazel 会在首次构建时自动下载对应版本的工具链。

### 构建命令示例（符合 Monorepo 目录约束）
```bash
# 构建所有服务
bazel build //services/...

# 构建指定业务域下的所有服务
bazel build //services/user/...

# 构建单个服务
bazel build //services/user/auth:auth_service

# 构建所有公共库
bazel build //packages/...

# 构建指定公共库
bazel build //packages/common/utils:utils_lib

# 构建 TypeScript 前端应用（按业务域划分）
bazel build //services/admin/frontend:admin_app

# 构建 C/C++ 项目
bazel build //tools/performance:profiler_bin

# 运行单个服务的测试
bazel test //services/user/auth:auth_test

# 运行所有测试
bazel test //...
```

### 查看工具链版本
```bash
# 查看 Go 版本
bazel run @go_sdk//:go version

# 查看 Rust 版本
bazel run @rust_toolchains//:rustc -- --version

# 查看 .NET 版本
bazel run @dotnet_toolchains//:dotnet -- --version

# 查看 Node.js 版本
bazel run @nodejs_toolchains//:node -- --version
```

## 版本更新流程
如需更新工具链版本，只需修改 `MODULE.bazel` 中的对应版本号即可：
```python
# 例如更新 Go 版本到 1.24.0
go_sdk.download(version = "1.24.0")
```
提交变更后，所有开发者下次执行 Bazel 命令时会自动下载新版本。

## 缓存策略
- 工具链下载后会自动缓存在 Bazel 的本地缓存目录中，默认路径：`~/.cache/bazelisk/downloads/`
- 容器环境中通过卷挂载持久化缓存，避免重复下载
- 多项目可以共享同一版本的工具链缓存

## 新增语言支持
如需新增其他语言的工具链支持，只需：
1. 在 `MODULE.bazel` 中添加对应语言的 rules 依赖
2. 配置对应语言的工具链版本
3. 在本文档中更新支持的语言列表

## 优势
- ✅ 一致性：所有开发者、CI 环境使用完全相同的工具链版本
- ✅ 无需配置：开箱即用，不需要开发者手动安装任何开发工具
- ✅ 版本隔离：不同项目可以使用不同版本的工具链，互不影响
- ✅ 易于升级：统一修改配置即可完成全团队的工具链版本升级
- ✅ 安全：工具链从官方源下载，校验和验证，避免供应链风险