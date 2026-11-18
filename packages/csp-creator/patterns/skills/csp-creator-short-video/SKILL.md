---
name: csp-creator-short-video
description: >
  Use when creating short videos (抖音/TikTok/YouTube Shorts/Reels/B站).
  Covers storyboarding, scripting, shooting guidelines, editing workflow,
  caption/subtitle generation, and platform-specific optimization.
  Keywords: 短视频, 抖音, TikTok, Shorts, Reels, 剪辑, 拍摄, 字幕, 转场, video editing.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-creator-content-strategy
  - csp-creator-publish-pipeline
  - csp-creator-thumbnail
  - csp-creator-image-prompt
triggers:
  keywords: ["短视频", "抖音", "TikTok", "Shorts", "Reels", "剪辑", "拍摄", "字幕", "转场"]
  intents:
    - "user wants to create a short video"
    - "user needs video editing guidance"
---

# Short Video Creation

AI 驱动的短视频创作——从创意到成片的完整工作流。

## Purpose

帮助创作者用 AI 工具高效完成短视频的全流程：选题→脚本→拍摄→剪辑→字幕→发布。

## When to Use

- ✅ 需要制作短视频内容
- ✅ 需要优化现有视频的剪辑/字幕/节奏
- ✅ 需要批量生成短视频（模板化生产）
- ❌ 长视频/电影级制作（用专业 NLE 工作流）
- ❌ 纯图文内容

## Process

### Step 1: 选题分析（2 min）

基于用户的目标平台和受众，分析热门选题：
- 平台趋势：当前平台的流量热点
- 对标账号：分析竞品账号的爆款模式
- 关键词工具：搜索量/竞争度

**输出**：3-5 个选题方向，含预估流量和制作难度。

### Step 2: 脚本撰写（3 min）

按平台特点撰写脚本结构：
- Hook (0-3s)：第一句话抓住注意力
- Body (3-30s)：核心内容/教程/故事
- CTA (last 3s)：引导互动（点赞/关注/评论）

**适配规则**：
| 平台 | 时长 | 节奏 | 字幕 |
|------|------|------|------|
| 抖音 | 15-60s | 快节奏，3s 一个 hook | 必须中文字幕 |
| TikTok | 15-60s | fast cuts, trending audio | English captions |
| B站 | 1-5min | 有深度，允许长句 | 双语字幕 |

### Step 3: 剪辑指导

生成分镜脚本 + AI 剪辑工具选择：
- **CapCut/剪映**：自动字幕 + 模板 + AI 配音
- **Premiere Pro**：专业调色 + 多轨道
- **DaVinci Resolve**：免费 + 专业色彩

输出分镜表：`场景 | 时长 | 画面描述 | 文案 | BGM`

### Step 4: 发布优化

平台特定的发布优化：
- 标题公式（数字+情绪+悬念）
- 封面图生成（AI 生成或 Canva 模板）
- 发布时间策略
- 标签/话题策略

## Verification Checklist

- [ ] 脚本有明确的 hook（前 3 秒）
- [ ] 字幕已生成并对齐
- [ ] BGM 与内容情绪匹配
- [ ] 封面图已生成
- [ ] 标题含数字或情绪词
- [ ] 标签已优化（5-10 个精准标签）

## Related Skills

- [[csp-creator-content-strategy]] — 内容日历和选题库建设
- [[csp-creator-publish-pipeline]] — 多平台自动发布
- [[csp-creator-auto-publish]] — 定时发布和数据复盘