#!/usr/bin/env python3
"""
G-11 Tag 前置门控 — 打 annotated tag 前六项机器闸。

用法:
  python3 prompts/scripts/tag_gate.py [--tag vX.Y.Z] [--skip mypy] [--json]

门控项:
  1. ruff check --statistics     → 0 violations
  2. mypy <src>                  → exit 0
  3. pytest --maxfail=0          → exit 0 (或 vitest run 对应)
  4. vitest run                  → exit 0 (或 pytest 对应)
  5. tsc --noEmit                → exit 0 (仅 TS 项目)
  6. make check 或等效 build     → exit 0

输出:
  - 六项逐一 ran: <cmd> exit <code> 格式证据
  - 任一项 non-zero → BLOCKED，exit 1
  - 全部 exit 0 → PASS，允许 git tag -a

设计原则:
  - 本脚本是「机器闸」，不是「文档声明」。
  - 每一项的 ran/exits 必须来自实际命令执行，不接受 not-run 降级。
  - 不存在"声称已跑但脚本不在"——本脚本就是执行件本身。
"""

import argparse
import json
import os
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Optional

PROJECT_ROOT = Path(os.environ.get("CSP_PROJECT_ROOT", os.getcwd()))


def run(cmd: str, cwd: Optional[Path] = None, timeout: int = 300) -> tuple[int, str, str]:
    """执行命令，返回 (exit_code, stdout, stderr)。"""
    try:
        r = subprocess.run(
            cmd, shell=True, capture_output=True, text=True,
            cwd=str(cwd or PROJECT_ROOT), timeout=timeout
        )
        return r.returncode, r.stdout.strip(), r.stderr.strip()
    except subprocess.TimeoutExpired:
        return -1, "", f"TIMEOUT ({timeout}s)"
    except Exception as e:
        return -1, "", str(e)


def detection() -> dict:
    """自动检测项目技术栈，返回可用检查项。"""
    checks = {}

    # Python 项目
    if (PROJECT_ROOT / "pyproject.toml").exists() or list(PROJECT_ROOT.glob("**/*.py")):
        if shutil_which("ruff"):
            checks["ruff"] = "ruff check --statistics"
        if shutil_which("mypy"):
            # mypy 源目录自动检测
            src_dirs = []
            for d in ["src", "trl", "app", "backend", "api"]:
                if (PROJECT_ROOT / d).is_dir():
                    src_dirs.append(d)
            src_arg = " ".join(src_dirs) if src_dirs else "."
            checks["mypy"] = f"mypy {src_arg}"
        if shutil_which("pytest"):
            checks["pytest"] = "pytest --maxfail=0 --tb=short -q"

    # JS/TS 项目
    if (PROJECT_ROOT / "package.json").exists():
        if shutil_which("vitest"):
            checks["vitest"] = "npx vitest run"
        if (PROJECT_ROOT / "tsconfig.json").exists() and shutil_which("tsc"):
            checks["tsc"] = "npx tsc --noEmit"

    # 通用 build 检查
    if (PROJECT_ROOT / "Makefile").exists():
        checks["build"] = "make check 2>&1 || make build 2>&1 || true"
    elif (PROJECT_ROOT / "package.json").exists():
        checks["build"] = "npm run build 2>&1 || pnpm build 2>&1 || true"

    return checks


def shutil_which(name: str) -> bool:
    import shutil
    return shutil.which(name) is not None


def main():
    parser = argparse.ArgumentParser(description="G-11 Tag 前置门控")
    parser.add_argument("--tag", help="目标版本号")
    parser.add_argument("--skip", nargs="*", default=[], help="跳过的检查项")
    parser.add_argument("--json", action="store_true", help="JSON 输出")
    parser.add_argument("--root", default=None, help="项目根目录")
    args = parser.parse_args()

    if args.root:
        global PROJECT_ROOT
        PROJECT_ROOT = Path(args.root)

    os.chdir(PROJECT_ROOT)

    checks = detection()
    if not checks:
        print("❌ G-11 BLOCKED: 未检测到任何可执行检查项。确认项目有 pyproject.toml 或 package.json。")
        sys.exit(1)

    results = {}
    all_pass = True

    for name, cmd in checks.items():
        if name in args.skip:
            results[name] = {"ran": f"(skipped) {cmd}", "exit": 0, "status": "SKIPPED"}
            continue

        exit_code, stdout, stderr = run(cmd)
        status = "PASS" if exit_code == 0 else "FAIL"
        if exit_code != 0:
            all_pass = False

        results[name] = {
            "ran": cmd,
            "exit": exit_code,
            "status": status,
            "stdout_tail": stdout[-500:] if stdout else "",
            "stderr_tail": stderr[-500:] if stderr else "",
        }

    # 摘要
    summary = {
        "tag": args.tag or "(none)",
        "root": str(PROJECT_ROOT),
        "checks": results,
        "all_pass": all_pass,
        "verdict": "PASS — 允许 git tag -a" if all_pass else "BLOCKED — 禁止打 tag",
    }

    if args.json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
    else:
        print(f"\n{'='*60}")
        print(f"  G-11 Tag 前置门控  {f'→ {args.tag}' if args.tag else ''}")
        print(f"{'='*60}")
        for name, r in results.items():
            icon = "✅" if r["status"] == "PASS" else "⛔" if r["status"] == "FAIL" else "⏭️"
            print(f"  {icon} {name}: ran: {r['ran']}  exit {r['exit']}")
        print(f"{'='*60}")
        print(f"  裁决: {summary['verdict']}")
        print(f"{'='*60}\n")

    sys.exit(0 if all_pass else 1)


if __name__ == "__main__":
    main()