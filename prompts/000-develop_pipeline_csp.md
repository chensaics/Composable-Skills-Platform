使用 [[workflow:csp-lifecycle-orchestrator]] 从当前 .csp/lifecycle-state.json 续跑，连续推进所有待交付版本（待交付 = ROADMAP 中 status planned/in-progress；deferred 版本不并入活跃队列）。每个版本 06 done 后自动读 `docs/strategy/ROADMAP.md` 取下一个未交付版本，直接进 05 实施，直到队列清空。

**前置条件**：ROADMAP 须已通过 `[[prompts/000-product-planning_csp.md]]` 的完整规划流程（Phase 0→7）——
ROADMAP 含功能-模块-描述-边界-测试维度-任务路径全部详情，PRD SPEC 已完成，技术 Spec (Layer 4) 已完成，任务拆解 (Phase 7) 已完成，`.csp/tasks/TASK-INDEX.md` 含依赖 DAG。

仅当我说"只做某个版本"时才单版本停。

每轮按 `[[workflow:csp-knowledge-hub]]` 四层入口定位当前状态与任务相关源。前置三读（缺一不可）：
① 读 `.csp/agent-conventions/` 全部规范（ai-coding-guardrails.md 的 G-01~G-08、VERIFICATION-DISCIPLINE.md 等），05 开发逐条遵守，禁因"知道了"跳过；
② 读 `.csp/{audit,ui-review,critic,gap-analysis}/` 最新批次 findings，把与本版本主题对应的 findings 并入入口清单作为验收项；
③ 对账 `.csp/lifecycle-state.json` 与 `docs/strategy/ROADMAP.md`（前者为运行时真相、后者为规划真相），漂移则按授权修复并记 DEV-LOG。

**lifecycle-state 写入对账**（写入时主动校验，不等下次读取才发现漂移）：
```bash
# 写入 lifecycle-state.json 前必须交叉验证 git tag
python3 prompts/scripts/lifecycle_tag_reconcile.py --check
# 不一致 → raise, 不写入。禁止静默漂移。
```

**输入校验**：任务清单 `.csp/tasks/TASK-INDEX.md` 必须存在——这是 `000-product-planning_csp.md` Phase 7 的产出。缺失说明规划未完成，回 `000-product-planning_csp.md` 补，不进 05。

**PRD 深度门控**（05 入口强制检查）：
```bash
# 每个版本必须有 engineering 级 PRD，不能是 planning 骨架
grep "prd_depth: engineering" docs/prd/PRD-{version-slug}.md
```
不匹配 → **BLOCKED**，回 `000-product-planning_csp.md` Phase 5→6 升级 PRD。原因：planning 级 PRD 只有大纲——缺少完整 AC（≥3 条/模块）、错误场景矩阵、埋点定义。不能拿大纲当开发规格。

**Spec 到位检查**（每个 task 开始前）：
- 对应 Spec（`.csp/planning/spec.md` + `.csp/tech-design/`）必须存在且 `build_status: built`
- Spec 含完整 8 面：接口契约/数据模型+DDL/业务规则/错误场景/状态机/前端交互/安全权限/运维就绪——按项目类型选择必写面，缺必写项不进 05
- 前端项目 → 面 6（前端交互）必写
- 有鉴权项目 → 面 7（安全/权限）必写
- 所有 feature → 面 8（运维就绪）必写

开发阶段（05）使用 [[workflow:csp-implementation-phase]]，遵循 TDD 流程 [[meta:csp-tdd]]，coding agent 遵守 [[pattern:csp-coding-standards]] 的全部命名/安全/跨层对齐规则。

**TDD 执行纪律**（05 开发期）：先写测试 → 实现 → 重构，测试与源码同 commit 提交：
- **测试基建健康检查**（05 首个 task 前必跑）：`pytest --collect-only` / `vitest run --reporter=json` 确认测试框架可正常加载。conftest/fixture/mock 引用路径断裂 → BLOCKED（先修基建再写新代码，不阻塞新测试）

**并发 Agent 安全**（多 Agent 并行开发时）：同一工作树同时仅一个会话修改代码；manifest/状态文件写前检查 `DIRTY_HASH` 未变；冲突时后者回滚并报告，不静默覆盖
- **单元测试**：按项目已有 runner 约定紧邻源码或镜像模块目录（如 `src/xxx.ts` ↔ `tests/unit/xxx.test.ts`），在实现前先写可运行断言
- **API/集成测试**：与受影响端点同步产出，使用实际测试根（monorepo 可在应用目录），不要求仓库根 `tests/integration/`
- **E2E 测试**：核心路径随开发构建可运行用例，发布门禁再实测；单有脚本骨架不等于通过
- 测试代码与实现代码在同一 commit，不拆"先提交实现、下个 commit 补测试"

