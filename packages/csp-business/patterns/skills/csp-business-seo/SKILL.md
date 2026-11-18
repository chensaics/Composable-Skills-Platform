---
name: csp-business-seo
description: >
  Use when optimizing content for search engines (Google/Bing/百度) AND AI
  search engines (ChatGPT, Perplexity, Gemini, Copilot, Claude). Covers
  traditional SEO (keyword research, on-page, technical, backlinks) plus GEO
  (Generative Engine Optimization) — being cited by AI is the new ranking #1.
  Includes Princeton GEO 9 methods, platform-specific strategies, JSON-LD
  schema templates, and AI bot access verification.
  Keywords: SEO, GEO, 搜索引擎优化, AI搜索, ChatGPT, Perplexity, schema,
  JSON-LD, 结构化数据, keyword research, backlink, 排名, meta tags.
version: "1.0.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep, WebFetch, WebSearch]
related_skills:
  - csp-business-growth-engine
  - csp-business-analytics
  - csp-deep-research
triggers:
  keywords: ["SEO", "GEO", "搜索引擎优化", "AI搜索", "ChatGPT搜索", "Perplexity",
    "关键词", "backlink", "排名", "Google", "搜索排名", "meta", "schema",
    "JSON-LD", "结构化数据", "AI visibility", "generative engine"]
  intents:
    - "user wants to optimize content for search engines or AI search engines"
    - "user needs keyword research or GEO optimization"
    - "user wants their content to appear in ChatGPT/Perplexity/Gemini answers"
    - "user needs to add schema markup or structured data"
anti_rationalizations:
  "SEO is dead with AI search": "AI search engines cite sources. GEO is the new SEO — being cited > ranking #1. Princeton research shows up to 40% visibility boost with proper optimization."
  "I'll add schema later": "Schema markup is one of the highest-ROI SEO actions. Adding it later means missing AI citations today."
---

# SEO & GEO Optimization

搜索引擎优化 + 生成式引擎优化 — 让内容同时在传统搜索和 AI 搜索中被发现。

## Purpose

SEO + GEO 双轨优化：传统搜索（Google/Bing/百度）靠排名，AI 搜索（ChatGPT/Perplexity/Gemini）靠引用。**被 AI 引用就是新的"排名第一"。**

## When to Use

- ✅ 新网站/新页面需要 SEO+GEO 基础配置
- ✅ 现有内容需要同时优化传统搜索和 AI 搜索
- ✅ 需要让内容出现在 ChatGPT、Perplexity、Gemini、Copilot、Claude 的回答中
- ✅ 需要做关键词研究和内容策略
- ✅ 需要添加 Schema markup（JSON-LD 结构化数据）
- ✅ 需要验证 AI 爬虫访问权限
- ✅ 需要建立外链策略
- ❌ 付费搜索广告（SEM/PPC）——归 csp-business-growth-engine
- ❌ 纯内容创作（不含优化意图）——归 csp-beautiful-article

## Process

### Step 0: 技术审计（3 min）

运行快速技术健康检查，建立基线。

```bash
# 检查页面元数据
curl -sL "{URL}" | grep -E "<title>|<meta name=\"description\"|<meta property=\"og:|application/ld\+json" | head -20

# 检查 robots.txt 是否允许 AI 爬虫
curl -s "{URL}/robots.txt"

# 检查 sitemap
curl -s "{URL}/sitemap.xml" | head -50
```

**检查点**：输出当前状态报告：meta tags ✅/❌ | schema ✅/❌ | AI bots ✅/❌ | sitemap ✅/❌

**红线**：
- robots.txt 禁止 Googlebot/Bingbot → P0 阻塞
- 无 `<title>` 标签 → P0 阻塞
- AI 爬虫（GPTBot/PerplexityBot/ClaudeBot）被禁止 → 无法获得 AI 引用

### Step 1: 关键词研究（3 min）

传统搜索 + AI 搜索双轨关键词策略：

- Google Keyword Planner / Ubersuggest / Ahrefs Free — 传统搜索量和竞争度
- WebSearch 验证 SERP 前 3 的内容格式和长度
- 识别 AI 搜索偏好：问答型、How-to 型、对比型关键词

**输出**：关键词矩阵 `关键词 | 搜索量 | 难度 | 意图 | AI引用潜力 | 优先级`

### Step 2: On-Page SEO（2 min per page）

```html
<title>{主关键词} - {品牌} | {副关键词}</title>           <!-- ≤60 字符 -->
<meta name="description" content="{行动号召, 150-160 字符}">

<!-- Open Graph -->
<meta property="og:title" content="{Title}">
<meta property="og:description" content="{Description}">
<meta property="og:image" content="{1200x630 图片 URL}">
<meta property="og:url" content="{Canonical URL}">

<!-- Twitter Cards -->
<meta name="twitter:card" content="summary_large_image">
```

- URL 简短干净，含关键词
- 图片 alt text 描述性
- Internal linking 建立内容集群
- 外部链接加 `rel="noopener noreferrer"`

### Step 3: GEO 优化——让 AI 引用你的内容（5 min）

应用 **Princeton GEO 9 大方法**（详见 `references/geo-research.md`）：

| 方法 | 可见性提升 | 实操 |
|------|-----------|------|
| **Cite Sources** | +40% | 每个主要段落添加权威引用 |
| **Statistics Addition** | +37% | 加入具体数字和数据点 |
| **Quotation Addition** | +30% | 添加专家引言并署名 |
| **Authoritative Tone** | +25% | 用自信、专业的语气 |
| **Easy-to-understand** | +20% | 简化复杂概念 |
| **Technical Terms** | +18% | 正确使用领域术语 |
| **Unique Words** | +15% | 增加词汇多样性 |
| **Fluency Optimization** | +15-30% | 提升可读性和流畅度 |
| **Keyword Stuffing** | **-10%** | ⚠️ 避免！ |

