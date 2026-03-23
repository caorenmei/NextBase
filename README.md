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

## 目录
- services: 可部署服务/应用
- packages: 可复用包
- tools: 工具与脚本
- bazel: Bazel 公共宏与规则封装
- agent: Code Agent 统一规则
