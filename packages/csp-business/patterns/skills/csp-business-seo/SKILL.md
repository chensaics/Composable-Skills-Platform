---
name: csp-business-seo
description: >
  Use when optimizing content for search engines (Google/Bing/百度).
  Covers keyword research, on-page SEO, technical SEO, backlink strategy,
  content optimization, and rank tracking.
  Keywords: SEO, 搜索引擎优化, 关键词, backlink, 排名, Google, 百度, 搜索排名, meta tags.
version: "0.1.0"
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
triggers:
  keywords: ["SEO", "搜索引擎优化", "关键词", "backlink", "排名", "Google", "搜索排名", "meta"]
  intents:
    - "user wants to optimize content for search engines"
    - "user needs keyword research"
---

# SEO Optimization

搜索引擎优化——从关键词到排名的完整工作流。

## Purpose

帮助一人公司/超级个体在有限资源下，系统性地提升搜索可见性和自然流量。

## When to Use

- ✅ 新网站/新页面需要 SEO 基础配置
- ✅ 现有内容需要 SEO 优化
- ✅ 需要做关键词研究和内容策略
- ✅ 需要建立外链策略
- ❌ 付费搜索广告（SEM/PPC）——归 business-growth-engine

## Process

### Step 1: 关键词研究（2 min）

使用免费/低成本工具做关键词研究：
- Google Keyword Planner / Ubersuggest / Ahrefs Free
- 分析搜索量、竞争度、用户意图
- 识别长尾关键词机会

**输出**：关键词矩阵 `关键词 | 搜索量 | 难度 | 意图 | 优先级`

### Step 2: On-Page SEO（1 min per page）

逐页面优化清单：
- Title tag: 含主关键词，≤60 字符
- Meta description: 行动号召，≤160 字符
- H1/H2 结构：有层级，含关键词变体
- URL: 简短，含关键词
- 图片 alt text: 描述性，含关键词
- Internal linking: 相关内容互链

### Step 3: Technical SEO

技术健康检查：
- 页面速度 (Core Web Vitals: LCP/FID/CLS)
- 移动友好性
- SSL/HTTPS
- Sitemap.xml + robots.txt
- Schema markup (结构化数据)
- Canonical tags

### Step 4: Content Optimization

内容质量优化：
- E-E-A-T: Experience, Expertise, Authoritativeness, Trustworthiness
- 内容长度：对标 SERP 前 3 的平均字数
- 多媒体：图片/视频/图表
- 更新频率：定期刷新旧内容

## Key Principles

- **内容为王，外链为后**：先做好内容质量，再建外链
- **长尾优先**：一人公司资源有限，长尾关键词 ROI 更高
- **白帽 ONLY**：不用黑帽技术（隐藏文字/链接农场/PBN）
- **一致性**：品牌名称、NAP (Name/Address/Phone) 全网一致

## Verification Checklist

- [ ] Title tag 含目标关键词，≤60 字符
- [ ] Meta description 有行动号召
- [ ] URL 结构干净
- [ ] 所有图片有 alt text
- [ ] 页面加载速度（LCP < 2.5s）
- [ ] 移动端正常显示
- [ ] Sitemap 已提交
- [ ] Schema markup 已验证

## Related Skills

- [[csp-business-growth-engine]] — 全渠道增长引擎
- [[csp-business-analytics]] — 流量和转化数据分析
- [[csp-business-model-canvas]] — 商业模式与变现策略