**05 完成**：源码 + 按变更风险配置的单元/API/组件/跨层测试 + 本阶段实跑证据；E2E 关键路径至少有可执行断言。项目无对应层时标不适用依据，未执行则不能称通过。

**05 Agent 写后验证纪律**（HARD BLOCK — 每文件写完后立即执行，不等到 06 gate）：
> grep 只能确认"文本写入了"，不能确认代码能编译/TPU。以下三项是 Agent 写文件后的**最低验证门槛**，缺一项即 05 未完成。

| 验证项 | 触发条件 | 命令 | 通过标准 |
|--------|---------|------|---------|
| **Build 验证** | 每次写文件后 | 项目实际构建命令（`pnpm build` / `npm run build` / `make build`） | exit 0，无 error |
| **Type-Check 验证** | 写 .ts/.tsx/.py（有类型注解）后 | `tsc --noEmit` / `mypy <file>` / `pyright` | exit 0，新增 import 全部 resolve |
| **CSS/样式构建验证** | 写 .css/.scss 或改 tailwind 配置后 | `tailwindcss` 编译 / PostCSS 处理 / 至少跑一次 build | 无 CSS parse error / `@import` 全部 resolve |

**写后验证红线**：
- **Build exit ≠ 0 → BLOCKED**。不允许"build 挂了但 commit 先 push，下次再修"。必须本 commit 修到 build 通过。
- **grep 断言 ≠ 编译验证**。grep 只能确认写出去了，不能确认 import 路径正确、CSS parser 能消费、模块能 resolve。Agent 写文件后必须跑对应语言的 type-check 或 build。
- **新建文件必跑 type-check**。Agent 新建 .tsx/.ts/.py 文件时，至少对新文件的 import 做 resolve 验证。`@/components/ui/button` 能 resolve 才算通过——grep 到 import 行不算通过。
- **CSS/样式文件必跑 build**。Agent 写 .css/.scss 或改 tailwind 配置时，必须跑一次完整 build（或至少 `tailwindcss` 编译验证）。CSS parse error 在 build 阶段就会暴露，不等到 E2E/视觉回归才抓。
- **增量验证优先**：仅对受影响的文件跑 type-check/build，不强制全量。但"受影响"的定义是 import 链上的文件——新建文件 import 了 A，A 的调用方也要覆盖。
- **写后验证证据落盘**：每次验证的命令 + exit code 写入 DEV-LOG 或 `.csp/artifacts/verify/evidence/post-write-{commit-short}.log`

**反模式**：

| 反模式 | 正确做法 |
|--------|---------|
| 写完多个文件后一起 build | 每文件写后立即验证——批量 build 的报错无法定位是哪个文件引入的 |
| 用 grep 代替 type-check | `grep "import.*Button"` 返回 match 不代表 `@/components/ui/button` 能 resolve |
| "build 失败是 CI 的事，我先把代码提交了" | CI 抓到不如本地抓到——Agent 写文件时就能验证，延迟到 CI 是浪费一次 push |
| CSS 只跑 lint 不跑 build | `stylelint` 通过不代表 PostCSS/tailwindcss 能编译——`@import url("tailwindcss")` 不会报 lint 错但 build 必挂 |

**全栈开发模式**（05 开发期间引导各层实现）：
- 前端：`[[skill:csp-frontend-patterns]]`（组合/状态/性能/表单/数据获取，框架无关）
- 后端：`[[skill:csp-backend-patterns]]`（API 设计/分层架构/错误处理/幂等/分页）
- 数据库：`[[skill:csp-postgres-patterns]]`（Schema 设计/索引/查询优化）+ `[[skill:csp-db-migration]]`（Schema 变更/数据迁移/回滚/零停机）

**模型层并行安全**（遵循 [[G-14 并行写入互斥]]）：
- Wave 1（模型/迁移）：主进程串行创建——模型是共享基础设施
- Wave 2（服务/API）：Agent 并行创建，`__init__.py` 注册由主进程统一执行
- Wave 3（前端）：Agent 并行，独立验证，共享状态冲突少

