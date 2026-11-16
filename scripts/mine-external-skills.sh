#!/usr/bin/env bash
set -euo pipefail

# mine-external-skills.sh — 批量 clone 外部 Agent Skills 仓库，分析结构，输出挖掘报告
#
# 用法:
#   ./scripts/mine-external-skills.sh                         # 全部 clone + 分析
#   ./scripts/mine-external-skills.sh --dry-run               # 只列名单，不 clone
#   ./scripts/mine-external-skills.sh --repo mattpocock/skills  # 只分析指定仓库
#   ./scripts/mine-external-skills.sh --report-only           # 不重新 clone，只生成报告
#
# 输出:
#   .csp/external-skills/{repo}/*     — 克隆的仓库
#   .csp/external-skills/REPORT.md    — 挖掘报告

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly MINE_DIR="${SCRIPT_DIR}/.csp/external-skills"
readonly REPORT="${MINE_DIR}/REPORT-$(date +%Y%m%d).md"

# ── 挖掘目标仓库清单 ──────────────────────────────────────────
# 格式: "owner/repo | 分类 | 优先级(1-5) | 简介"
# 分类对应 CSP federation 包: programming/quality/security/devops/
#   data/design/creator/automation/business/product/workspace/other
# 来源: GitHub topics: agent-skills, claude-skills, codex-skills,
#   skills.sh trending, awesome-agent-skills 合集, 社区搜索

