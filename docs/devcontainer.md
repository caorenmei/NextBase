# DevContainer 开发环境

## 设计原则
1. **一致性**：所有开发者使用完全相同的开发环境，避免"本地能跑"问题
2. **高性能**：最大化利用缓存，减少构建和下载时间
3. **安全**：最小权限原则，无硬编码密钥，凭证外置
4. **可扩展**：支持自定义代理、镜像源，适配不同网络环境
5. **最小改动**：保持配置精简，仅包含项目必需的依赖

## 目录结构
```
.devcontainer/
├── devcontainer.json      # DevContainer 主配置文件
├── devcontainer.schema.json # 配置文件JSON Schema（可选，用于编辑器提示）
├── Dockerfile             # 容器镜像构建文件
└── scripts/               # 辅助脚本目录
    └── generate-proxy-env.sh # 代理环境变量生成脚本
```

## 各文件说明

### 1. [devcontainer.json](../.devcontainer/devcontainer.json)
主配置文件，定义：
- 容器构建参数（代理、镜像源等）
- VSCode 扩展推荐列表
- 端口转发配置
- 缓存挂载卷（Go、Rust、Bazel、npm 等缓存目录）
- 容器启动后执行的命令（postCreateCommand）

### 2. [Dockerfile](../.devcontainer/Dockerfile)
容器镜像构建文件，仅预装最小运行依赖，**所有编程语言工具链完全由 Bazel 自动管理**：
- 基础镜像：`mcr.microsoft.com/devcontainers/base:ubuntu`
- 仅预装工具：
  - Bazelisk (bazel 命令，Bazel 版本管理器)
  - GitHub CLI (gh，通过官方 APT 源安装)
  - 系统基础工具（curl, git, unzip, build-essential 等，仅用于 Bazel 运行）
- 内置代理和APT源自动配置
- 预创建 Bazel 缓存目录并设置正确权限

> 注意：**所有开发工具链（Go、Rust、.NET、Node.js、TypeScript、C/C++ Clang 等）都不再预装在容器中**，由 Bazel Hermetic Toolchain 自动下载和管理版本，确保所有开发者、CI 环境使用完全相同的工具链版本，无任何版本差异。

### 3. scripts/generate-proxy-env.sh
代理环境变量生成脚本，用于自动适配宿主机代理配置，无缝支持有代理和无代理环境。

## 缓存策略
通过容器卷挂载持久化缓存，避免重复下载：
- `/home/vscode/.cache/bazel` - Bazel 构建缓存
- `/home/vscode/.cache/bazelisk` - Bazelisk 版本缓存
- `/home/vscode/go/pkg/mod` - Go 模块缓存
- `/home/vscode/.cargo/registry` - Rust 依赖缓存
- `/home/vscode/.nuget/packages` - .NET 包缓存
- `/home/vscode/.npm` - npm 包缓存

## 使用方法
1. 在 VSCode 中安装 "Dev Containers" 扩展
2. 打开项目根目录，点击右下角弹窗中的"Reopen in Container"
3. 等待容器构建完成（首次构建需下载依赖，后续启动秒开）

## 自定义配置
如需自定义代理或镜像源，可在 `.devcontainer/devcontainer.json` 中修改 `build.args` 配置：
```json
"build": {
  "args": {
    "USE_PROXY": "1",
    "HTTP_PROXY": "http://your-proxy:port",
    "HTTPS_PROXY": "http://your-proxy:port",
    "APT_MIRROR": "mirrors.aliyun.com"
  }
}
```