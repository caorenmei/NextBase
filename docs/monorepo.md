# Monorepo 规范

## 目录结构
本项目采用标准 Monorepo 结构，分为三个顶层目录：

```
<root>
├── services/       # 可部署服务/应用
├── packages/       # 公共复用库
└── tools/          # 工程工具与脚本
```

### 1. services/ 目录
按业务域组织可独立部署的服务/应用：
- 格式：`services/<business-domain>/<service-name>/`
- 每个服务必须包含：`src/`、`tests/`、`BUILD`、`README.md`
- 示例：
  - `services/user/auth/` - 用户认证服务
  - `services/billing/invoice/` - 账单服务
  - `services/admin/frontend/` - 管理后台前端应用（按业务域划分，admin域下包含前端服务）

### 2. packages/ 目录
跨域公共复用库，被多个服务依赖：
- 格式：`packages/<library-name>/`
- 库必须具有明确的边界和独立的版本
- 示例：
  - `packages/common/utils/` - 通用工具库
  - `packages/db/orm/` - 数据库 ORM 封装
  - `packages/api/sdk/` - 对外 API SDK

### 3. tools/ 目录
工程工具、脚本、CI 相关代码：
- 格式：`tools/<tool-name>/`
- 不得包含业务逻辑
- 示例：
  - `tools/build-rules/` - 自定义 Bazel 构建规则
  - `tools/lint/` - 代码检查工具配置
  - `tools/release/` - 发布脚本

## 命名规范
- 目录和文件名使用小写字母，单词间用下划线分隔（snake_case）
- 服务和库名称应清晰描述其职责，避免模糊命名
- 避免使用缩写，除非是行业通用缩写（如 API、SDK）

## 依赖规则
### 基本原则
- **依赖方向唯一**：services → packages → tools，禁止反向依赖
- **跨域依赖必须显式声明**：服务不能直接依赖其他服务的内部代码，必须通过公共包或 API 调用
- **最小依赖原则**：只依赖实际需要的包，避免引入不必要的依赖
- **禁止循环依赖**：A 依赖 B，B 不能再依赖 A（直接或间接）

### 允许的依赖
✅ `services/<domain>/<service>` → `packages/*`
✅ `services/<domain>/<service>` → `tools/*`
✅ `packages/<lib>` → `packages/*`
✅ `packages/<lib>` → `tools/*`
✅ `tools/*` → `tools/*`

### 禁止的依赖
❌ `services/*` → `services/*`（服务间不能直接依赖代码，必须通过 API 或公共包）
❌ `packages/*` → `services/*`（公共包不能依赖服务实现）
❌ `tools/*` → `services/*`、`tools/*` → `packages/*`（工具不能依赖业务代码）

## 构建规则
- 所有可构建目标必须在对应目录下的 `BUILD` 文件中声明
- 目标命名：`{name}_{type}`，如 `auth_service_bin`、`user_lib`、`auth_test`
- 测试目标必须包含 `_test` 后缀
- 禁止使用绝对路径引用，必须使用 Bazel 标签格式：`//path/to/package:target`

## 版本管理
- 公共包（packages/）使用语义化版本号
- 服务版本与发布版本保持一致
- 所有依赖版本在 `MODULE.bazel` 中统一管理

## 目录新增规则
- 优先使用现有目录结构，禁止随意新增顶层目录
- 新增业务域需要在 `services/<domain>/` 下创建，需包含 `README.md` 和 `OWNERS` 文件
- 新增公共包需要评估是否真的需要多服务复用，避免过度抽象

## 验证规范
- 提交代码前必须运行受影响目标的测试：`bazel test //path/to/target/...`
- CI 会自动运行全量测试，确保所有目标构建和测试通过
- 修改公共包需要运行所有依赖该包的服务的测试