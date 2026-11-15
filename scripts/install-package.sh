#!/bin/bash
# CSP 子包独立安装脚本 (v0.1.0)
# 
# 用法: ./install.sh csp-quality
#  或: ./install.sh --list  查看所有可用子包
#
# 每个子包的结构:
#   <pkg>-meta/ <pkg>-workflow/ <pkg>-patterns/ <pkg>-runtime/
#   + csp-meta/ (自动安装基座)
#
# 安装目标: .claude/skills/ 或 $CSP_INSTALL_DIR

set -euo pipefail

PKG="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_ROOT="$SCRIPT_DIR"
TARGET="${CSP_INSTALL_DIR:-$HOME/.claude/skills}"

# ── 已注册的子包 ────────────────────────────────────────────
declare -A PACKAGES=(
  ["csp-code"]="code-skills-package 编程全链路 (550+ skills)"
  ["csp-quality"]="quality 测试/安全/CR"
  ["csp-devops"]="devops CI/CD/K8s/云部署"
  ["csp-data"]="data 数据分析/SQL/BI"
  ["csp-design"]="design UI/UX/品牌/3D"
  ["csp-creator"]="creator 短视频/写作/自媒体"
  ["csp-automation"]="automation 无代码/工作流/webhook"
  ["csp-business"]="business 营销/电商/金融"
  ["csp-product"]="product PRD/路线图/Spec"
  ["csp-workspace"]="workspace 项目管理/知识库/IM"
  ["csp-other"]="other 教育/科研/法律/生活"
)

# ── 子包→目录映射 ────────────────────────────────────────────
declare -A PKG_DIRS=(
  ["csp-code"]="packages/csp-code/csp-meta packages/csp-code/csp-workflow packages/csp-code/csp-patterns packages/csp-code/csp-runtime csp-router"
  ["csp-quality"]="packages/csp-quality/meta packages/csp-quality/workflow packages/csp-quality/patterns packages/csp-quality/runtime"
  ["csp-devops"]="packages/csp-devops/meta packages/csp-devops/workflow packages/csp-devops/patterns packages/csp-devops/runtime"
  ["csp-data"]="packages/csp-data/meta packages/csp-data/workflow packages/csp-data/patterns packages/csp-data/runtime"
  ["csp-workspace"]="packages/csp-workspace/meta packages/csp-workspace/workflow packages/csp-workspace/patterns packages/csp-workspace/runtime"
  ["csp-creator"]="packages/csp-creator/meta packages/csp-creator/workflow packages/csp-creator/patterns packages/csp-creator/runtime"
  ["csp-business"]="packages/csp-business/meta packages/csp-business/workflow packages/csp-business/patterns packages/csp-business/runtime"
)

# ── --list 模式 ───────────────────────────────────────────────
if [[ "$PKG" == "--list" ]]; then
  echo "CSP 可用子包:"
  for pkg in "${!PACKAGES[@]}"; do
    printf "  %-18s %s\n" "$pkg" "${PACKAGES[$pkg]}"
  done
  echo ""
  echo "一键安装: $0 <package-name>"
  echo "示例: $0 csp-quality"
  exit 0
fi

# ── 验证子包名 ───────────────────────────────────────────────
if [[ -z "${PACKAGES[$PKG]:-}" ]]; then
  echo "❌ 未识别子包名: '$PKG'"
  echo "   可用: ${!PACKAGES[*]}"
  echo "   使用 --list 查看详情"
  exit 1
fi

# ── 安装 ──────────────────────────────────────────────────────
echo "📦 安装 $PKG — ${PACKAGES[$PKG]}"
echo "   源: $SOURCE_ROOT"
echo "   目标: $TARGET"

mkdir -p "$TARGET"

# 安装子包的目录
dirs="${PKG_DIRS[$PKG]:-}"
copied=0
for dir in $dirs; do
  src="$SOURCE_ROOT/$dir"
  dst="$TARGET/$dir"
  if [[ -d "$src" ]]; then
    echo "   cp $dir/"
    cp -r "$src" "$dst" 2>/dev/null && copied=$((copied + 1))
  else
    echo "   ⚠️  $dir/ 不存在于源码中（跳过）"
  fi
done

# 安装 csp-meta 基座（所有子包共享）
if [[ "$PKG" != "csp-code" ]]; then
  for meta_dir in csp-router csp-meta; do
    src="$SOURCE_ROOT/$meta_dir"
    dst="$TARGET/$meta_dir"
    if [[ -d "$src" ]]; then
      echo "   cp $meta_dir/ (meta 基座)"
      cp -r "$src" "$dst" 2>/dev/null
    fi
  done
fi

echo "✅ $PKG 安装完成 ($copied 个目录)"
echo ""
echo "后续步骤："
echo "  在你的项目 CLAUDE.md 中添加:"
echo "  '使用 CSP (Code Skills Package) 技能包。'"
echo ""
echo "  npx skills add maythyai/code-skills-package  # 全量安装（或单独子包）"