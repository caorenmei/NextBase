---
name: dependency-build
description: Use when the task involves build metadata, dependency graph correctness, target granularity, cache hit rate, or build and test verification.
---

# Dependency Build

## When to use
- Add, split, or update build targets and dependency declarations.
- Fix graph correctness issues (missing/extra deps, wrong target boundaries).
- Improve incremental build behavior and cache hit rates.
- Align local build behavior with CI build behavior.

## Core workflow
1. Read affected build metadata and root-level build configuration first.
2. Separate graph-definition issues from toolchain/runtime issues.
3. Keep targets single-purpose with clear inputs and outputs.
4. Prefer explicit direct dependencies over broad aggregate dependencies.
5. Validate changed targets first, then expand to wider scope if impact is broad.

## Graph and granularity rules
- Keep dependency edges minimal and intentional.
- Avoid oversized shared targets that force unnecessary rebuilds.
- Split libraries/tests where it improves cache reuse and ownership clarity.
- Document cross-boundary dependencies and justify why they are necessary.
- Keep build metadata and lockfiles consistent after dependency changes.

## Validation examples
- Graph query/check command(s) for the project build system.
- Build/test for affected targets.
- Full-suite build/test when changing shared rules or root dependencies.

## Output expectations
- Summarize changed targets, dependency edges, and lockfile impact.
- Explain expected effect on graph correctness and cache efficiency.
- Report commands executed and unverified coverage.

## 中文说明
- 这个技能用于处理构建元数据、依赖图正确性、目标粒度、缓存命中率和构建验证。
- 修改依赖或目标时，优先让目标边界与目录边界尽量一致，减少横向耦合和不必要重建。
- 中文说明保留在正文中；`name` 和 `description` 保持英文，方便跨工具发现和复用。
