# csp-quality — 测试/安全/CR 包

本目录是 quality 子包的内部目录结构占位。正式拆包时：
- quality-meta/     → 测试方法论、安全框架、CR 规范
- quality-workflow/ → 测试管道（TB→TD→TU→TI→TE→TQ）、安全审计流程
- quality-patterns/  → pytest/vitest/playwright/sonarqube/snyk 等工具链
- quality-runtime/   → 自动测试、持续安全扫描、门控集成

当前种子: quality-patterns/skills/csp-quality-seed/