**创建 Model 前**：遵循 [[G-12 创建数据实体前查重]]，`grep` 表名/类名，零命中才允许。

**Agent 写后验证**：遵循 [[G-13 写后验证覆盖 import 可达性]]，lint/format 通过不足够——必须 import 能 resolve。

**API Registry 路由规则**（防止重复注册/遗漏注册——来自复盘因果链 1+3）：
- 新 router **只进一个** registry 文件。项目有多个 registry 时，逐版本开发期间一律进 `recent_features.py`（或项目约定的标准入口）。除非项目有明确的**域→registry 映射表**（如 `ai_intelligence.py: AI domain / recent_features.py: recent features`），否则 Agent 不自行判断"这个功能属于哪个域"
- 创建 API 文件**同一次修改必须包含注册**——遵循 [[G-15 新模块创建必附带接入点注册]]。Agent 创建 `api/v1/xxx.py` 后必须同步修改 registry 的 `include_router` 行
- **提交前检查**：
  ```bash
  # 新增 API 文件 → registry 也必须有新增行
  diff <(git diff --cached --name-only | grep "api/" | sort) \
       <(git diff --cached | grep "^+.*include_router\|^+.*router" | grep -oP '["\x27].*?["\x27]' | sort)
  ```

**启动时路由验证**（06 门控的一部分——防止重复和遗漏积累到生产）：
```bash
# 检查 1：无重复路由
# 启动 app 时自动执行 assert_no_duplicate_routes() 断言

# 检查 2：无孤儿 API 文件
# 对比 api/ 目录下的文件列表 vs 已注册的路由
python3 scripts/router_registry_check.py
```
重复路由 → BLOCKED（双注册导致每个 endpoint 出现 2 次）。孤儿 API 文件 → BLOCKED（文件存在但从未被注册，不可达）。

**Lint/Type 豁免基线**（解决预存错误阻塞门控）：
- 项目已有 `.csp/exemptions.json` 时，gate 脚本读取豁免后判断「新增回归」而非「全量 zero」
- 格式：`{"tsc": ["file:line:error_code"], "ruff": ["file:line:rule"], "mypy": ["file:line:error_code"]}`
- gate 逻辑：`current_errors − exemptions = new_errors`；new_errors > 0 → BLOCKED；new_errors == 0 → PASS

**数据库开发保障**（05 开发期间）：
- Schema 设计：从 `docs/architecture/DATA-SCHEMA.md` 取字段名，生成 DDL。开发中新字段先更新数据字典，再改 Spec，再写代码——不要反过来
- SQL 审查：`[[skill:csp-sql-reviewer]]` — 每条新增/变更 SQL 过审
- DB 性能：`[[skill:csp-db-performance]]` — 热路径 SQL 索引/查询优化
- 数据完整性：`[[skill:csp-db-state-assertion]]` — 写操作前后 DB 状态验证
- API 治理：`[[skill:csp-api-governance]]`（契约/版本管理/限流/认证授权模式）

**代码质量保障**（05 开发期间并行）：
- 编码规范：`[[pattern:csp-coding-standards]]`（通用跨语言规范）+ 语言专精（`[[skill:csp-python-coding-standards]]` / `[[skill:csp-java-coding-standards]]` / `[[skill:csp-cpp-coding-standards]]`）
- 关键日志：`[[skill:csp-observability-and-instrumentation]]`（关键路径日志/结构化日志/trace_id，不遗漏也不冗余）
- DRY 与复用：`[[skill:csp-code-simplification]]`（死代码清理/AI 冗余消除/重复逻辑合并）+ `[[skill:csp-refactoring-strategies]]`（重构路径规划）
- 最小改动：`[[skill:csp-minimal-change-engineer]]`（只修该修的，拒绝 scope creep）

**测试嵌入**：开发期间测试并行推进——`[[prompts/000-test_pipeline_csp.md]]` 从当前版本的 PRD SPEC 提取测试依据→设计用例→分层实施，产出测试证据直接嵌入 S6 质量门控。

自决策授权（默认自己拍板，不问我）：范围/优先级、Wave 排序、fix 路由（05 实现缺陷 vs Spec 缺口）、可逆整改（已授权移动后的 manifest re-point、版本漂移核对）、CMS re-align——这些你自己定，定了记入 DEV-LOG 即可，不打断我。**deferred 禁止自决策**：任何 deferred 项必须在 DEV-LOG 中注明解除条件 + 预期版本——不是"下轮再说"的万能兜底。

