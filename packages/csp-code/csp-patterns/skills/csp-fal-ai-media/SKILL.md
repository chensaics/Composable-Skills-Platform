---
name: csp-fal-ai-media
description: >
  Unified AI media generation — image, video, and audio. Two providers:
  fal.ai MCP (Nano Banana for images, Seedance/Kling/Veo 3 for video,
  CSM-1B/ThinkSound for audio) and Google Gemini API (Gemini 3 Pro Image
  for text-to-image with batch generation). Includes creator workflows for
  logo/banner design (batch iterate → preview → select → finalize).
  Use when the user wants to generate images, videos, audio, logos, or
  banners with AI.
  Keywords: generate image, generate video, generate audio, create logo,
  create banner, AI image, AI video, text-to-image, text-to-speech,
  Gemini, fal.ai, Nano Banana, 图片生成, 视频生成, 音频生成.
layer: 3
category: patterns
domain: patterns
phase: build
version: "2.0.0"
role: specialist
scope: implementation
tools: [Read, Write, Edit, Bash, Glob, Grep]
related_skills:
  - csp-creator-image-prompt
  - csp-beautiful-article
triggers:
  keywords: ["generate image", "generate video", "generate audio",
    "create logo", "create banner", "AI image", "AI video", "text-to-image",
    "text-to-speech", "Gemini", "fal.ai", "图片生成", "视频生成", "音频生成",
    "logo design", "banner design"]
  intents:
    - "user wants to generate images/videos/audio with AI"
    - "user wants to create a logo or banner"
    - "user needs batch image generation for design iteration"
---

# AI Media Generation

统一 AI 媒体生成——图片、视频、音频，双 provider 支持。

## Purpose

通过 fal.ai MCP 和 Google Gemini API 提供全面的 AI 媒体生成能力，覆盖图片、视频、音频三大媒体类型，并内置 Logo/Banner 创建工作流。

## When to Use

- ✅ 用 AI 生成图片（照片、插画、像素画、Logo、Banner）
- ✅ 文字/图片转视频
- ✅ 文字转语音
- ✅ 视频转音频
- ✅ 需要批量生成图片进行设计迭代
- ✅ 创建 Logo 或 Banner 等视觉资产
- ❌ 需要真人出镜的专业视频拍摄
- ❌ 需要特定品牌字体的精确排版（AI 文本渲染有限）

## Providers

| Provider | 接入方式 | 擅长 | 限制 |
|----------|---------|------|------|
| **fal.ai** | MCP | 图片（Nano Banana 2/Pro）、视频（Seedance/Kling/Veo 3）、音频（CSM-1B/ThinkSound） | 需要 fal.ai API key |
| **Gemini** | REST API | 图片生成（Gemini 3 Pro Image）、批量变体 | 需要 GEMINI_API_KEY；需确认网络可达性 |

---

## Part 1: Image Generation

### Provider A: fal.ai (MCP)

#### Nano Banana 2 (Fast, Low Cost)
Best for: quick iterations, drafts, image editing.

```
generate(
  model_name: "fal-ai/nano-banana-2",
  input: {
    "prompt": "a futuristic cityscape at sunset, cyberpunk style",
    "image_size": "landscape_16_9",
    "num_images": 1,
    "seed": 42
  }
)
```

#### Nano Banana Pro (High Fidelity)
Best for: production images, realism, typography, detailed prompts.

```
generate(
  model_name: "fal-ai/nano-banana-pro",
  input: {
    "prompt": "professional product photo, studio lighting",
    "image_size": "square",
    "num_images": 1,
    "guidance_scale": 7.5
  }
)
```

#### Image Editing

```
upload(file_path: "/path/to/image.png")
generate(
  model_name: "fal-ai/nano-banana-2",
  input: {
    "prompt": "same scene but in watercolor style",
    "image_url": "<uploaded_url>",
    "image_size": "landscape_16_9"
  }
)
```

### Provider B: Gemini 3 Pro Image (REST API)