readonly TARGETS=(
  # ═══ Programming · 编程 (13 repos) ═══
  "mattpocock/skills|programming|5|TypeScript 工程技能(119K stars). 21 skills: TDD/PRD/设计/Git安全"
  "anthropics/skills|programming|5|Anthropic 官方技能(189K stars). docx/pptx/xlsx/pdf/mcp-builder"
  "obra/superpowers|programming|5|SDLC 技能系统(317K stars). 20+ composable skills"
  "vercel-labs/agent-skills|programming|4|Vercel 官方: React/Next.js 最佳实践"
  "apify/agent-skills|programming|4|Web scraping+automation skills. 130+ curated Actors"
  "sickn33/agentic-awesome-skills|programming|4|2,955+ reusable skills 合集. CLI/MCP/plugins"
  "EmilKowalski/skill|programming|3|全栈审美: 设计+动效+代码+性能"
  "imsai-sh/skills|programming|3|worktree 三件套 + iOS ICP filing + 火山引擎 RTC"
  "GoogleChrome/modern-web-guidance|programming|3|Chrome 团队: 现代 Web 最佳实践(7.2K stars)"
  "solana-foundation/solana-dev-skill|programming|3|Solana 链上开发技能"
  "new-silvermoon/awesome-android-agent-skills|programming|3|Android 开发技能(Kotlin/Compose)"
  "lennney/gate-all-skills|programming|3|前端/Next.js 技能合集"
  "golang-collection/go-modern-guidelines|programming|3|Go 现代编码规范(2.6K stars)"

  # ═══ Quality · 测试/安全/代码质量 (6 repos) ═══
  "cloudflare/security-audit-skill|quality|5|六阶段安全审计(65K stars). 隔离猎手+对抗验证"
  "TrailOfBits/skills|quality|4|安全审计技能(26 skills). building-secure-contracts/static-analysis"
  "sentry/skills|quality|4|Sentry 官方: code-review/commit/create-pr/find-bugs"
  "UseAI-pro/openclaw-skills-security|quality|3|安全扫描: prompt injection/supply chain/credential leaks"
  "buainoai/awesome-clawdbot-skills|quality|3|565+ Clawdbot 社区技能合集(安全扫描)"
  "bruc3van/agent-skills-guard|quality|3|Agent Skills 安全扫描器+Rust桌面管理"

  # ═══ DevOps · 部署/CI/CD/云 (3 repos) ═══
  "cloudflare/agent-skills|devops|4|Cloudflare Workers/Pages/Durable Objects"
  "neondatabase/skills|devops|3|Neon Serverless Postgres 集成"
  "tinybirdco/skills|devops|3|Tinybird 实时数据分析管道"

  # ═══ Data · 数据分析/SQL/BI (4 repos) ═══
  "K-Dense-AI/scientific-agent-skills|data|5|165 科研技能(190K+ users). 100+科学数据库"
  "brycewang-stanford/Auto-Research-Skills|data|4|自主科研: 从灵感到论文全自动(21 projects)"
  "leanjialuyao-dev/AcademicForge|data|4|学术写作技能集成. 论文润色/翻译/排版"
  "ClickHouse/skills|data|3|ClickHouse 分析数据库技能"

  # ═══ Design · 设计 (5 repos) ═══
  "Nutlope/hallmark|design|5|AI 设计技能(51K stars). 设计稿→代码"
  "nextlevelbuilder/ui-ux-pro-max-skill|design|4|视觉层级×色彩心理学×交互模式"
  "tt-a1i/archify|design|4|架构图自动生成(27K stars). Mermaid/流程图"
  "motiful/product-shots|design|3|电商视觉: 产品图→全套 e-commerce visuals"
  "emilkowalski/skill|design|3|设计驱动开发: 动效+性能+审美"

  # ═══ Creator · 内容创作 (8 repos) ═══
  "ConardLi/garden-skills|creator|4|创作与知识处理(11K stars). 文章/图像/网页/PPT"
  "alchaincyf/huashu-skills|creator|4|内容创作21合1(30万粉博主). 选题/PPT/审校/短视频"
  "lijigang/ljg-skills|creator|4|写作思考认知工具箱. plain/learn/read/card/think"
  "Remotion/skills|creator|3|Remotion 视频编辑技能(React编程生成视频)"
  "storytold/craft-anything|creator|3|网站→代码: 分析任意网站生成可编译项目(29K stars)"
  "kostja94/marketing-skills|creator|3|营销技能(160+): SEO/内容/40+page types/付费广告"
  "echohaoran/AI-AGENT-Skills|creator|3|办公生产力: Office/WPS/PDF/浏览器自动化"
  "imsai-sh/skills-hackernews|creator|2|HackerNews Show HN 提交技能"

  # ═══ Automation · 工具与自动化 (3 repos) ═══
  "firecrawl/skills|automation|4|Firecrawl 网页抓取+数据提取"
  "ComposioHQ/skills|automation|3|Composio 工具集成平台(Tool-as-a-Service)"
  "VintLin/skill-flow|automation|3|跨平台 skill 管理器(Claude/Cursor/Copilot)"

  # ═══ Business · 商业 (5 repos) ═══
  "Eronred/aso-skills|business|4|ASO 应用商店优化. 关键词/元数据/竞品分析"
  "stripe/agent-skills|business|4|Stripe 官方: 支付/订阅集成最佳实践"
  "Nexscope/eCommerce-Skills|business|3|Amazon/eCommerce 技能合集"
  "Typefully/skills|business|3|Typefully: X/Twitter 内容创作与数据分析"
  "Sanity-io/skills|business|3|Sanity CMS 内容管理集成"

  # ═══ Product · 产品管理 (2 repos) ═══
  "better-auth/skills|product|3|Better Auth: 认证/授权最佳实践"
  "cursor/plugins|product|3|Cursor 官方插件目录(4K stars)"

  # ═══ Workspace · 工作套件/效率 (5 repos) ═══
  "thedotmack/claude-mem|workspace|5|跨会话记忆(114K stars). 压缩+注入+持久化"
  "paperclipai/paperclip|workspace|4|Agent 工作管理: multi-agent/project/编排"
  "Egonex-AI/Understand-Anything|workspace|4|代码知识图谱: 可搜索/可提问/可探索"
  "claude-obsidian/skills|workspace|3|Claude ↔ Obsidian 双向同步(14K stars)"
  "jackfrued/awesome-agent-skills|workspace|3|1000+ 精品技能合集. 手选非AI生成"

  # ═══ Other · 其他/跨域 (6 repos) ═══
  "Donchitos/Claude-Code-Game-Studios|other|4|49 Agent+72 Skills 游戏开发多智能体"
  "nvidia/skills|other|4|NVIDIA 官方: Physical AI/机器人/仿真/CUDA/RAG"
  "aAAaqwq/AGI-Super-Team|other|3|跨框架 AI 组织: C-suite agents+expert subagents(837 skills)"
  "expo/skills|other|3|Expo 官方: React Native 移动开发"
  "huggingface/skills|other|3|Hugging Face: model-trainer/datasets/evaluation/jobs"
  "google/labs-skills|other|3|Google Labs: design-md/react-components"

  # ═══ Awesome 合集 · 发现平台 (6 repos) ═══
  "VoltAgent/awesome-agent-skills|discovery|5|1000+ 精品合集. 官方+社区. 手选非AI生成"
  "JackyST0/awesome-agent-skills|discovery|5|AI Agent Skills 发现平台(install.sh一键装)"
  "helloianneo/awesome-claude-code-skills|discovery|4|50+精选. 按场景分类. 带推荐等级"
  "subinium/awesome-claude-code|discovery|4|Claude Code 工具/技能/插件/MCP 精选"
  "michielhdoteth/awesome-ai-agent-tools|discovery|4|AI agent 工具全栈: skills/MCP/loops/hooks/plugins"
  "mantoufan/behi-acs|discovery|3|Awesome Claude Skills: 按域分类收录"
)