**最佳组合**：Fluency + Statistics = 最大提升

**内容结构优化**：
- "答案优先"格式：直接回答放在最前面
- H1 > H2 > H3 清晰层级
- 2-3 句的短段落
- 对比数据用表格
- 要点用列表

### Step 4: Schema Markup（3 min）

**FAQPage Schema**（+40% AI 引用率）：
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "What is [topic]?",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "According to [source], [answer with statistics]."
    }
  }]
}
```

完整的 Schema 模板（Article / Product / Organization / SoftwareApp / HowTo / LocalBusiness / SpeakableSpecification）见 `references/schema-templates.md`。

验证 Schema：`https://search.google.com/test/rich-results?url={encoded_url}`

### Step 5: AI 爬虫访问验证

确保以下爬虫在 robots.txt 中允许：
```
User-agent: Googlebot       # Google / Google AI Overview
User-agent: Bingbot         # Bing / Copilot
User-agent: PerplexityBot   # Perplexity
User-agent: GPTBot          # ChatGPT browsing
User-agent: ChatGPT-User    # ChatGPT browsing
User-agent: ClaudeBot       # Claude
User-agent: anthropic-ai    # Claude
Allow: /
```

### Step 6: 平台差异化策略

不同 AI 搜索引擎有不同偏好（详见 `references/platform-algorithms.md`）：

| 平台 | 关键因子 | 特殊要求 |
|------|---------|---------|
| **ChatGPT** | 域名权威 + 内容时效 | 30 天内更新内容、匹配 ChatGPT 回答风格 |
| **Perplexity** | 语义相关 + FAQ Schema | 允许 PerplexityBot、上传 PDF |
| **Google AI Overview** | E-E-A-T + 结构化数据 | Knowledge Graph 收录、主题权威 |
| **Copilot** | Bing 索引 + 微软生态 | 提交 Bing Webmaster、页面速度 < 2s |
| **Claude** | Brave 索引 + 事实密度 | 确保 Brave Search 收录、ClaudeBot 允许 |

## Key Principles

- **引用 > 排名**：AI 搜索不排名页面，它引用来源。被引用就是新的排名第一
- **内容为王，外链为后**：先做好内容质量和结构化数据，再建外链
- **长短结合**：传统 SEO 靠长尾关键词；GEO 靠结构化数据和权威度
- **时效性**：30 天内更新过的内容被 AI 多引用 3.2 倍
- **白帽 ONLY**：不用黑帽技术。GEO 下关键词堆砌反而 -10% 可见性

## Anti-Patterns

| Anti-Pattern | 信号 | 正确做法 |
|-------------|------|---------|
| 只优化 Google，忽略 AI | 内容没有 schema、没有权威引用 | 添加 FAQPage/Article schema + 统计引用 |
| 关键词堆砌 | GEO 可见性下降 10% | 自然写作，多样词汇 |
| robots.txt 禁止 AI 爬虫 | 零 AI 引用 | 开放 GPTBot/PerplexityBot/ClaudeBot |
| 内容长期不更新 | AI 引用率低 | 30 天内刷新内容 |
| Schema 错误 | Rich Results Test 报错 | 用 validator.schema.org 验证 |

## Verification Checklist

- [ ] Title tag 含目标关键词，≤60 字符
- [ ] Meta description 有行动号召，≤160 字符
- [ ] H1/H2 层级清晰
- [ ] 所有图片有 alt text
- [ ] robots.txt 允许主流 AI 爬虫
- [ ] 至少一种 Schema markup（FAQPage/Article/Product）
- [ ] Schema 通过 Google Rich Results Test 验证
- [ ] 内容含 2+ 权威引用
- [ ] 内容含 3+ 具体数据/统计
- [ ] 页面加载 < 3s（LCP < 2.5s）
- [ ] 移动端正常显示
- [ ] Sitemap 已提交 Google + Bing
- [ ] 内容 30 天内有更新

## Examples

### Example 1: 新 SaaS 产品页面优化

```
输入: "帮我优化我们的 AI 客服产品落地页的 SEO，让它在 ChatGPT 搜索中也能被提到"
处理:
  1. 技术审计 → 发现无 schema、robots.txt 禁止 GPTBot
  2. 关键词研究 → 主关键词"AI customer service software"
  3. On-Page → 优化 title/meta/OG，添加 3 个 FAQ
  4. GEO → 添加 "According to Gartner, AI chatbots handle 85% of routine inquiries"
  5. Schema → 添加 SoftwareApplication + FAQPage + Organization
  6. 修复 robots.txt → 允许 GPTBot/PerplexityBot/ClaudeBot
输出: 落地页结构化数据完整，AI 爬虫可访问，含权威引用和数据点
```

### Example 2: 博客文章 GEO 优化

```
输入: "这篇关于 RAG 架构的技术博客怎么让 Perplexity 引用？"
处理:
  1. GEO 审计 → 内容不错但缺少 schema 和权威引用
  2. 添加 Article schema + SpeakableSpecification
  3. 注入 5 个权威引用（"According to the original RAG paper by Lewis et al. (2020)..."）
  4. 结构化改进 → 答案优先格式 + FAQ section
  5. 验证 PerplexityBot 可访问
输出: 博客文章对 AI 引擎友好，FAQ section 可被 Perplexity 直接引用
```

## Related Skills

- [[csp-business-growth-engine]] — 全渠道增长引擎（含 SEM/PPC）
- [[csp-business-analytics]] — 流量和转化数据分析
- [[csp-deep-research]] — 深度调研（用于竞品 SEO 分析）
- [[csp-beautiful-article]] — 高质量内容创作（先创作后优化）