Set `GEMINI_API_KEY` in environment (from [Google AI Studio](https://aistudio.google.com/apikey)).

**Generate single image:**
```bash
python3 scripts/gemini_generate.py "a cute robot mascot, pixel art style" \
  --ratio 1:1 -o robot.png
```

**Batch generate variations (essential for design iteration):**
```bash
python3 scripts/gemini_batch.py "pixel art logo for SaaS product" \
  -n 20 --ratio 1:1 -d ./outputs -p logo --delay 3
```

**Image editing with Gemini:**
```bash
python3 scripts/gemini_generate.py "make the background blue" \
  -i input.png -o output.png
```

**Supported aspect ratios for Gemini:**
`1:1` | `2:3` | `3:2` | `4:3` | `3:4` | `16:9` | `9:16` | `21:9`

**Image sizes:** standard | `2K` | `4K`

### Common Image Parameters

| Param | Type | Values | Notes |
|-------|------|--------|-------|
| `prompt` | string | required | Describe what you want |
| `image_size` | string | `square`, `landscape_16_9`, `portrait_16_9`, etc. | Aspect ratio |
| `num_images` | number | fal.ai: 1-4, Gemini: 1 per API call | Batch via script |
| `seed` | number | any integer | Reproducibility |
| `guidance_scale` | number | 1-20 (fal.ai only) | Prompt adherence |

---

## Part 2: Creator Workflows

### Logo Creation Workflow（5步法）

**Step 1: Discovery** — 收集需求
- 品牌/项目名称，风格偏好（像素画/极简/3D/吉祥物/字母标），色彩偏好，参考图

**Step 2: Batch Generate** — 生成 20 张变体
```bash
# fal.ai 方式 (需要多次调用)
# Gemini 方式 (推荐)
python3 scripts/gemini_batch.py "{style} logo for {brand}, {description}" \
  -n 20 --ratio 1:1 -d .output/logo-iter1 -p logo
```

**Step 3: Preview** — 生成 HTML 预览页供人工选择
```html
<!-- 复制 preview.html 模板，更新图片列表 -->
```

**Step 4: Iterate** — 基于选中的变体（如 #3, #7, #15）再生成 10-20 张
```bash
python3 scripts/gemini_batch.py "{refined style based on #3,#7,#15}" \
  -n 15 --ratio 1:1 -d .output/logo-iter2 -p logo-v2
```

**Step 5: Finalize** — 确认最终版本，后期处理
- Crop 留白 → Remove BG → Vectorize (SVG)

### Banner Creation Workflow（5步法）

与 Logo 流程相同，但：
- 生成比例用 `21:9`（最宽），之后 crop 到目标尺寸
- 目标尺寸：GitHub README `2:1` (1280x640) | Twitter header `3:1` (1500x500) | Web hero `16:9` (1920x1080)

---

## Part 3: Prompt Engineering

### Prompt 结构（5要素）

1. **Subject** — 主体：生成什么
2. **Style** — 风格：像素画/写实/插画/极简/3D
3. **Details** — 细节：光照、色彩、构图
4. **Quality** — 质量提示：high resolution, 4K, professional, sharp focus
5. **Format** — 格式约束：square format, centered composition, no text

### 风格速查

| 风格 | Prompt 关键修饰词 |
|------|-----------------|
| 像素画 | `pixel art, 8-bit retro, limited color palette, crisp pixels` |
| 写实 | `professional photograph, studio lighting, 85mm lens, sharp focus` |
| 极简 | `minimalist, flat design, clean lines, simple shapes, modern aesthetic` |
| 3D/等距 | `3D render, isometric view, low poly, soft shadows, pastel` |
| 插画 | `digital illustration, vibrant, detailed, storybook quality` |
| 抽象 | `abstract, flowing shapes, high contrast, artistic composition` |

详见 `references/prompt-patterns.md`

---

## Part 4: Video Generation

### Seedance 1.0 Pro (ByteDance)
```
generate(model_name: "fal-ai/seedance-1-0-pro", input: {
  "prompt": "a drone flyover of a mountain lake at golden hour, cinematic",
  "duration": "5s", "aspect_ratio": "16:9", "seed": 42
})
```

### Kling Video v3 Pro
```
generate(model_name: "fal-ai/kling-video/v3/pro", input: {
  "prompt": "ocean waves crashing on rocky coast, dramatic clouds",
  "duration": "5s", "aspect_ratio": "16:9"
})
```

### Veo 3 (Google DeepMind)
```
generate(model_name: "fal-ai/veo-3", input: {
  "prompt": "bustling Tokyo street market at night, neon signs",
  "aspect_ratio": "16:9"
})
```

### Image-to-Video
```
generate(model_name: "fal-ai/seedance-1-0-pro", input: {
  "prompt": "camera slowly zooms out, gentle wind",
  "image_url": "<uploaded_image_url>", "duration": "5s"
})
```

---

## Part 5: Audio Generation

### CSM-1B (TTS)
```
generate(model_name: "fal-ai/csm-1b", input: {
  "text": "Hello, let me show you how this works.", "speaker_id": 0
})
```

### ThinkSound (Video-to-Audio)
```
generate(model_name: "fal-ai/thinksound", input: {
  "video_url": "<video_url>",
  "prompt": "ambient forest sounds with birds chirping"
})
```

### ElevenLabs (via API)
```python
import os, requests
resp = requests.post(
    f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
    headers={"xi-api-key": os.environ["ELEVENLABS_API_KEY"]},
    json={"text": "...", "model_id": "eleven_turbo_v2_5"}
)
```

---

## Tips

- **迭代策略**：先用低成本模型（Nano Banana 2）快速尝试 prompt，满意后切换 Pro
- **批量生成**：设计类任务一次生成 20 张变体，再人工挑选最好的 2-3 张深入迭代
- **Seed 固定**：微调 prompt 时固定 seed，确保可控比较
- **视频成本**：用 `estimate_cost` 预估费用再生成
- **Image-to-Video**：比纯文本生成视频更可控

## Related Skills

- [[csp-creator-image-prompt]] — 图片 prompt 工程和风格指南
- [[csp-beautiful-article]] — 高质量内容创作（含配图）
- [[csp-creator-thumbnail]] — 缩略图生成