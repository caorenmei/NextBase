---
name: development-environment
description: Use when the task involves reproducible development setup, containerized workflows, cache strategy, build speed, network configuration, or container security hardening.
---

# Development Environment

## When to use
- Setup or change local/container development environments.
- Improve reproducibility, startup/build speed, or cache reuse.
- Configure proxy, mirror, certificate, or network-related build behavior.
- Harden container security, permissions, and supply-chain exposure.

## Core workflow
1. Read existing environment docs and config before editing.
2. Prefer the smallest change that improves consistency across contributors.
3. Keep cache strategy explicit and stable (image-layer cache vs runtime cache).
4. Apply security-first defaults: least privilege, no secret hardcoding, minimal network surface.
5. Run minimal verification in the target environment and report any unverified scope.

## Checklist
- Reproducibility: same commands should work across fresh environments.
- Performance: cache paths/mounts remain deterministic and reusable.
- Safety: credentials are externalized; privileged operations are minimized.
- Scope control: no build artifacts or machine-local temp files are added to version control.
- Documentation: usage changes are reflected in project docs.

## Validation examples
- Environment/toolchain version checks.
- Dependency graph or lockfile resolution checks.
- Build and test command(s) used by the project CI path.

## Output expectations
- List changed files and why they were necessary.
- State impact on consistency, speed, and security.
- Include executed verification commands and clear unverified items.

## 中文说明
- 这个技能用于处理开发环境一致性、容器化工作流、缓存策略、构建速度和容器安全。
- 修改环境时，优先保持缓存路径、命名卷和构建入口一致，避免不同开发者得到不同结果。
- 中文说明放在正文里，便于团队阅读；`name` 和 `description` 继续保留英文，方便各类 Code Agent 发现。
