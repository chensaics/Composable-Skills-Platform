---
name: csp-data
description: >
  Data entry hub — routes SQL queries, data analysis (pandas/scikit-learn),
  BI dashboards, and ETL pipeline requests to the correct sub-skill.
  Keywords: SQL, data science, pandas, BI, ETL, BigQuery, dbt, 数据分析, 查询.
version: "0.1.0"
layer: 3
category: patterns
type: workflow
phase: build
domain: patterns
role: orchestrator
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-data-analysis
  - csp-sql-reviewer
  - csp-db-performance
  - csp-data-pipeline-patterns
---

# csp-data · 数据入口

数据分析的入口 hub — 根据用户意图分发到正确的 data 子技能。

## When to Use

- ✅ 写 SQL 查询 / 优化索引
- ✅ 数据分析 (pandas / polars / scikit-learn)
- ✅ BI 仪表盘 / 可视化
- ✅ ETL 管道 (Airflow / dbt)
- ❌ 数据库 schema 设计 → `csp-code` (csp-postgres-patterns)

## Routing

| 用户意图 | route to |
|---------|----------|
| SQL 查询 / 优化 | `csp-sql-reviewer` |
| 数据分析 | `csp-data-analysis` |
| 可视化 / BI | `csp-chart` / 外部工具 (Tableau/Metabase) |
| 数据管道 / ETL | `csp-data-pipeline-patterns` |
| DB schema / 迁移 | `csp-postgres-patterns` / `csp-db-migration` |

## Quick Check

```bash
# 数据库是否可达
python3 -c "
import os
db = os.getenv('DATABASE_URL', 'postgresql://localhost:5432/postgres')
try:
    from sqlalchemy import create_engine
    e = create_engine(db)
    with e.connect() as c:
        print(f'DB: OK ({c.execute(\"SELECT 1\").scalar()})')
except Exception as ex:
    print(f'DB: unreachable ({ex})')
"

# dbt 是否可用
dbt --version 2>&1 | head -1
```