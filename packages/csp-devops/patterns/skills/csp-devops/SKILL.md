---
name: csp-devops
description: >
  DevOps entry hub — routes CI/CD, container/K8s, cloud deployment, and monitoring
  requests to the correct sub-skill. Use when deploying, configuring CI/CD, managing
  Docker/K8s, or setting up cloud monitoring.
  Keywords: deploy, CI/CD, Docker, K8s, kubectl, GitHub Actions, cloud, 部署, 运维.
version: "0.1.0"
layer: 3
category: patterns
type: workflow
phase: build
domain: devops
role: orchestrator
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-cicd-pipelines
  - csp-deployment
  - csp-docker-patterns
  - csp-kubernetes-patterns
  - csp-monitoring-alerting
---

# csp-devops · DevOps 入口

部署和运维的入口 hub — 根据用户意图分发到正确的 devops 子技能。

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