---
name: csp-creator-thumbnail
description: >
  Use when designing video thumbnails, article cover images, social media covers,
  or any first-impression visual that drives click-through. Covers composition rules,
  text overlay, color psychology, A/B testing, and platform-specific dimensions.
  Use BEFORE publishing — thumbnails determine 80% of click-through. Keywords: 封面,
  缩略图, thumbnail, cover, 封面设计, 点击率, CTR, YouTube thumbnail, 小红书封面,
  抖音封面, B站封面.
version: "0.1.0"
layer: 3
category: patterns
type: technique
phase: build
domain: patterns
role: specialist
scope: implementation
invocation: user
tools: [Read, Write, Edit, Bash, Glob, Grep]
dependencies:
  skills: [csp-creator-image-prompt]
related_skills:
  - csp-creator-image-prompt
  - csp-creator-short-video
  - csp-creator-publish-pipeline
  - csp-poster
triggers:
  keywords: ["封面", "缩略图", "thumbnail", "cover", "封面设计", "点击率", "CTR",
             "YouTube封面", "小红书封面", "抖音封面", "B站封面", "头图"]
  intents:
    - "user wants to design a thumbnail or cover image"
    - "user's video/article isn't getting clicks"
    - "user needs platform-specific cover design"
---

# Thumbnail & Cover Design

Design first-impression visuals that make people click.

## Purpose

Your content could be brilliant — but if the thumbnail doesn't sell it, nobody sees it. This skill covers the art and science of thumbnail design: composition, text overlay, color psychology, platform-specific rules, and A/B testing.

## When to Use

- ✅ Creating a thumbnail for a video (YouTube/B站/抖音)
- ✅ Designing a cover for an article (公众号/小红书)
- ✅ Click-through rate is below benchmark → redesign
- ✅ Setting up A/B thumbnail testing
- ❌ Full poster/marketing material (use `csp-poster`)
- ❌ In-content images/illustrations (use `csp-creator-image-prompt`)

## Platform Dimension Reference

| Platform | Dimensions | Ratio | Max Text | File Size |
|----------|-----------|-------|----------|-----------|
| YouTube | 1280×720 | 16:9 | 4-6 words | < 2 MB |
| B站 | 1146×717 | ~16:10 | 4-8 chars | < 5 MB |
| 抖音 | 1080×1920* | 9:16* | 3-5 chars | N/A (frame select) |
| TikTok | 1080×1920* | 9:16* | 3-5 chars | N/A (frame select) |
| 小红书 | 1080×1440 | 3:4 | 5-10 chars | < 20 MB |
| 公众号 | 900×383 | 2.35:1 | 0-8 chars | < 10 MB |
| X/Twitter | 1200×675 | 16:9 | Minimal | < 5 MB |
| Podcast | 3000×3000 | 1:1 | Show name | < 500 KB |

*短视频平台封面取自视频帧，需在剪辑时预留封面帧。

## Thumbnail Composition Rules

### Rule 1: The 3-Element Rule

Every effective thumbnail has exactly 3 focal elements:

```
1. SUBJECT (50% of frame)  — Face, object, or scene that anchors attention
2. CONTEXT (30% of frame)  — Background/environment that sets the mood
3. TEXT/ACCENT (20% of frame) — 3-5 words max, large font, high contrast
```

### Rule 2: Face Forward

Faces increase CTR by 30-50%:
- **Eye contact** with camera (or looking at the subject matter)
- **Expressive emotion** — surprise, curiosity, excitement
- **Face takes ~40-50% of thumbnail area**
- **Well-lit, sharp, no motion blur**

### Rule 3: Color Contrast

High-contrast color combos that pop:

