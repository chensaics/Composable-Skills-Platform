# Reddit JSON API Reference

Reddit 公开 JSON API——追加 `.json` 到任何 Reddit URL 即可获取数据。无需认证，Rate limit: 100 req/min。

## Base URL

```
https://www.reddit.com
```

## User-Agent

必须设置 User-Agent header（否则返回 429）：
```
User-Agent: Research/1.0 (your-project-description)
```

## Endpoints

### 搜索帖子

```bash
# 全站搜索
GET /search.json?q={query}&sort=relevance&limit=25&raw_json=1

# 子版块内搜索
GET /r/{subreddit}/search.json?q={query}&restrict_sr=1&sort=top&t=year&limit=25&raw_json=1
```

### 子版块帖子

```bash
GET /r/{subreddit}/hot.json?limit=25&raw_json=1        # 热门
GET /r/{subreddit}/new.json?limit=25&raw_json=1         # 最新
GET /r/{subreddit}/top.json?t=week&limit=25&raw_json=1  # 每周最佳
GET /r/{subreddit}/rising.json?limit=25&raw_json=1      # 上升中
```

### 帖子与评论

```bash
GET /comments/{post_id}.json?limit=50&raw_json=1
# 返回数组: [post_listing, comments_listing]
```

### 子版块信息

```bash
GET /r/{subreddit}/about.json?raw_json=1
```

### 用户信息

```bash
GET /user/{username}/about.json?raw_json=1
GET /user/{username}/submitted.json?limit=25&raw_json=1  # 用户帖子
```

## 响应结构

```json
{
  "data": {
    "children": [
      {
        "data": {
          "id": "abc123",
          "title": "Post Title",
          "subreddit": "python",
          "author": "username",
          "score": 150,
          "upvote_ratio": 0.95,
          "num_comments": 42,
          "url": "https://...",
          "permalink": "/r/python/comments/abc123/...",
          "selftext": "Post body text...",
          "created_utc": 1700000000,
          "link_flair_text": "Discussion"
        }
      }
    ],
    "after": "t3_abc123"   // pagination cursor
  }
}
```

## 搜索策略

| Query 类型 | 示例 | 用途 |
|-----------|------|------|
| 产品反馈 | `"{product}" review` | 用户评价 |
| 痛点搜索 | `"hate {product}" OR "frustrated with {product}"` | 负面反馈 |
| 需求发现 | `"looking for" "{category}"` | 未满足的需求 |
| 竞品比较 | `"{productA}" vs "{productB}"` | 竞争定位 |
| 功能请求 | `"wish {product} had" OR "{product} missing"` | 功能 gap |

## 推荐子版块（按领域）

| 领域 | 推荐子版块 |
|------|-----------|
| 开发者工具 | r/programming, r/webdev, r/devops, r/selfhosted |
| AI/SaaS | r/MachineLearning, r/SaaS, r/OpenAI, r/ClaudeAI |
| 设计 | r/web_design, r/UI_Design, r/graphic_design |
| 产品 | r/ProductManagement, r/startups, r/Entrepreneur |
| 自媒体 | r/NewTubers, r/podcasting, r/Blogging |