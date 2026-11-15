#!/usr/bin/env bash
# sync-reference-projects.sh — clone or update CSP's upstream reference projects
#
# Examples:
#   ./scripts/sync-reference-projects.sh
#   ./scripts/sync-reference-projects.sh --clone-only
#   ./scripts/sync-reference-projects.sh --status
#   ./scripts/sync-reference-projects.sh --target "$HOME/csp-reference-projects" --clone-only
#
# The script is safe to rerun: missing projects are cloned and existing projects
# are updated with fast-forward-only pulls. Use --target when running a copied or
# piped version of the script outside the code-skills-package repository.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-reference-projects.sh [MODE] [--target DIR]

Clone or update the open-source projects used as CSP design references.

Modes (choose at most one):
  --clone-only       Clone missing projects; do not update existing projects.
  --status           Show local clone/tracking status without fetching or pulling.
  -h, --help         Show this help text.

Options:
  --target DIR       Store repositories in DIR. Defaults to
                     <code-skills-package>/开源项目参考 when run from this repo,
                     otherwise $PWD/开源项目参考.

Without a mode, the script clones missing projects and runs `git pull --ff-only`
for clean existing projects. Repositories with local changes are never pulled.

Standalone example:
  curl -fsSL \
    https://raw.githubusercontent.com/maythyai/code-skills-package/master/scripts/sync-reference-projects.sh \
    | bash -s -- --target "$HOME/csp-reference-projects" --clone-only

One registered repository is private and uses an SSH URL. Configure GitHub SSH
access on a new machine before running if you need that repository too.
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 2
}

