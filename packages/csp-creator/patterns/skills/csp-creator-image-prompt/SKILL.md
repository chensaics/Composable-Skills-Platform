---
name: csp-creator-image-prompt
description: >
  Use when crafting prompts for AI image generation (fal.ai, Midjourney, DALL-E, Stable
  Diffusion, Nano Banana, etc.). Covers prompt structure, style control, composition
  techniques, negative prompting, and model-specific optimization. Use BEFORE generating
  images — good prompts save iterations. Keywords: AI绘图, 图片生成, prompt engineering,
  image prompt, 提示词, Midjourney, DALL-E, Stable Diffusion, 图像生成, 提示词工程,
  text-to-image.
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
related_skills:
  - csp-fal-ai-media
  - csp-poster
  - csp-creator-thumbnail
triggers:
  keywords: ["AI绘图", "图片生成", "提示词", "prompt engineering", "Midjourney",
             "DALL-E", "Stable Diffusion", "图像生成", "文生图", "text-to-image",
             "image prompt", "写prompt", "绘图提示词"]
  intents:
    - "user wants to write better AI image prompts"
    - "user's generated images don't match expectations"
    - "user wants to learn prompt structure"
---

# AI Image Prompt Engineering

Craft prompts that make AI image generators produce exactly what you want — first try, fewer iterations.

## Purpose

AI image generators speak prompt-language. This skill teaches the grammar: how to structure prompts, control style, manage composition, and use negative prompts effectively. It turns "close but not quite" into "exactly what I pictured."

## When to Use

- ✅ Before generating AI images — craft the prompt first
- ✅ Generated images don't match vision — debug the prompt
- ✅ Need consistent style across multiple images
- ✅ Switching between models (Midjourney → DALL-E → fal.ai)
- ❌ Already have a working prompt template for your use case

## Prompt Structure Formula

Every effective image prompt follows this hierarchy:

```
[Subject] + [Context/Scene] + [Style/Medium] + [Lighting/Color] + [Composition] + [Quality Modifiers]
```

| Element | Weight | Example |
|---------|--------|---------|
| **Subject** | 40% | "a young woman with silver hair, wearing a minimalist white dress" |
| **Context/Scene** | 25% | "standing in a futuristic glass atrium overlooking a cyberpunk city" |
| **Style/Medium** | 15% | "digital painting, anime-inspired with realistic rendering" |
| **Lighting/Color** | 10% | "soft cinematic lighting, cool blue tones with warm accent highlights" |
| **Composition** | 5% | "medium shot, rule of thirds, subject centered, shallow depth of field" |
| **Quality** | 5% | "highly detailed, 8K, sharp focus, professional photography" |

### Model-Specific Syntax

| Model | Prompt Style | Special Syntax |
|-------|-------------|----------------|
| **fal.ai Nano Banana** | Natural language, detailed | `image_size`, `guidance_scale`, `seed` |
| **Midjourney** | Keyword-heavy, comma-separated | `--ar 16:9 --style raw --v 6.1` parameters |
| **DALL-E 3** | Natural language, narrative | No special syntax needed |
| **Stable Diffusion** | Tag-based, weighted | `(important:1.2)`, `[negative]`, LoRA triggers |

## Style Control

### Style Keywords by Category

| Category | Keywords |
|----------|----------|
| **Photography** | `professional photography, 85mm lens, f/1.8, golden hour, editorial` |
| **Digital Art** | `digital painting, concept art, artstation style, trending on behance` |
| **Anime/Manga** | `anime style, studio ghibli aesthetic, makoto shinkai lighting` |
| **3D Render** | `octane render, unreal engine 5, ray tracing, photorealistic 3D` |
| **Illustration** | `vector illustration, flat design, minimalist, bold colors, geometric` |
| **Oil Painting** | `oil on canvas, impasto technique, rembrandt lighting, classical` |
| **Watercolor** | `watercolor wash, wet-on-wet, soft edges, paper texture` |
| **UI/Screenshot** | `clean UI design, product screenshot, SaaS dashboard, glass morphism` |

### Style Consistency Across Images

To maintain a consistent style across multiple images:

```yaml
style_seed:
  artist_style: "makoto shinkai"
  color_palette: "cool blues, warm golden hour accents"
  lighting: "soft diffused light, lens flares"
  rendering: "highly detailed, volumetric lighting, 8K"
  composition: "wide establishing shots, shallow depth of field on close-ups"

# Reuse this style_seed block in every prompt
```

## Negative Prompting

