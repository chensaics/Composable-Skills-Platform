---
name: csp-creator-publish-pipeline
description: >
  Use when publishing content across multiple platforms (抖音/TikTok/小红书/B站/YouTube/
  公众号/X/LinkedIn). Covers format adaptation, scheduling, cross-platform optimization,
  tag/hashtag strategy, and publish-time coordination. Use AFTER content is created and
  ready for distribution. Keywords: 发布, 多平台分发, 一键发布, publish, cross-platform,
  发布时间, 标签策略, hashtag, 多平台发布, distribution.
version: "0.1.0"
layer: 3
category: patterns
type: workflow
phase: ship
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
dependencies:
  skills: [csp-creator-content-strategy]
related_skills:
  - csp-creator-short-video
  - csp-creator-content-strategy
  - csp-creator-auto-publish
  - csp-crosspost
  - csp-content-engine
triggers:
  keywords: ["发布", "多平台", "一键发布", "publish", "cross-platform", "分发",
             "发布时间", "标签策略", "hashtag", "上线", "go live"]
  intents:
    - "user wants to publish content to multiple platforms"
    - "user needs platform-specific publishing guidance"
    - "user wants to schedule content release"
---

# Multi-Platform Publish Pipeline

Coordinate multi-platform content publishing — from format prep to go-live.

## Purpose

Content is made. Now get it everywhere it needs to go — properly adapted, timely, with the right metadata. This skill handles the publish workflow: format checks, platform-specific optimization, tag strategy, timing coordination, and post-publish monitoring.

## When to Use

- ✅ Content is ready and needs multi-platform distribution
- ✅ Need platform-specific publish optimization (hashtags, title, cover)
- ✅ Coordinating a timed launch across platforms
- ✅ Need publish checklist before hitting "post"
- ❌ Content still in production (use `csp-creator-short-video` or `csp-article-writing`)
- ❌ Only need text adaptation (use `csp-crosspost`)

## When NOT to Use

Skip this skill when:
- Content isn't finished yet → return to production skills
- Posting to a single text platform only → `csp-crosspost` is lighter
- Need automated timed publishing → use `csp-creator-auto-publish`

## Process

### Step 1: Asset Inventory & Readiness Check (2 min)

Gather all content assets, verify each:

```markdown
## Publish Manifest

### Content ID: [slug]
**Anchor Asset**: [video/article/carousel file]
**Derived Assets**:
  - [ ] 16:9 version (YouTube/B站)
  - [ ] 9:16 version (TikTok/抖音/Reels/Shorts)
  - [ ] 1:1 version (Instagram feed)
  - [ ] Thumbnail/cover image
  - [ ] Caption/description text
  - [ ] Subtitle file (.srt/.vtt)

**Publish Targets**: [platform list]
```

**Checkpoint**: All assets exist and match target formats.

**红线**：
- Missing subtitle file → BLOCKED (must generate before publishing)
- Wrong aspect ratio → generate correct version first
- No thumbnail → generate one with `csp-creator-thumbnail`

### Step 2: Platform-Specific Optimization (5 min)

For each target platform, optimize metadata:

| Platform | Title Max | Title Formula | Hashtags | Cover | Best Time |
|----------|-----------|---------------|----------|-------|-----------|
| 抖音 | 55 chars | 数字+情绪+悬念 | 3-5精准 | 9:16 高清 | 7-9am, 7-9pm |
| TikTok | 150 chars | Hook + emoji | 3-5 trending | 9:16 | varies by region |
| B站 | 80 chars | 双标题(主+副) | 5-10 tags | 16:9 custom | 12-2pm, 6-8pm |
| YouTube | 100 chars | SEO keyword + value | 10-15 tags | 16:9 custom | 12-4pm (weekday) |
| 小红书 | 20 chars | 情绪+场景 | 5-8 notes | 3:4 or 1:1 | 12-2pm, 8-10pm |
| 公众号 | 64 chars | 悬念+利益点 | N/A | 2.35:1 cover | 8-10am |
| X/Twitter | 280 chars | Claim first | 1-2 hashtags | 16:9 or 1:1 | 9-11am |
| LinkedIn | 220 chars | Professional hook | 3-5 | 1.91:1 | 8-10am (Tue-Thu) |