循环收敛：06 未过按根因回 05/03 修 delta 重验，循环到全绿；超 5 轮再报我。跨版本熔断：连续 3 个版本因同一根因失败，暂停并报我，附根因证据链。

06 done 硬定义（由 [[workflow:csp-release-manager]] 执行全流程，详见 prompts/06-verify-ship.md，任一不满足即 06 未过）：
- **G-11 Tag 前置门控**（打 annotated tag 前必须六项全绿，缺一项禁止打 tag）：
  执行: `python3 prompts/scripts/tag_gate.py --tag vX.Y.Z --json`
  （自动检测项目技术栈，六项逐一 ran+exit 证据。全部 exit 0 → PASS，任一项 non-zero → BLOCKED）

- S6 质量门控全 ran（附命令+exit code 证据，禁止 not-run 降级）：
  Check 1: 测试 → [[workflow:csp-verify-phase]] Check 1
  Check 1.5: 有后端 API 变更时跑项目实际的 API/集成测试套件（从测试配置定位，不假定 `tests/backend/api/` 存在），附命令/exit；无此类变更注明依据
  Check 2: Lint → ran: <lint cmd> exit 0
  Check 3: Build → ran: <build cmd> exit 0
  Check 4: TypeCheck → ran: <tsc/mypy> exit 0
  Check 5: AC 逐条演示
  Check 5.5: 前端专项（前端项目必检，纯后端 skip）：
    Check 5.5a: 无障碍审计 → [[agent:csp-a11y-architect]]（WCAG 2.2 AA 合规）
    Check 5.5b: 前端性能 → [[agent:csp-web-performance-auditor]]（CWV 不劣化）或 [[skill:csp-frontend-performance]]（bundle/缓存优化）
    Check 5.5c: 跨层契约验证 → [[skill:csp-cross-layer-testing]]（前后端接口契约一致性，UI→API→DB 往返 traceable）
  Check 5.6: E2E 测试（有 UI 的项目必检）→ [[skill:csp-e2e-testing]]（全路由 sweep + 关键路径冒烟，Playwright/Cypress，exit 0）
  Check 5.7: 视觉回归测试（有 UI 且改动了界面时必检）→ [[skill:csp-visual-regression]]（截图 vs 基线 diff，无意外变更）
  Check 5.8: DB 迁移验证（有 DB schema 变更时必检）→ [[skill:csp-db-migration]]（正向/回滚 ran，数据完整性验证，exit 0）
  Check 5.8a: SQL 审查 → [[skill:csp-sql-reviewer]]（新增/变更 SQL 全量过审）
  Check 5.8b: DB 状态断言 → [[skill:csp-db-state-assertion]]（写操作前后 DB 状态验证，字段完整性）
  Check 5.8c: Schema 漂移检测 → [[skill:csp-schema-drift-detection]]（ORM 声明 vs information_schema 物理列 diff——迁移工具说 head≠真实 schema 时阻断发布）
  Check 5.8d: 字段名一致性 → `docs/architecture/DATA-SCHEMA.md`（数据字典）vs 代码 model/API 响应/DB 列名三者对齐——数据字典写 `user_id` 但 API 返回 `id` → BLOCKED
  Check 5.8e: DB 表命名 → 新增表名禁版本前缀（`v329_` `v328_` 等）。版本号属于 migration chain，不属于表名。违规表名记录技术债，不阻塞发布但必须登记
  Check 5.9: 安全审查 → [[skill:csp-security-review]]（鉴权/越权/注入/XSS/CSRF/敏感数据脱敏/依赖漏洞）
  Check 5.10: 后端性能 → [[skill:csp-backend-performance]]（API P95/慢查询索引/N+1/缓存策略/连接池，有后端时选做）
  Check 5.11: 前后端接线验证 → 基于实际路由/消费者、运行证据核对；静态搜索只能给候选，不能称机器接线门禁。无消费者先区分公开 API/后台任务与 UI 必需能力，按本版 Spec 裁决
  Check 5.12: 命名规范 → [[agent:csp-project-standards-reviewer]] 检查项目及语言约定，发现无语义版本/milestone 副本提出重命名；迁移 revision、稳定公开协议标识等要验证使用方，不能按正则盲改并称通过
  Check 5.13: 审计 findings 闭合 → P0 audit finding = 0（全部 closed，附 fix commit 证据）；P1 > 3 条同 P0 阻断
  Check 5.14: 门控合规审计 → [[skill:csp-gate-compliance]] — 上一版 gate snapshot 是否 BLOCKED 且无修复记录即 shipped？gate 证据是否来自当前 commit？中间版本是否缺 gate 记录？有违规 → 不打 tag，先闭合
  Check 5.15: 路由完整性 → `assert_no_duplicate_routes()` exit 0（无重复注册）+ `python3 scripts/router_registry_check.py` exit 0（无孤儿 API 文件）
  （工具链不可用 = BLOCKED，不得用 grep/review 替代动态门控）
