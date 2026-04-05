# 工具链管理方案

## 适用范围
本文档对应以下实际文件：
- `.bazelversion`
- `.bazelrc`
- `MODULE.bazel`
- `MODULE.bazel.lock`
- `services/hello_world/*/BUILD.bazel`

## 当前版本基线
- Bazel 版本：`.bazelversion` 固定为 `8.1.1`
- Bzlmod：`.bazelrc` 通过 `common --enable_bzlmod` 开启
- 锁文件模式：`.bazelrc` 通过 `common --lockfile_mode=error` 强制锁文件一致性

## 当前依赖与工具链
`MODULE.bazel` 当前声明的核心 rules 与版本如下：

| 类型 | 组件 | 版本 |
|---|---|---|
| Go rules | `rules_go` | `0.49.0` |
| Gazelle | `gazelle` | `0.36.0` |
| Rust rules | `rules_rust` | `0.69.0` |
| .NET rules | `rules_dotnet` | `0.21.5` |
| TypeScript rules | `aspect_rules_ts` | `3.8.8` |
| Node.js rules | `rules_nodejs` | `6.7.3` |
| C/C++ rules | `rules_cc` | `0.2.17` |
| LLVM toolchain | `toolchains_llvm` | `1.7.0` |

`MODULE.bazel` 当前注册的语言版本：
- Go：`1.23.6`
- Rust：`1.83.0`
- .NET SDK：`8.0.100`
- Node.js：`18.19.0`
- TypeScript：`5.8.3`
- LLVM/Clang：`17.0.6`

## Bazel 运行规则
`.bazelrc` 当前强制的关键行为：
- `--repository_cache=/home/vscode/.cache/bazel/repository`
- `--experimental_repository_cache_hardlinks`
- `--output_user_root=/home/vscode/.cache/bazel/output_user_root`
- `--disk_cache=/home/vscode/.cache/bazel/disk`
- `--remote_download_toplevel`
- `--symlink_prefix=.bazel/`
- `build --keep_going`
- `test --test_output=errors`

这些路径约定要求 Dev Container 和 GitHub CI 都把缓存挂载到 `/home/vscode` 这一组目录上。

## 当前各语言构建方式
- Go：`go_binary` 和 `go_test`
- Rust：`rust_binary` 和 `rust_test`
- C++：`cc_binary` 和 `cc_test`
- C#：`csharp_binary` 和 `csharp_test`
- TypeScript：通过 `genrule` 调用 `@npm_typescript//:tsc` 产出 `main.js`，再用 `sh_test` 做烟测

当前 hello_world 示例入口：
- `//services/hello_world/go:hello`
- `//services/hello_world/rust:hello`
- `//services/hello_world/cpp:hello`
- `//services/hello_world/csharp:hello`
- `//services/hello_world/typescript:hello`

## 常用命令
```bash
bazel build //...
bazel test //...
bazel run //services/hello_world/go:hello
bazel run //services/hello_world/rust:hello
bazel run //services/hello_world/cpp:hello
bazel run //services/hello_world/csharp:hello
bazel run //services/hello_world/typescript:hello
```

查看工具链版本：

```bash
bazel run @go_sdk//:go -- version
bazel run @rust_toolchains//:rustc -- --version
bazel run @dotnet_toolchains//:dotnet -- --version
bazel run @nodejs_toolchains//:node -- --version
```

## 变更规则
- 修改 `MODULE.bazel` 或 `MODULE.bazel.lock` 后，必须更新本文档中的版本表和 README 中的相关说明
- 修改 `.bazelrc` 的缓存路径或下载策略后，必须同步更新 `docs/devcontainer.md` 和 `docs/ci.md`
- 新增语言时，优先使用 Bazel 官方或主流规则集，并补齐示例目标、验证命令和文档

## 缓存策略
- Bazel 外部仓库和构建缓存统一落在 `/home/vscode/.cache/bazel`
- Bazelisk 下载缓存位于 `/home/vscode/.cache/bazelisk`
- Dev Container 通过命名卷持久化这些目录
- GitHub Actions 通过 runner 目录挂载和 `actions/cache` 持久化这些目录