What to exclude, by model:

```
# Universal negative prompt template
"blurry, low quality, deformed, distorted, extra limbs, bad anatomy,
watermark, text, signature, cropped, out of frame, ugly, duplicate"

# Context-specific additions
Portraits: "asymmetrical eyes, bad teeth, plastic skin, doll-like"
Architecture: "floating, impossible geometry, Escher-like"
Products: "reflections of photographer, fingerprints, dust, scratches"
Food: "unappetizing, spoiled, artificial plastic-looking"
```

## Prompt Templates

### Template 1: Product/App Screenshot

```
[product description] on a [device] with [background context],
clean UI design, product photography style, [lighting],
[color palette], sharp focus, highly detailed, 8K

Example:
"A modern AI chatbot interface on a MacBook Pro on a wooden desk
in a sunlit co-working space, clean UI with glass morphism design,
product photography style, natural window lighting, warm tones,
sharp focus, highly detailed, 8K"
```

### Template 2: Social Media Thumbnail

```
[subject] with [expression/action], [background style],
bold composition, vibrant colors, eye-catching, designed for
social media thumbnail, [aspect ratio], high contrast

Example:
"A surprised young professional looking at a laptop screen showing
dramatic AI-generated results, neon-lit dark background,
bold composition, vibrant cyan and magenta, eye-catching,
designed for YouTube thumbnail, 16:9, high contrast, dramatic lighting"
```

### Template 3: Brand/Business Illustration

```
[scene description] in [art style], [brand color palette],
professional and polished, [mood], suitable for [use case],
consistent brand aesthetic

Example:
"A diverse remote team collaborating via holographic screens
in a minimalist modern office, flat vector illustration style,
blue and teal brand palette with orange accents, professional
and optimistic, suitable for SaaS landing page hero, consistent
brand aesthetic"
```

## Prompt Iteration Workflow

```
1. WRITE → Start with the structure formula
2. GENERATE → Get 2-4 variations
3. DIAGNOSE → What's wrong?
   - Wrong subject? → Strengthen subject description
   - Wrong style? → Add style keywords and artist reference
   - Wrong composition? → Add camera angle, framing, focal length
   - Artifacts? → Add to negative prompt
4. REFINE → Adjust the weakest element
5. REPEAT → 2-3 iterations max before trying a different approach
```

## Model Selection Guide

| Use Case | Recommended Model | Why |
|----------|------------------|-----|
| Quick iteration, drafts | Nano Banana 2 (fal.ai) | Fast, cheap |
| Production images, typography | Nano Banana Pro (fal.ai) | High fidelity |
| Artistic, creative | Midjourney v6.1 | Best aesthetics |
| Text rendering in images | DALL-E 3 | Best text accuracy |
| Photorealistic people | Midjourney / Nano Banana Pro | Natural faces |
| Consistent character design | Midjourney (--cref) or Stable Diffusion (LoRA) | Reference consistency |

## Key Principles

- **Structure beats vagueness** — A structured prompt beats a long rambling one
- **Subject first, style second** — Nail what's in the image before worrying about how it looks
- **Negative prompts prevent, don't fix** — Good prompts shouldn't need 20 negative terms
- **Model matters** — A Midjourney prompt won't work verbatim on DALL-E

## Verification Checklist

- [ ] Prompt follows the structure formula (Subject → Context → Style → Lighting → Composition)
- [ ] Style keywords are specific (not just "beautiful" or "nice")
- [ ] Negative prompt addresses likely issues for the subject type
- [ ] Aspect ratio specified for the intended use
- [ ] Model-appropriate syntax used (parameters, weights, etc.)

## Examples

```
Input: "帮我写一个AI产品发布会的配图prompt"

Output:
"Futuristic product launch stage with a holographic AI assistant
projected center stage, audience of diverse tech professionals in
silhouette, dramatic stage lighting with cyan and purple beams,
wide establishing shot, cyberpunk-inspired but clean and corporate,
photorealistic 3D render, octane render style, volumetric lighting,
8K resolution, ultra detailed, 16:9 aspect ratio"

Negative: "crowded, messy, low light, blurry, text artifacts, watermark"
```

## Related Skills

- [[csp-fal-ai-media]] — fal.ai image/video/audio generation
- [[csp-poster]] — 营销海报生成（含材质提示词库）
- [[csp-creator-thumbnail]] — 封面图/缩略图设计（使用本 skill 的 prompt 模板）
- [[csp-frontend-design]] — 前端设计实现