---
name: csp-creator-auto-publish
description: >
  Use when setting up automated/timed content publishing. Covers scheduled posting
  via platform APIs or scheduling tools, batch upload, content queue management,
  and post-publish performance data collection for复盘. Use when content is ready
  but publishing should happen at a future time. Keywords: 定时发布, 自动发布,
  scheduled post, 批量发布, batch publish, 内容队列, content queue, 数据复盘,
  performance review, 定时, 预约发布.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: ship
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
dependencies:
  skills: [csp-creator-publish-pipeline]
related_skills:
  - csp-creator-publish-pipeline
  - csp-creator-content-strategy
  - csp-creator-short-video
triggers:
  keywords: ["定时发布", "自动发布", "预约发布", "scheduled post", "批量发布",
             "batch publish", "内容队列", "content queue", "数据复盘", "performance review"]
  intents:
    - "user wants to schedule content for later publishing"
    - "user wants batch upload across platforms"
    - "user wants to review content performance data"
---

# Auto-Publish & Performance Review

Automated timed publishing + post-publish data复盘.

## Purpose

Don't baby-sit the publish button. Queue content for automated publishing at optimal times, then collect performance data for review and strategy iteration.

## When to Use

- ✅ Need to schedule posts for future dates/times
- ✅ Want to batch-upload a week's content at once
- ✅ Need post-publish performance data for复盘
- ✅ Content calendar has 7+ items — automation saves hours
- ❌ Publishing immediately right now (use `csp-creator-publish-pipeline`)
- ❌ Only 1-2 posts (manual publish is fine)

## Process

### Step 1: Queue Setup (3 min)

Build content queue from editorial calendar:

```yaml
# .csp/publish-queue.yaml
queue:
  - id: "post-001"
    platform: douyin
    title: "3个免费AI工具"
    asset: "data/assets/douyin/post-001.mp4"
    scheduled: "2026-11-18T12:00:00+08:00"
    hashtags: ["#AI工具", "#免费", "#效率"]
    status: scheduled

  - id: "post-002"
    platform: bilibili
    title: "AI工具深度评测：这3款改变我的工作流"
    subtitle: "设计师效率提升300%"
    asset: "data/assets/bilibili/post-002.mp4"
    scheduled: "2026-11-18T12:15:00+08:00"
    tags: ["AI", "设计", "工具评测", "效率"]
    status: scheduled
```

**Checkpoint**: Queue has valid assets, future dates, and complete metadata.

### Step 2: Scheduling Options

Choose scheduling method per platform:

| Platform | Manual Schedule | API/3rd-Party Tool |
|----------|----------------|-------------------|
| 抖音 | 创作者服务平台 → 定时发布 | 抖音开放平台 API |
| TikTok | TikTok Studio → Schedule | TikTok Creator API |
| B站 | 创作中心 → 定时发布 | bilibili-api |
| YouTube | YouTube Studio → Schedule | YouTube Data API v3 |
| 小红书 | 创作者中心 → 定时发布 | Limited API |
| 公众号 | 后台 → 定时群发 | 公众号 API |
| X/Twitter | TweetDeck → Schedule | X API v2 |
| LinkedIn | Schedule post (native) | LinkedIn API |

**Recommendation**: Use native scheduling for < 5 posts/week. Use third-party tools (Hootsuite/Buffer/Later) for > 5 posts/week across 3+ platforms.

### Step 3: Batch Upload

For platforms supporting bulk scheduling:

```python
# Example: Batch schedule via bilibili-api
from bilibili_api import video_uploader

for post in queue:
    if post['scheduled'] > now:
        video_uploader.schedule(
            video_path=post['asset'],
            title=post['title'],
            tags=post['tags'],
            publish_time=post['scheduled']
        )
```

**Batch limits**: Most platforms cap at 10-50 scheduled posts. Split large queues into manageable batches.

### Step 4: Performance Data Collection (复盘)

After content has been live for 24h-7d, collect metrics:

```markdown
## Performance Report: [Content ID]

### Platform: 抖音
| Metric | Value | Benchmark |
|--------|-------|-----------|
| Views | 12,340 | > 5K ✅ |
| Likes | 890 | > 500 ✅ |
| Comments | 45 | > 20 ✅ |
| Shares | 120 | > 50 ✅ |
| Completion rate | 62% | > 45% ✅ |
| Follower growth | +34 | > 10 ✅ |

### Traffic Sources
- 推荐流: 68%
- 搜索: 15%
- 主页: 10%
- 其他: 7%

### Key Takeaways
- Hook (前3秒) 完成率高 → 保持这个 hook 风格
- 评论区反馈：想要更多实操步骤 → 下期加实操
- 标签 #AI工具 带来最多搜索流量 → 继续使用
```

### Step 5: Strategy Iteration

Feed performance data back to content strategy:

```yaml
insights:
  - finding: "教程类内容完播率最高(62%)"
    action: "增加教程类内容比例 40% → 50%"
  - finding: "晚8点发布的视频播放量比中午高40%"
    action: "优先排期到晚8点档"
  - finding: "含'免费'关键词的标题点击率高25%"
    action: "标题策略中加入价值信号词"
```

## Key Principles

- **Schedule once, publish everywhere** — Batch the work upfront
- **Data closes the loop** — Performance data feeds back to strategy
- **Platform-native scheduling beats third-party where supported** — Lower failure rate
- **Monitor, don't fire-and-forget** — Check first 60 min of each publish for issues

## Anti-Patterns

| Anti-Pattern | Signal | Fix |
|-------------|--------|-----|
| Queue-and-forget | No post-publish check | Monitor first 60 min |
| All platforms same time | Self-competition | Stagger by 15-30 min |
| No performance review | "Just post more" mindset | Collect and analyze data |
| Over-automation | Queue filled months ahead | Max 2-week queue, leave room for trending |

## Verification Checklist

- [ ] Publish queue created with valid future dates
- [ ] All assets verified before scheduling
- [ ] Platform scheduling method chosen per platform
- [ ] Performance data collection template ready
- [ ] First 60-min monitoring plan in place
- [ ] Review session scheduled (24h and 7d post-publish)

## Examples

### Example: Weekly auto-publish batch

```
Input: "帮我把这周的5条内容排期到抖音和B站自动发布"

Output:
  Queue set:
    Mon 12:00 抖音 | "3个免费AI工具"
    Mon 12:15 B站   | "AI工具深度评测"
    Wed 12:00 抖音 | "AI翻车现场合集"
    Wed 12:15 B站   | "AI生成内容的边界在哪里"
    Fri 12:00 抖音 | "周末效率工具推荐"
    Fri 12:15 B站   | "我的AI工作流全揭秘"

  Data collection scheduled:
    Mon → review Wed
    Wed → review Fri
    Fri → review Mon
```

## Related Skills

- [[csp-creator-publish-pipeline]] — 即时手动发布流程
- [[csp-creator-content-strategy]] — 内容策略，数据复盘后迭代策略
- [[csp-creator-short-video]] — 短视频内容生产
- [[csp-autonomous-loops]] — 自动化循环任务设置