| Background | Text/Accent | Vibe |
|------------|------------|------|
| Dark (#1a1a2e) | Yellow (#ffd700) | Bold, dramatic |
| Dark (#1a1a2e) | Cyan (#00d4ff) | Tech, futuristic |
| White (#ffffff) | Red (#ff2d55) | Urgent, attention |
| Dark blue (#0d1b2a) | Orange (#ff6b35) | Professional, warm |
| Black (#000000) | White (#ffffff) | Minimal, premium |
| Gradient | White outline text | Modern, dynamic |

### Rule 4: Text That Works at Small Size

Thumbnail text appears at ~150px wide in feeds. Test it:
- **Max 5 words** (4 for Chinese characters)
- **Sans-serif bold** (no thin/serif fonts at small size)
- **Drop shadow or outline** for readability over busy backgrounds
- **Left or center alignment** (never right)
- **No punctuation** unless it's a question mark or exclamation

### Good vs Bad Text Examples:

| ❌ Bad | ✅ Good | Why |
|--------|---------|-----|
| "在这个视频中我将向大家展示如何..." | "3步学会" | Too long, gets cut off |
| "Complete Guide to AI Tools for..." | "AI Tools 101" | Too long, gets cut off |
| "tips" (lowercase, no contrast) | "5 TIPS" (bold, outlined) | Too subtle at thumbnail size |

## Thumbnail Design Process

### Step 1: Extract the Hook

From the content, extract the single most compelling visual moment or promise:

```
Content: "3个免费AI工具替代PS"
Hook options:
  1. Before/after comparison (PS result vs AI result)
  2. Surprised face + tool screenshot
  3. "免费" big text + tool logos
→ Pick option 2 (face + result = highest CTR)
```

### Step 2: Build the Layout

```
┌─────────────────────────────────┐
│  [BACKGROUND: relevant scene]    │
│                                  │
│   ┌──────────┐    ┌──────────┐  │
│   │ SUBJECT  │    │  BIG TEXT │  │
│   │  (face/  │    │  3-5 WORDS│  │
│   │  object) │    │  outlined │  │
│   └──────────┘    └──────────┘  │
│                                  │
│   [ACCENT: logo/brand/arrow]     │
└─────────────────────────────────┘
```

### Step 3: Generate or Source the Image

- AI-generated: Use `csp-creator-image-prompt` with thumbnail-specific prompt
- Screenshot: Take at highest resolution, crop to target ratio
- Photo: Well-lit, sharp, high contrast

### Step 4: Add Text Overlay

```css
/* Thumbnail text CSS reference (for HTML canvas/Figma) */
.thumbnail-text {
  font-family: "PingFang SC", "Noto Sans SC", sans-serif;
  font-weight: 900; /* Extra bold */
  font-size: 72px; /* At 1280px wide canvas */
  color: #ffffff;
  text-shadow:
    0 2px 8px rgba(0,0,0,0.8),  /* Drop shadow */
    0 0 40px rgba(0,0,0,0.4);   /* Glow for readability */
  letter-spacing: 2px;
  line-height: 1.1;
}
```

### Step 5: Thumbnail Checklist Before Publishing

- [ ] Subject is clearly visible at 200px wide (phone feed preview)
- [ ] Text is readable at 150px wide
- [ ] 3 elements maximum (not cluttered)
- [ ] High contrast between subject and background
- [ ] No important content in bottom-right corner (overlaid by duration badge)
- [ ] Consistent with your brand/visual identity

## A/B Testing Thumbnails

For YouTube (supports native A/B testing):

1. Create 3 variants of the same thumbnail:
   - **Variation A**: Different facial expression
   - **Variation B**: Different text/copy
   - **Variation C**: Different background/color scheme

2. Upload all 3 to YouTube's "Test & Compare" feature

3. After 1-2 weeks, check which has the highest CTR
   - Replace losing thumbnails with the winner
   - Feed learning into future designs

## Key Principles

- **Thumbnail sells the click; content delivers the promise** — Don't clickbait
- **Face beats object, emotion beats neutral** — Humans connect with humans
- **Test at phone-feed size** — How it looks at 1200px doesn't matter
- **3 elements max** — Any more and nothing registers at thumbnail scale

## Verification Checklist

- [ ] Platform dimensions correct (ratio + pixels)
- [ ] 3-element composition: subject + context + text
- [ ] Text readable at 150px width (test it)
- [ ] High color contrast between text and background
- [ ] No content in bottom-right corner (YouTube duration badge zone)
- [ ] Video title and thumbnail tell a consistent story (no mismatch)
- [ ] Thumbnail file size under platform limit

## Examples

### Example: YouTube tutorial thumbnail

```
Input: "帮我的AI工具教程视频设计一个YouTube封面"

Video topic: "3个免费AI编程助手，效率翻倍"

Design:
  Subject: My surprised/excited face (60% of frame, left side)
  Context: VS Code screen with AI autocomplete in background (40%, right side)
  Text: "免费AI编程" (white bold, outlined, bottom-left, 20% of frame)
  Colors: Dark IDE background + warm face lighting + white/yellow text

Prompt for face shot replacement (if AI-generated):
  "Surprised young programmer looking at laptop, well-lit face,
  genuine expression of amazement, professional but casual look,
  portrait orientation close-up, sharp focus, natural lighting"
```

## Related Skills

- [[csp-creator-image-prompt]] — AI 图片 prompt 工程（生成封面底图）
- [[csp-creator-short-video]] — 短视频创作（封面最终发布在这里）
- [[csp-creator-publish-pipeline]] — 发布流水线（封面是最终检查项）
- [[csp-poster]] — 营销海报（更大画幅，更多文字）