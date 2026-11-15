---
name: csp-devops-seed
description: >
  Use when deploying, configuring CI/CD, managing containers/K8s, or setting
  up monitoring. Covers GitHub Actions, Docker, K8s, AWS/GCP/阿里云 CLI.
  Keywords: deploy, CI/CD, Docker, K8s, kubectl, GitHub Actions, 部署, 运维.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: devops
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# DevOps Seed

部署和运维的入口 — 快速路由到正确的 devops 子技能。

## When to Use

- ✅ 配置 CI/CD pipeline
- ✅ 容器化 / K8s 部署
- ✅ 云服务配置 (AWS/GCP/阿里云)
- ✅ 监控告警设置
- ❌ 纯编码 → `csp-code`

## Routing

| 用户意图 | route to |
|---------|----------|
| CI/CD pipeline | `csp-cicd-pipelines` |
| Docker / K8s | `csp-docker-patterns` / `csp-kubernetes-patterns` |
| 云部署 | `csp-deployment` |
| 监控 | `csp-monitoring-alerting` |
| CLI 工具 | 直接使用 `kubectl` / `aws` / `gcloud` / `terraform` |

## Quick Check

```bash
# CI 是否可用
gh run list --limit 1 2>&1 | grep -q "completed" && echo "CI: OK"

# Docker 是否可用
docker ps 2>&1 | head -1

# K8s 集群是否可达
kubectl cluster-info 2>&1 | head -1
```