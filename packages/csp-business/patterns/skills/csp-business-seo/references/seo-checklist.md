# SEO/GEO Audit Checklist

## P0 — Critical (must fix immediately)

- [ ] `robots.txt` allows Googlebot, Bingbot, and AI bots (GPTBot, PerplexityBot, ClaudeBot)
- [ ] Site accessible (no 5xx errors)
- [ ] HTTPS enabled with valid SSL
- [ ] Mobile-responsive design
- [ ] No critical pages blocked by `noindex`
- [ ] Site indexed in Google (`site:domain.com`)
- [ ] Unique `<title>` tag (50-60 chars, contains primary keyword)
- [ ] Single H1 tag per page containing primary keyword

## P1 — Important (fix soon)

- [ ] Unique `<meta description>` (150-160 chars, compelling)
- [ ] Logical heading hierarchy (H1 > H2 > H3)
- [ ] All images have `alt` attributes
- [ ] XML sitemap exists and submitted to Google + Bing
- [ ] Canonical tags properly set
- [ ] Page load time < 3s (LCP < 2.5s)
- [ ] Site indexed in Bing (for Copilot visibility)
- [ ] At least one Schema type on each page (Article, FAQPage, Product, etc.)
- [ ] Schema validates via Google Rich Results Test

## P2 — Recommended (nice to have)

- [ ] Open Graph tags (og:title, og:description, og:image, og:url)
- [ ] Twitter Card tags
- [ ] LCP < 2.5s, FID < 100ms, CLS < 0.1
- [ ] Images optimized (WebP, lazy loading)
- [ ] CSS/JS minified
- [ ] GZIP/Brotli compression
- [ ] CDN configured
- [ ] Content updated within 30 days
- [ ] 2+ authoritative citations per major section
- [ ] 3+ specific data points/statistics
- [ ] FAQ section on key pages
- [ ] Internal links to related content
- [ ] Brave Search indexed (for Claude visibility)