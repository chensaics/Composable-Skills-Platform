# Product Hunt GraphQL API Reference

## Endpoint

```
POST https://api.producthunt.com/v2/api/graphql
Authorization: Bearer {PRODUCTHUNT_ACCESS_TOKEN}
Content-Type: application/json
```

## Rate Limits

6250 complexity points / 15 minutes. Each field in the query contributes to complexity.

## Core Queries

### Posts (Product Listings)

```graphql
# Featured posts
query { posts(first: 20, featured: true) { edges { node { id name tagline votesCount commentsCount url website } } } }

# By topic
query { posts(first: 15, topic: "developer-tools") { edges { node { id name tagline votesCount } } } }

# By date range
query { posts(first: 10, postedAfter: "2026-01-01T00:00:00Z", postedBefore: "2026-01-31T23:59:59Z") { edges { node { name tagline votesCount } } } }

# By ID or slug
query { post(slug: "chatgpt") { id name tagline description votesCount commentsCount url website makers { name username headline } topics(first: 5) { edges { node { name slug } } } } }
```

### Topics (Categories)

```graphql
# Search topics
query { topics(query: "AI", first: 15) { edges { node { id name slug description postsCount followersCount } } } }

# Single topic
query { topic(slug: "artificial-intelligence") { id name description postsCount followersCount } }
```

### Users (Makers)

```graphql
# User profile
query { user(username: "rrhoover") { id name username headline isMaker twitterUsername websiteUrl } }

# User's submitted products
query { user(username: "rrhoover") { submittedPosts(first: 10) { edges { node { id name tagline votesCount url } } } } }

# User's made (created) products
query { user(username: "rrhoover") { madePosts(first: 10) { edges { node { id name tagline votesCount } } } } }
```

### Collections

```graphql
# Featured collections
query { collections(first: 10, featured: true, order: FOLLOWERS_COUNT) { edges { node { id name tagline url followersCount posts(first: 5) { edges { node { name tagline votesCount } } } } } } }

# Single collection
query { collection(slug: "ai-tools") { id name tagline description url followersCount posts(first: 10) { edges { node { name tagline votesCount } } } } }
```

### Comments

```graphql
query { post(slug: "chatgpt") { comments(first: 20) { edges { node { id body votesCount createdAt user { name username } } } } } }
```

## Key Fields Reference

### Post
| Field | Type | Description |
|-------|------|-------------|
| `id` | ID | Unique identifier |
| `name` | String | Product name |
| `tagline` | String | One-line description |
| `slug` | String | URL-friendly name |
| `description` | String | Full description (HTML) |
| `votesCount` | Int | Total upvotes |
| `commentsCount` | Int | Total comments |
| `url` | String | PH page URL |
| `website` | String | Product website |
| `featuredAt` | DateTime | When featured |
| `createdAt` | DateTime | When submitted |
| `makers` | [User] | Product creators |
| `topics` | [Topic] | Assigned categories |

### User
| Field | Type | Description |
|-------|------|-------------|
| `id` | ID | User ID |
| `name` | String | Display name |
| `username` | String | @handle |
| `headline` | String | Bio/title |
| `isMaker` | Boolean | Is a product maker |
| `twitterUsername` | String | Twitter handle |
| `websiteUrl` | String | Personal website |

### Topic
| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Display name |
| `slug` | String | URL slug |
| `description` | String | Topic description |
| `postsCount` | Int | Products in topic |
| `followersCount` | Int | Topic followers |

## Useful Topic Slugs

| Slug | Category |
|------|----------|
| `developer-tools` | 开发工具 |
| `artificial-intelligence` | AI |
| `saas` | SaaS |
| `productivity` | 生产力 |
| `design-tools` | 设计工具 |
| `open-source` | 开源 |
| `analytics` | 数据分析 |
| `api` | API |
| `no-code` | 无代码 |
| `privacy` | 隐私安全 |
| `fintech` | 金融科技 |
| `health` | 健康医疗 |
| `education` | 教育 |
| `e-commerce` | 电商 |
| `marketing` | 市场营销 |

## Signal Interpretation

| Votes | Signal |
|-------|--------|
| < 50 | 低关注度，可能是早期/利基产品 |
| 50-200 | 中等关注，有一定 traction |
| 200-500 | 不错的发布，社区认可 |
| 500-1000 | 热门发布，通常获得 Featured |
| 1000-2000 | 爆款，Product of the Day 级别 |
| 2000+ | 现象级，Product of the Week/Month |