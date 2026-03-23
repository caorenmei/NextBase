# Monorepo: Container Dev + Bazel + Code Agent

## 快速开始
1. 使用 Dev Container 打开仓库
2. 执行：
   - bazel run //services/go/hello:hello
   - bazel run //services/rust/hello:hello
   - bazel test //...

## 验证方式（容器优先）
- 不依赖本机 Go/Rust/Bazel 安装
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

示例（Windows PowerShell）:
```powershell
setx DEV_CONTAINER_HTTP_PROXY "http://host.docker.internal:1080"
setx DEV_CONTAINER_HTTPS_PROXY "http://host.docker.internal:1080"
setx DEV_CONTAINER_NO_PROXY "localhost,127.0.0.1,host.docker.internal"
setx DEV_CONTAINER_APT_MIRROR "mirrors.tuna.tsinghua.edu.cn"
```

重启 VS Code（确保 Dev Containers 扩展读取到新的宿主环境变量），然后使用 `Dev Containers: Reopen in Container` 来重建/启动容器。

## 目录
- services: 可部署服务/应用
- packages: 可复用包
- tools: 工具与脚本
- bazel: Bazel 公共宏与规则封装
- agent: Code Agent 统一规则
