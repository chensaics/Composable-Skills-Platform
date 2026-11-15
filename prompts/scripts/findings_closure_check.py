#!/usr/bin/env python3
"""
findings 闭合闸门 — 修复「预关闭即回滚」缺陷。

支持 staged-closure 模式：
  在 tag 之前，findings 可以标记为 staged_closed（修复已完成但 tag 未打）。
  打 tag 后，运行本脚本 --promote 将 staged_closed → closed（批量升级）。

用法:
  # tag 前检查：允许 OPEN + STAGED_CLOSED，不允许声称已 closed 但无 tag
  python3 scripts/findings_closure_check.py --baseline .csp/findings-baseline.json

  # tag 后升级：STAGED_CLOSED → CLOSED
  python3 scripts/findings_closure_check.py --promote --tag v6.66.0

输出:
  - exit 0: 通过（或不适用）
  - exit 1: BLOCKED — P0 finding OPEN 或 声称 closed 但 evidence 不满足
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional


def load_json(path: str) -> Optional[dict]:
    try:
        with open(path) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def save_json(path: str, data: dict):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def check_closed(finding: dict, valid_tags: set) -> str | None:
    """检查一条 finding 的 closed 声明是否有效。返回 None=有效，否则返回错误原因。"""
    status = finding.get("status", "OPEN")

    if status in ("OPEN", "DEFERRED"):
        return None  # 未声称 closed，合法

    if status == "STAGED_CLOSED":
        return None  # staged 模式：修复已完成，等 tag 升级

    if status == "CLOSED":
        fixed_in = finding.get("fixed_in", "")
        if not fixed_in:
            return "status=CLOSED 但 fixed_in 为空 — 声称 closed 但无修复版本"
        # fixed_in 可以是 tag 或 commit hash
        if fixed_in.startswith("v") and fixed_in not in valid_tags:
            return f"fixed_in={fixed_in} 不是已存在的 tag — 预关闭禁止（用 STAGED_CLOSED 代替）"
        verification = finding.get("verification", "")
        if not verification:
            return f"status=CLOSED 但 verification 为空 — 缺 file:line/ran+exit/实机截图证据"
        return None

    return f"未知 status={status}"


def main():
    parser = argparse.ArgumentParser(description="findings 闭合闸门")
    parser.add_argument("--baseline", default=".csp/findings-baseline.json", help="豁免基线文件")
    parser.add_argument("--findings-dir", default=".csp/review/", help="findings 目录")
    parser.add_argument("--promote", action="store_true", help="升级 STAGED_CLOSED → CLOSED")
    parser.add_argument("--tag", help="关联的 tag（promote 模式使用）")
    args = parser.parse_args()

    # 收集所有 findings
    findings = []
    findings_dir = Path(args.findings_dir)
    if findings_dir.exists():
        for f in findings_dir.rglob("REVIEW-FINDINGS*.json"):
            data = load_json(str(f))
            if data and isinstance(data, list):
                findings.extend(data)

    if not findings:
        print("✅ No findings to check.")
        sys.exit(0)

    # 加载豁免基线
    baseline = load_json(args.baseline) or {}
    exempt_ids = set(baseline.get("exempt_ids", []))

    # 获取已存在 tag
    import subprocess
    r = subprocess.run("git tag -l 'v*'", shell=True, capture_output=True, text=True)
    valid_tags = set(r.stdout.strip().split("\n")) if r.stdout.strip() else set()
    if args.tag:
        valid_tags.add(args.tag)

    # PROMOTE 模式：STAGED_CLOSED → CLOSED
    if args.promote:
        promoted = 0
        for f in findings:
            if f.get("status") == "STAGED_CLOSED":
                f["status"] = "CLOSED"
                f["fixed_in"] = f.get("fixed_in", args.tag or "unknown")
                f["promoted_at"] = datetime.now(timezone.utc).isoformat()
                promoted += 1

        for f_path in findings_dir.rglob("REVIEW-FINDINGS*.json"):
            data = load_json(str(f_path))
            if data and isinstance(data, list):
                new_data = []
                for item in data:
                    if item.get("id") in {f.get("id") for f in findings if f.get("status") == "CLOSED"}:
                        for f in findings:
                            if f.get("id") == item.get("id"):
                                item.update(f)
                    new_data.append(item)
                save_json(str(f_path), new_data)

        print(f"✅ Promoted {promoted} STAGED_CLOSED → CLOSED (tag: {args.tag})")
        sys.exit(0)

    # CHECK 模式：验证
    errors = []
    p0_open_count = 0
    p1_open_count = 0

    for f in findings:
        fid = f.get("id", "?")
        if fid in exempt_ids:
            continue

        severity = f.get("severity", "P2").upper()
        status = f.get("status", "OPEN")

        if severity.startswith("P0") and status not in ("CLOSED",):
            p0_open_count += 1
            if status != "STAGED_CLOSED":
                errors.append(f"P0 {fid} status={status} — 必须 closed（或 staged_closed）")
        if severity.startswith("P1"):
            p1_open_count += 1

        err = check_closed(f, valid_tags)
        if err:
            errors.append(f"{fid}: {err}")

    # 裁决
    if p0_open_count > 0:
        print(f"⛔ BLOCKED: {p0_open_count} P0 finding(s) not closed.")
        for e in errors:
            print(f"   {e}")
        sys.exit(1)

    if p1_open_count > 3:
        print(f"⛔ BLOCKED: {p1_open_count} P1 finding(s) open (max 3).")
        sys.exit(1)

    if errors:
        print(f"⚠️  WARNING: {len(errors)} evidence issue(s):")
        for e in errors:
            print(f"   {e}")
        # WARNING 不阻断

    staged = sum(1 for f in findings if f.get("status") == "STAGED_CLOSED")
    print(f"✅ Gate passed. P0={p0_open_count} P1={p1_open_count} total={len(findings)} staged={staged}")
    sys.exit(0)


if __name__ == "__main__":
    main()