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
readonly TARGETS=(
  # 编程类
  "mattpocock/skills|programming|5|TypeScript 工程技能(119K stars). 21 skills: TDD/PRD/设计/Git安全"
  "anthropics/skills|programming|5|Anthropic 官方技能示例(189K stars). docx/pptx/xlsx/pdf/mcp-builder"
  "cloudflare/security-audit-skill|security|4|六阶段安全审计(65K stars). 隔离猎手+对抗验证"
  "obra/superpowers|programming|4|SDLC 技能系统(274K stars). 20+ composable skills"
  "vercel-labs/agent-skills|programming|4|Vercel 官方技能: React/Next.js 最佳实践"

  # 创作类
  "Nutlope/hallmark|creator|4|AI 设计技能(51K stars). 设计稿→代码"
  "ConardLi/garden-skills|creator|4|创作与知识处理技能(11K stars). 文章/图像/网页"
  "alchaincyf/huashu-skills|creator|3|内容创作 21合1. 选题/PPT/审校"

  # 商业类
  "Eronred/aso-skills|business|3|ASO 应用商店优化技能"

  # 基础设施
  "thedotmack/claude-mem|infra|4|跨会话记忆(114K stars)"
  "Donchitos/Claude-Code-Game-Studios|infra|3|49 Agent + 72 Skills 多智能体编排"

  # 知识管理
  "lijigang/ljg-skills|knowledge|3|写作思考认知工具箱. plain/learn/read/card/think"
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
分析仓库: ${#TARGETS[@]} 个

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