**Title formulas**:
- 数字型: "[N]个[主题]秘诀/工具/方法，第[X]个绝了"
- 情绪型: "[痛点描述]？试试这个[解决方案]"
- 悬念型: "99%的人不知道的[主题]秘密"
- 反转型: "都说[共识]，但[反观点]"

### Step 3: Hashtag Strategy

Per platform, generate hashtag mix:

```
Tier 1 — Broad reach (1-2): #AI #科技 (high volume, high competition)
Tier 2 — Niche target (2-3): #AI工具 #效率提升 (medium volume, target audience)
Tier 3 — Branded/long-tail (1-2): #XXX的AI工具箱 (low volume, community)
```

**红线**：
- No banned/flagged hashtags per platform
- Verify hashtag meaning before using (avoid double meanings)
- Don't use the same exact hashtag set across platforms

### Step 4: Publish Order & Timing

Default publish sequence for a coordinated launch:

```
1. Primary platform first (where audience is largest)
2. Secondary platforms within 30 min
3. Cross-reference in description where natural
4. Track initial engagement (first 60 min)
```

**Timing by timezone**: Default to China Standard Time (UTC+8) for 抖音/小红书/B站/公众号, local audience peak for TikTok/YouTube/X.

### Step 5: Go-Live & Monitor

Post-publish monitoring (first 24h):

- [ ] Content is live and accessible on all platforms
- [ ] Thumbnails/cover display correctly
- [ ] Captions/subtitles sync correctly
- [ ] Links in description/bio work
- [ ] Initial engagement metrics: views, likes, comments, shares

## Key Principles

- **Adapt, don't copy-paste** — Each platform version is distinct
- **Timing matters** — 30 min coordination window for multi-platform launch
- **Metadata IS content** — Title + thumbnail + first 3 seconds determine 80% of performance
- **Verify before publish** — Every asset checked before hitting "post"

## Verification Checklist

- [ ] Publish manifest complete with all assets listed
- [ ] Each platform has unique title (not copy-pasted)
- [ ] Hashtag strategy applied per platform (tier 1/2/3)
- [ ] Thumbnails/cover images generated and verified
- [ ] Subtitle files ready where required (抖音/TikTok mandatory)
- [ ] Publish times aligned with platform best times
- [ ] Post-publish monitoring scheduled

## Examples

### Example: Launch a tutorial video across platforms

```
Input: "帮我把这个AI教程视频发布到B站、抖音、小红书"

Process:
  1. Asset check: 16:9 source video → generate 9:16 (抖音), 3:4 (小红书)
  2. B站: 主标题"3个免费AI工具替代PS，设计效率翻倍"
     副标题"设计师必看｜适合新手的AI设计工具推荐"
     Tags: AI设计, 设计工具, 免费工具, PS替代, 效率提升
  3. 抖音: "设计师别再只会PS了！3个免费AI工具救你命"
     Hashtags: #AI工具 #设计 #免费 #效率
  4. 小红书: "设计师的AI秘密武器" (封面重点)
     Notes: #AI设计 #效率工具 #设计师日常 #免费资源
  5. Publish order: B站 → 小红书 → 抖音 (each 15 min apart)

Output:
  ✅ 3 platform variants ready
  ✅ 9:16 and 3:4 versions generated
  ✅ Custom thumbnails for each
  ✅ Publish schedule: B站 12:00 → 小红书 12:15 → 抖音 12:30
```

## 产物路径

发布管线产物落 `.csp/ship/` 目录：
- `.csp/ship/publish-manifest-{date}.yaml` — 发布清单
- `data/assets/{platform}/` — 待发布媒体资产

## Related Skills

- [[csp-creator-short-video]] — 短视频创作，发布前的内容生产
- [[csp-creator-content-strategy]] — 内容策略，确定发布什么
- [[csp-creator-auto-publish]] — 定时自动发布
- [[csp-creator-thumbnail]] — 封面图/缩略图设计
- [[csp-crosspost]] — 纯文本跨平台适配与分发
- [[csp-content-engine]] — 内容引擎，单条内容制作

遵照 `000-project-governance_csp.md` G2.1 约定：发布产物落 `.csp/ship/`，媒体资产落 `data/assets/`。