readonly DRY_RUN="${1:-}"
readonly SINGLE_REPO="${2:-}"

# ── 工具函数 ──────────────────────────────────────────────────

log()  { echo "  $*"; }
h1()   { echo ""; echo "## $*"; echo ""; }
ok()   { echo "  ✅ $*"; }
warn() { echo "  ⚠️  $*"; }
skip() { echo "  ⏭️  $*"; }

# 分析单个仓库的结构
analyze_repo() {
  local repo_dir="$1"
  local repo_name="$2"
  local category="$3"

  log "分析: $repo_name"

  # 基本统计
  local skill_count=$(find "$repo_dir" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  local script_count=$(find "$repo_dir" -path "*/scripts/*" -type f 2>/dev/null | wc -l | tr -d ' ')
  local ref_count=$(find "$repo_dir" -path "*/references/*" -type f 2>/dev/null | wc -l | tr -d ' ')
  local md_count=$(find "$repo_dir" -name "*.md" -type f ! -name "SKILL.md" ! -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')

  # 技能名列表
  local skill_names=""
  while IFS= read -r skill_file; do
    local dir_name=$(basename "$(dirname "$skill_file")")
    skill_names="$skill_names $dir_name"
  done <<< "$(find "$repo_dir" -name "SKILL.md" -type f 2>/dev/null)"

  # 目录结构（top 3 levels）
  local dir_tree
  dir_tree=$(cd "$repo_dir" && find . -maxdepth 2 -type d ! -path './.git/*' ! -path './.git' 2>/dev/null | sort | head -20 | sed 's/^/      /')

  # 安装方式
  local install_hint=""
  if grep -q "npx skills" "$repo_dir/README.md" 2>/dev/null; then
    install_hint="npx skills add $repo_name"
  elif grep -q "plugin marketplace" "$repo_dir/README.md" 2>/dev/null; then
    install_hint="/plugin marketplace add $repo_name"
  fi

  # 写入报告
  cat >> "$REPORT" <<EOF

### $repo_name

| 属性 | 值 |
|------|-----|
| 分类 | $category |
| Skills 数 | $skill_count |
| 脚本数 | $script_count |
| 参考文档数 | $ref_count |
| Markdown 数 | $md_count |
| 安装方式 | ${install_hint:-手动 clone} |
| 技能列表 | ${skill_names:-无} |

**目录结构**:
\`\`\`
$dir_tree
\`\`\`

**CSP 可借鉴点**:
<!-- 待分析后填写 -->

EOF
}

# 提取 CSP 可借鉴模式
extract_patterns() {
  local repo_dir="$1"
  local repo_name="$2"

  # 检查是否有双类型 invocation 模式
  if grep -rq "user-invoked\|model-invoked\|User-invoked\|Model-invoked" "$repo_dir" 2>/dev/null; then
    echo "    - [invocation] 双类型调用模式 (user-invoked / model-invoked)"
  fi

  # 检查是否有对抗验证模式
  if grep -rq "adversar\|verify.*finding\|verify.*candidate" "$repo_dir" 2>/dev/null; then
    echo "    - [verification] 对抗验证模式"
  fi

  # 检查是否有领域语言/上下文提取
  if grep -rq "ubiquitous.language\|CONTEXT.md\|domain.*language" "$repo_dir" 2>/dev/null; then
    echo "    - [context] 领域语言/上下文提取模式"
  fi

  # 检查 skill 分发/安装机制
  if [ -d "$repo_dir/.claude-plugin" ] || grep -q "marketplace" "$repo_dir/README.md" 2>/dev/null; then
    echo "    - [distribution] Claude Code Marketplace 分发"
  fi
  if grep -q "npx skills" "$repo_dir/README.md" 2>/dev/null; then
    echo "    - [distribution] npx skills 安装通道"
  fi

  # 检查多 agent 并行模式
  if grep -rq "parallel\|spawn.*agent\|subagent" "$repo_dir" --include="*.md" 2>/dev/null | head -5 >/dev/null; then
    echo "    - [multi-agent] 多 Agent 并行/编排模式"
  fi

  # 检查是否有 TDD 模式
  if grep -rq "red.*green.*refactor\|test.*first\|tdd" "$repo_dir" --include="*.md" -i 2>/dev/null | head -3 >/dev/null; then
    echo "    - [tdd] TDD 驱动模式"
  fi
}

# ── 主流程 ────────────────────────────────────────────────────

main() {
  mkdir -p "$MINE_DIR"

  # 报告头部
  cat > "$REPORT" <<EOF
# 外部 Agent Skills 挖掘报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')
分析仓库: ${#TARGETS[@]} 个（覆盖 12 个 CSP 领域 + 6 个发现平台）

---

EOF

  local total=0
  local cloned=0
  local analyzed=0

  for target in "${TARGETS[@]}"; do
    IFS='|' read -r repo category priority desc <<< "$target"
    total=$((total + 1))

    local repo_dir="$MINE_DIR/${repo/\//_}"
    local repo_url="https://github.com/${repo}.git"

    h1 "[$priority/5] $repo — $desc"

    # 跳过条件
    if [ -n "${SINGLE_REPO:-}" ] && [ "$repo" != "$SINGLE_REPO" ]; then
      skip "跳过 (非目标仓库)"
      continue
    fi

    if [ "$DRY_RUN" = "--dry-run" ]; then
      log "预览: $repo → $repo_dir ($desc)"
      continue
    fi

    # Clone
    if [ -d "$repo_dir/.git" ]; then
      log "已存在，更新..."
      git -C "$repo_dir" pull --ff-only origin HEAD 2>/dev/null || warn "更新失败，使用现有版本"
    else
      log "克隆: $repo_url"
      if git clone --depth 1 "$repo_url" "$repo_dir" 2>/dev/null; then
        ok "克隆完成"
        cloned=$((cloned + 1))
      else
        warn "克隆失败 (网络不可达或仓库不存在)"
        echo "### $repo — ⚠️ 克隆失败" >> "$REPORT"
        continue
      fi
    fi

    # 分析
    analyze_repo "$repo_dir" "$repo" "${category:-unknown}"
    analyzed=$((analyzed + 1))

    # 提取可借鉴模式
    echo "" >> "$REPORT"
    echo "**CSP 可借鉴模式**:" >> "$REPORT"
    extract_patterns "$repo_dir" "$repo" >> "$REPORT"

  done

  # 报告尾部
  cat >> "$REPORT" <<EOF

---

## 挖掘统计

| 指标 | 数值 |
|------|------|
| 目标仓库 | $total |
| 成功克隆 | $cloned |
| 分析完成 | $analyzed |
| 识别模式 | 见各仓库详情 |

## 下一步

1. 逐一审查每个仓库的 "CSP 可借鉴点"
2. 使用 [[workflow:csp-skill-distiller]] 进行深度蒸馏
3. 按 CSP v3 规范改写可集成内容
4. 注册到 federation.yaml 对应包
EOF

  echo ""
  echo "═══ 挖掘完成 ═══"
  echo "  报告: $REPORT"
  echo "  仓库: $MINE_DIR"
  echo "  克隆: $cloned / 分析: $analyzed / 总计: $total"
  echo ""
}

main "$@"