- 运行环境先探测实际服务/启动命令、端口身份和可用凭据；按项目授权启动并探活，不默认 Compose、npm 或固定重试次数。视觉/性能/API 文档动态检查工具不可用时标未执行及解除条件，不能用静态 grep 冒充动态验证。
- S7 审查无 CRITICAL → [[workflow:csp-code-review]] + [[pattern:csp-santa-method]]（关键模块双审）
- 每阶段完成后技能蒸馏 → [[workflow:csp-skill-distiller]]（收集执行观察，识别技能缺口，产出具象改进提案到 `.csp/skill-improvements/`）
- 跨层集成验证 → [[pattern:csp-integration-review]]（11 场景全栈契约审查）
- 7.6 对账 reconciled=true（含 findings 闭合闸门 exit 0）
  → `python3 prompts/scripts/findings_closure_check.py --baseline .csp/findings-baseline.json`
- **Tag 后 findings 升级**: `python3 prompts/scripts/findings_closure_check.py --promote --tag vX.Y.Z`
  （STAGED_CLOSED → CLOSED。tag 前标记 staged，tag 后批量升级——解决"预关闭回滚"缺陷）
- 版本对齐：按本项目真源传实际存在的 `--files` 运行 `python3 prompts/scripts/version_integrity_check.py --files <...> --baseline .csp/version-baseline.json`。脚本当前只实现 T1–T4；缺文件为 WARNING，存量基线可豁免旧违规，不得因此声称 T5/T6、所有来源、Release 或线上版本已自动校验。发布/部署状态另以远端 Release 与运行环境证据核对
- 归档完成 → [[workflow:csp-ship]] + 里程碑归档
- 文档结构维护 → [[workflow:csp-documentation-governance]]（对外/对内文档分界 + 更新触发规则）
- C-01 批量交付 S6 完整性格栅：batch_evidence_map 不得缺失
- Phase 0.6 发布复发检测：WARNING/BLOCKED 按阈值处理
- deferred 审视 gate：06 done 前逐条审视 deferred 列表——不可 deferred 的升为 done/BLOCKED，可 deferred 的确认解除条件有效，超 3 条或跨版本 deferred 减速报用户

留尾纪律：剩余项只能 done / BLOCKED（附阻塞+谁解除）/ deferred（附解除条件并计入 Release notes），禁止"下轮再补/gate 全绿就交差"。deferred 项不阻塞当前版本发布，但要自动并入下一版本 01 的入口清单。

**deferred 纪律（防积压）**：
- **不可 deferred**：本版本 Spec 明确列出的功能点、AC 覆盖的验收项、已发现的 P0/P1 缺陷——这些是本版本的"已承诺范围"，要么 done 要么 BLOCKED，不准 deferred
- **可 deferred**：本版本 Spec 未列入的非承诺项、用户口头提到的"顺便看看"、发现但 P2/P3 的问题——这些可 deferred，但必须附解除条件（触发版本/依赖就绪/用户确认）
- **deferred 上限**：每个版本 deferred 项不超过 3 条（超过 → Agent 必须在 06 done 前 review 并合并/升级/eliminate，减速报用户）
- **deferred 不得跨版本：同一项连续 2 个版本出现在 deferred 列表中 → 必须升级为 BLOCKED（标注阻塞原因）或降级为 WONTFIX（明确不做）——禁止"永远 deferred"项
- **06 done 前 deferred 审视**：发布前逐条过——这个真的本版本做不了？还是"懒得做/忘了做/没规划好"？
  - "本版本做不了" → 保留 deferred + 明确的解除条件
  - "懒得做" → 升为 done（立即做，不拖延）
  - "忘了做" → 升为 BLOCKED（标注阻塞原因）
  - "没规划好" → 回 01/03 补 Spec