resolve_default_target() {
  local source_path script_dir project_root
  source_path="${BASH_SOURCE[0]:-$0}"

  case "$source_path" in
    /dev/fd/*|/proc/*/fd/*|-|bash)
      ;;
    *)
      if [ -f "$source_path" ]; then
        script_dir="$(cd "$(dirname "$source_path")" && pwd)"
        project_root="$(cd "${script_dir}/.." && pwd)"
        if [ -f "${project_root}/package.json" ] \
          && grep -Eq '"name"[[:space:]]*:[[:space:]]*"code-skills-package"' "${project_root}/package.json"; then
          printf '%s/开源项目参考\n' "$project_root"
          return
        fi
      fi
      ;;
  esac

  printf '%s/开源项目参考\n' "$PWD"
}

MODE="pull"
MODE_SET=false
REFS_DIR=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --clone-only)
      [ "$MODE_SET" = false ] || fail "only one mode may be specified"
      MODE="clone-only"
      MODE_SET=true
      ;;
    --status)
      [ "$MODE_SET" = false ] || fail "only one mode may be specified"
      MODE="status"
      MODE_SET=true
      ;;
    --target)
      shift
      [ "$#" -gt 0 ] || fail "--target requires a directory"
      [ -n "$1" ] || fail "--target cannot be empty"
      REFS_DIR="$1"
      ;;
    --target=*)
      REFS_DIR="${1#--target=}"
      [ -n "$REFS_DIR" ] || fail "--target cannot be empty"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1 (use --help for usage)"
      ;;
  esac
  shift
done

command -v git >/dev/null 2>&1 || fail "git is required but was not found in PATH"

if [ -z "$REFS_DIR" ]; then
  REFS_DIR="$(resolve_default_target)"
fi
mkdir -p "$REFS_DIR"
REFS_DIR="$(cd "$REFS_DIR" && pwd)"

# Project registry: "local-directory|canonical-git-url"
#
# The seven projects acknowledged in the root README are all represented here.
# Several old README links now return no repository; their current canonical
# locations are used below. See docs/reference/UPSTREAM-PROJECTS.md for the
# source map, provenance notes, and CSP optimization opportunities.
PROJECTS=(
  # README core sources
  "agency-agents|https://github.com/msitarzewski/agency-agents.git"
  "awesome-copilot|https://github.com/github/awesome-copilot.git"
  "ECC|https://github.com/affaan-m/ECC.git"
  "get-shit-done|https://github.com/gsd-build/get-shit-done.git"
  "oh-my-claudecode|https://github.com/Yeachan-Heo/oh-my-claudecode.git"
  "spec-kit|https://github.com/github/spec-kit.git"
  "superpowers|https://github.com/obra/superpowers.git"

  # Additional projects retained for comparison and skill optimization
  "agent-skills|https://github.com/addyosmani/agent-skills.git"
  "BMAD-METHOD|https://github.com/bmad-code-org/BMAD-METHOD.git"
  "claude-skills|https://github.com/alirezarezvani/claude-skills.git"
  "claude-standard-dev-team|https://github.com/xuanbingbingo/claude-standard-dev-team.git"
  "coding-skill-orchestrator|git@github.com:chensaics/coding-skill-orchestrator.git"
  "comet|https://github.com/rpamis/comet.git"
  "compound-engineering-plugin|https://github.com/EveryInc/compound-engineering-plugin.git"
  "impeccable|https://github.com/pbakaus/impeccable.git"
)

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  RED=''
  CYAN=''
  NC=''
fi

CLONED=0
PULLED=0
UP_TO_DATE=0
FAILED=0
SKIPPED=0

printf '%b\n' "${CYAN}=== Reference Projects Sync ===${NC}"
printf 'Target: %s\n' "$REFS_DIR"
printf 'Mode:   %s\n\n' "$MODE"

for entry in "${PROJECTS[@]}"; do
  dir_name="${entry%%|*}"
  repo_url="${entry#*|}"
  target="${REFS_DIR}/${dir_name}"

  if [ -e "$target" ] && [ ! -d "${target}/.git" ]; then
    printf '%b\n' "  ${RED}FAIL${NC} ${dir_name} — target exists but is not a Git repository"
    FAILED=$((FAILED + 1))
    continue
  fi

  if [ -d "${target}/.git" ]; then
    actual_origin="$(git -C "$target" remote get-url origin 2>/dev/null || true)"
    if [ -n "$actual_origin" ] && [ "$actual_origin" != "$repo_url" ]; then
      printf '%b\n' "  ${YELLOW}WARN${NC} ${dir_name} — origin differs: ${actual_origin}"
    fi

    if [ "$MODE" = "clone-only" ]; then
      printf '%b\n' "  ${YELLOW}SKIP${NC} ${dir_name} (already exists)"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    if [ "$MODE" = "status" ]; then
      branch="$(git -C "$target" branch --show-current 2>/dev/null || true)"
      head="$(git -C "$target" rev-parse --short HEAD 2>/dev/null || printf '?')"
      dirty="$(git -C "$target" status --porcelain 2>/dev/null || true)"
      behind="$(git -C "$target" rev-list --count HEAD..@{upstream} 2>/dev/null || printf '?')"
      ahead="$(git -C "$target" rev-list --count @{upstream}..HEAD 2>/dev/null || printf '?')"
      state="clean"
      [ -z "$dirty" ] || state="local changes"
      [ -n "$branch" ] || branch="detached"
      printf '  %-5s %s (%s@%s, ahead=%s, behind=%s)\n' "OK" "$dir_name" "$branch" "$head" "$ahead" "$behind"
      if [ "$state" != "clean" ]; then
        printf '%b\n' "        ${YELLOW}${state}${NC}"
      fi
      UP_TO_DATE=$((UP_TO_DATE + 1))
      continue
    fi

    if [ -n "$(git -C "$target" status --porcelain 2>/dev/null || true)" ]; then
      printf '%b\n' "  ${YELLOW}SKIP${NC} ${dir_name} (local changes; refusing to pull)"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    before="$(git -C "$target" rev-parse HEAD)"
    if pull_out="$(git -C "$target" pull --ff-only 2>&1)"; then
      after="$(git -C "$target" rev-parse HEAD)"
      if [ "$before" != "$after" ]; then
        new_count="$(git -C "$target" rev-list --count "${before}..${after}")"
        printf '%b\n' "  ${GREEN}PULL${NC} ${dir_name} (+${new_count} commits)"
        git -C "$target" log --oneline -5 "${before}..${after}" | while IFS= read -r line; do
          printf '        %s\n' "$line"
        done
        PULLED=$((PULLED + 1))
      else
        printf '%b\n' "  ${GREEN}OK${NC}   ${dir_name} (already up to date)"
        UP_TO_DATE=$((UP_TO_DATE + 1))
      fi
    else
      printf '%b\n' "  ${RED}FAIL${NC} ${dir_name} — pull failed: $(printf '%s\n' "$pull_out" | tail -n 1)"
      FAILED=$((FAILED + 1))
    fi
    continue
  fi

  if [ "$MODE" = "status" ]; then
    printf '%b\n' "  ${RED}MISS${NC} ${dir_name} (not cloned)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  printf '  CLONE %s ... ' "$dir_name"
  if clone_out="$(git clone --depth 1 -- "$repo_url" "$target" 2>&1)"; then
    printf '%b\n' "${GREEN}OK${NC}"
    CLONED=$((CLONED + 1))
  else
    printf '%b\n' "${RED}FAIL${NC}"
    printf '        %s\n' "$(printf '%s\n' "$clone_out" | tail -n 1)"
    FAILED=$((FAILED + 1))
  fi
done

printf '\n%b\n' "${CYAN}--- Summary ---${NC}"
printf '  Cloned:    %s\n' "$CLONED"
printf '  Pulled:    %s\n' "$PULLED"
printf '  Available: %s\n' "$UP_TO_DATE"
printf '  Skipped:   %s\n' "$SKIPPED"
printf '  Failed:    %s\n' "$FAILED"

printf '\n%b\n' "${CYAN}Unregistered directories (not modified):${NC}"
found_unregistered=false
for directory in "$REFS_DIR"/*/; do
  [ -d "$directory" ] || continue
  name="$(basename "$directory")"
  registered=false
  for entry in "${PROJECTS[@]}"; do
    if [ "${entry%%|*}" = "$name" ]; then
      registered=true
      break
    fi
  done
  if [ "$registered" = false ]; then
    printf '  - %s\n' "$name"
    found_unregistered=true
  fi
done
[ "$found_unregistered" = true ] || printf '  (none)\n'

printf '\nDone.\n'
[ "$FAILED" -eq 0 ] || exit 1
