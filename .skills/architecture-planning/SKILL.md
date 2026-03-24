---
name: architecture-planning
description: Use when the task involves monorepo topology, directory placement, ownership boundaries, cross-package dependencies, or preventing architectural erosion.
---

# Architecture Planning

## When to use
- Add or reorganize modules, services, shared packages, or tooling folders.
- Define ownership boundaries and dependency directions.
- Prevent monorepo structure drift and long-term coupling.
- Evaluate where new code should live when placement is ambiguous.

## Planning principles
1. Classify first: deployable app/service, reusable package, or engineering tool.
2. Define ownership, consumers, and validation path before creating new structure.
3. Keep dependency direction stable and easy to reason about.
4. Extract shared abstractions only when real multi-consumer reuse exists.
5. Keep generated artifacts and local temporary outputs out of long-lived topology.

## Decision rules
- Prefer minimal placement that fits existing conventions.
- Require explicit justification for cross-boundary dependencies.
- Avoid creating new top-level folders unless existing domains cannot host the change.
- When structure changes, update build metadata, CI pathing, and documentation together.

## Anti-patterns
- "Temporary" placement that becomes permanent without ownership.
- Shared layers that depend on concrete service implementations.
- Tooling directories accumulating runtime business logic.
- Premature abstractions built for a single caller.

## Output expectations
- Provide recommended and rejected placement options with rationale.
- State boundary and dependency-direction impact.
- Identify verified conclusions vs planning assumptions.
- Include rollback strategy when topology changes are non-trivial.

## 中文说明
- 这个技能用于处理 Monorepo 拓扑、目录落点、所有权边界、跨包依赖和架构漂移。
- 新结构优先落在现有边界内，只有当前目录体系无法承载时才考虑扩展顶层目录。
- 中文说明放在正文里，帮助团队理解；`name` 和 `description` 保持英文，利于工具发现。