收尾必做：
- commit（Conventional Commits、原子提交；遵循 [[pattern:csp-git-conventions]] §3 Commit Workflow）
- CHANGELOG.md 追加
- tag（遵循 prompts/version-management.md §五 Tag 规则：v 前缀 + annotated + 不可变 + 一 commit 一 tag）
- 六处版本同步 → `python3 prompts/scripts/version_integrity_check.py`
- push origin → Release → 归档
- CI/CD 管道验证 → [[skill:csp-cicd-pipelines]]（构建/测试/部署管道通过，GitHub Actions/Jenkins 绿）
- 部署 → [[skill:csp-deployment]]（健康检查/回滚策略/灰度/蓝绿，无 downtime）
- 可观测投产 → [[skill:csp-monitoring-alerting]] + [[skill:csp-observability-and-instrumentation]]（关键指标/日志/链路/告警规则已就绪）

findings 回写契约：仅对"本版本真实修复且已验证"的 findings 回写；fixed_in 必须真实存在（tag/commit）+ verification 证据（file:line / ran+exit / 实机截图）。预关闭 → exit 1。

版本与门禁条款：
- 纯文档 commit 禁打版本 tag（[[pattern:csp-git-conventions]] §6 Tag Discipline）
- 一 commit 一 tag，禁多 tag 同 commit
- guardrail 脚本落盘 + CI 接线，未接 CI 不得声称 enforcement

每版本 checkpoint 落盘：更新 .csp/lifecycle-state.json + DEV-LOG 追加本轮决策摘要，保证会话中断可无损续跑。

gate 即授权，全自动推进。打断条件（仅 6 类）：战略根本模糊 / PRD Rejected / 真破坏操作 / 多 tag 不明 / 无法 auto-resolve 的报错 / deferred 堆积（单版本 >3 条或同项跨 2 版本 deferred）。07 复盘默认自动触发（[[pattern:csp-retro]]），lessons 并入下一版本 01 入口清单。质量自评可选用 [[pattern:csp-agent-self-evaluation]] 做 5 轴结构性复盘。

**每阶段完成后技能蒸馏**：01-07 每阶段 gate 通过后，自动触发 `[[workflow:csp-skill-distiller]]` — 收集本阶段的执行观察（失败的 gate/修复性 commit/用户纠正），识别 CSP 技能体系的规则缺失/门禁缺失/技能空白，产出具象改进提案到 `.csp/skill-improvements/`。P0 提案立即执行修改。蒸馏不是复盘——复盘分析项目问题，蒸馏分析技能缺口。

**缺口报告**：执行过程中若发现本说明未覆盖的维度、或引用的 CSP skill 不包含所需方法论（功能缺失/深度不足），**立即指出缺口**——不跳过、不假装覆盖、不用「可以了」糊过。

迭代间代码健康维护（版本间隙或 07 复盘发现代码债时触发）：
- 重构 → `[[skill:csp-refactoring-strategies]]`（Strangler Fig / Branch by Abstraction / 并行运行，大规模架构演进）
- 代码整洁 → `[[skill:csp-code-simplification]]`（死代码清理/简化 AI 生成冗余/移除未使用依赖）

完成每个版本按进度条格式播报，全部版本清空后输出总发布摘要再停。

---

## CSP Skill 路径速查

