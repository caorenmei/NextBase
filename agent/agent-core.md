# Agent Core（统一规则源）

## 目标
- 保持最小改动
- 先读后改
- 先测后交付
- 明确影响范围与回滚路径

## 工作流
1. 读取上下文与约束
2. 形成最小变更方案
3. 先改测试再改实现（可行时）
4. 优先在 Dev Container 中执行最小验证
5. 涉及结构调整时，同时更新 BUILD、模块路径、CI/部署与文档
6. 输出：变更、验证、风险、后续建议

## 环境约束
- 默认不要求本机安装依赖
- 验证命令优先通过容器执行

## Monorepo 约束
- services: 应用与服务，按 Domain -> Group 分层，例如 `services/hello_world/{go,rust,cpp,csharp,typescript}/hello`
- packages: 复用库
- tools: 工具与脚本
- 跨目录依赖需说明原因
- 新增依赖优先走 Bazel 规则管理

## 输出格式
- 先结论，后细节
- 包含：修改文件列表、命令、结果、风险
- 未验证项必须明确标记