| 阶段 | CSP Skill |
|------|-----------|
| 全生命周期编排 | `[[workflow:csp-lifecycle-orchestrator]]` |
| 并行开发（05） | `[[workflow:csp-implementation-phase]]` |
| TDD | `[[meta:csp-tdd]]` |
| 测试方法论 → 专项测试 skill 分派 | `[[meta:csp-test-methodology]]` |
| 编码规范 | `[[pattern:csp-coding-standards]]` |
| 前端开发模式 | `[[skill:csp-frontend-patterns]]` |
| 后端开发模式 | `[[skill:csp-backend-patterns]]` + `[[skill:csp-postgres-patterns]]` |
| 数据库迁移 | `[[skill:csp-db-migration]]` |
| SQL 审查 | `[[skill:csp-sql-reviewer]]` |
| DB 性能 | `[[skill:csp-db-performance]]` |
| DB 状态断言 | `[[skill:csp-db-state-assertion]]` |
| Schema 漂移检测 | `[[skill:csp-schema-drift-detection]]` |
| API 治理 | `[[skill:csp-api-governance]]` |
| 代码整洁 | `[[skill:csp-code-simplification]]` + `[[skill:csp-refactoring-strategies]]` |
| 最小改动工程 | `[[skill:csp-minimal-change-engineer]]` |
| 可观测与日志 | `[[skill:csp-observability-and-instrumentation]]` |
| 质量门控（06） | `[[workflow:csp-release-manager]]` 或 `[[workflow:csp-verify-phase]]` |
| 审查（07） | `[[workflow:csp-code-review]]` |
| 双审对抗验证 | `[[pattern:csp-santa-method]]` |
| 跨层集成审查 | `[[pattern:csp-integration-review]]` |
| 安全审查 | `[[skill:csp-security-review]]` |
| 门控合规审计 | `[[skill:csp-gate-compliance]]` |
| 后端性能 | `[[skill:csp-backend-performance]]` |
| 无障碍审计 | `[[agent:csp-a11y-architect]]` |
| 前端性能 | `[[agent:csp-web-performance-auditor]]` 或 `[[skill:csp-frontend-performance]]` |
| 跨层契约测试 | `[[skill:csp-cross-layer-testing]]` |
| E2E 测试 | `[[skill:csp-e2e-testing]]` |
| 视觉回归测试 | `[[skill:csp-visual-regression]]` |
| 发布 | `[[workflow:csp-ship]]` |
| CI/CD 管道 | `[[skill:csp-cicd-pipelines]]` |
| 部署策略 | `[[skill:csp-deployment]]` |
| 可观测 | `[[skill:csp-monitoring-alerting]]` + `[[skill:csp-observability-and-instrumentation]]` |
| Git 规范 | `[[pattern:csp-git-conventions]]` |
| 复盘 | `[[pattern:csp-retro]]` |
| 技能蒸馏 | `[[workflow:csp-skill-distiller]]` |
| 文档治理 | `[[workflow:csp-documentation-governance]]` |

---

## 文档协作关系

```
000-product-planning_csp.md
  │  产出: ROADMAP (Layer 1+2: 功能/模块/边界/测试/任务) + PRD SPEC + 技术 Spec (Layer 4) + 任务拆解
  │  门控: Phase 2.5 集成审视 + Phase 3 收敛审查 + 规划完成门控
  │
  └──→ 000-develop_pipeline_csp.md（本文件）
          │  开发 Pipeline: 读任务清单 → 05(实施) → 06(质量门控+发布) → 07(复盘)
          │  不包含 01→04（已在 planning 完成）
          │  输入: .csp/tasks/TASK-INDEX.md + .csp/planning/spec.md
          │
          ├──← 06 质量门控消费测试证据
          │       │
000-test_pipeline_csp.md ←──┘
  │  测试 Pipeline: TB→TD→TU→TI→TE→TV→TP→TSEC→TQ
  │  Spec (Layer 4) → 测试依据/用例 → 分层实施 → 嵌入 06 门控
```

- **上游输入** = `000-product-planning_csp.md` 产出的完整规划包（ROADMAP + PRD + Spec + 任务清单）
- **本文件职责** = 纯开发执行: 读任务 → 写代码 → 质量门控 → 发布 → 复盘
- **测试嵌入** = `000-test_pipeline_csp.md` 从 Spec 提取测试依据 → 分层实施 → 证据嵌入 06 门控
- **项目治理** = `[[prompts/000-project-governance_csp.md]]` 定义产物路径/版本管理/文档边界

---

继续完成所有版本的任务开发。采用多 agent 并行，独立任务数量不设上限；先查找并调用相关 skill 执行任务，若找不到，再到项目根目录的 .claude/skills/ 下查找。本次不使用 worktree 方式开发。

若存在关键但不清晰的问题，先与我确认，但在此之前，先给出 3 版方案。对每个方案，不仅评估直接效果，还要推演二阶、三阶影响，尤其关注对其他模块、用户行为、系统复杂度和长期维护成本的潜在影响；并参考类似方案，以跨领域视角寻找最优解。随后做反向检验：先假设你认为最合理的方案是错误的，站在最强反对者角度寻找能推翻它的证据、反例和边界情况，再重新评估是否有更好的解法。

在你的自决授权范围内，自行制定方案并解决问题：自主规划任务，充分推敲方案细节，确保不出现偏差和错误；未完成就继续推进，直到所有任务完成。需要决策时，自我驱动给出最合理的决策；确实无法自行定夺时再询问我。

