---
name: csp-creator-podcast
description: >
  Use when creating podcast/audio content — from episode planning and scripting
  through recording setup, AI voice synthesis, editing, show notes, and publishing
  to platforms (小宇宙/Apple Podcasts/Spotify/喜马拉雅). Covers solo shows,
  interview formats, and AI-generated podcasts. Keywords: 播客, podcast, 音频创作,
  audio content, 录音, recording, 剪辑, audio editing, 小宇宙, 喜马拉雅, Apple
  Podcasts, Spotify, TTS, AI语音, show notes.
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
  - csp-creator-content-strategy
  - csp-creator-publish-pipeline
  - csp-article-writing
triggers:
  keywords: ["播客", "podcast", "音频创作", "录音", "音频剪辑", "audio editing",
             "小宇宙", "喜马拉雅", "Apple Podcasts", "Spotify", "AI语音",
             "show notes", "节目", "电台"]
  intents:
    - "user wants to start a podcast"
    - "user needs podcast episode planning"
    - "user wants to create AI-generated audio content"
---

# Podcast & Audio Content Creation

Create podcast episodes — from concept to published show.

## Purpose

Podcasts are the fastest-growing content format for deep engagement. This skill covers the full production pipeline: episode planning, scripting, recording (live or AI voice), editing, show notes, and platform publishing — for both traditional interview/solo shows and AI-generated podcasts.

## When to Use

- ✅ Starting a new podcast — format, branding, setup
- ✅ Planning and scripting an episode
- ✅ AI voice synthesis for narration or full episodes
- ✅ Editing raw audio into a polished episode
- ✅ Writing show notes and publishing
- ❌ Short-form video voiceover only (use `csp-creator-short-video`)
- ❌ Music production (different domain)

## Podcast Formats

Choose your format before production:

| Format | Length | Prep Time | Best For |
|--------|--------|-----------|----------|
| **Solo monologue** | 15-30 min | 1-2 hours scripting | Thought leadership, tutorials |
| **Interview** | 30-60 min | 30 min prep + guest coordination | Conversations, networking |
| **Co-hosted** | 30-60 min | Shared prep | Chemistry-driven shows |
| **Narrative/Storytelling** | 20-40 min | 4-8 hours research + scripting | Deep dives, documentaries |
| **AI-Generated** | 5-15 min | Script + TTS only | Rapid content, news summaries |
| **Roundtable (3+ people)** | 45-90 min | Minimal per-person prep | Debates, panel discussions |

## Process

### Step 1: Episode Planning (3 min)

For each episode, define:

```yaml
episode_plan:
  title: "EP01: [Hook-driven title]"
  format: solo | interview | co-hosted | narrative
  duration_target: "25 min"
  core_topic: "One sentence — the single thing this episode is about"
  segments:
    - name: "Cold Open"
      duration: "1-2 min"
      content: "Grab attention — a question, stat, or story"
    - name: "Main Discussion"
      duration: "15-20 min"
      content: "3-5 key points, structured progression"
    - name: "Takeaways"
      duration: "3-5 min"
      content: "Actionable summary, what the listener should do"
    - name: "Outro + CTA"
      duration: "1-2 min"
      content: "Subscribe/follow ask, next episode teaser"
  guest:
    name: ""
    bio: ""
    questions: []  # 5-8 prepared questions
```

### Step 2: Scripting (5 min)

**Solo episode script structure:**

```markdown
# [Episode Title]

## Cold Open (0:00-1:30)
[HOOK]: "Did you know that [surprising fact]?"
[PROMISE]: "Today I'm going to show you [what they'll learn]."

## Segment 1: [Key Point 1] (1:30-8:00)
- State the point
- Give an example or story
- Explain why it matters

## Segment 2: [Key Point 2] (8:00-15:00)
...

## Segment 3: [Key Point 3] (15:00-20:00)
...

## Takeaways & Outro (20:00-25:00)
- 3 things to remember
- 1 thing to do
- Subscribe + next episode tease
```

**Interview episode question guide:**

```
1. Icebreaker (2 min): "Tell me about [something personal but relevant]"
2. Origin story (5 min): "How did you get into [their field]?"
3. Deep dive (15 min): 3-5 questions on their expertise
4. Hot take (5 min): "What's something you believe that most people disagree with?"
5. Practical advice (5 min): "What should someone starting out do first?"
6. Rapid fire (3 min): 3-5 quick questions
7. Wrap (2 min): "Where can people find you?"
```

### Step 3: Recording Setup

**Hardware minimums:**

| Level | Mic | Interface | Room | Budget |
|-------|-----|-----------|------|--------|
| Beginner | USB mic (Blue Yeti/Snowball) | None (USB direct) | Quiet room | ¥500-1000 |
| Intermediate | XLR mic + audio interface | Focusrite Scarlett | Basic treatment | ¥2000-4000 |
| Professional | Shure SM7B + Cloudlifter | RODEcaster Pro | Treated room | ¥8000+ |

**Recording software:**
- **Audacity** (free, cross-platform)
- **GarageBand** (free, Mac)
- **Adobe Audition** (pro, paid)
- **Descript** (AI-powered, transcript-based editing)
- ** Riverside.fm** (remote recording, studio quality)

**Recording checklist:**
- [ ] Close windows, doors, and noise sources
- [ ] Test record 30s, check levels (-12 dB to -6 dB target)
- [ ] Phone on silent, notifications off
- [ ] Water nearby (no ice — clinking sound)
- [ ] Record 10s of "room tone" for noise reduction in post

### Step 4: Editing & Production

**Basic editing workflow (Audacity/Descript):**

```
1. Import raw audio
2. Noise reduction: Apply room tone sample
3. Cut silences and filler words (um, uh, you know)
4. Normalize to -16 LUFS (podcast standard)
5. Add intro/outro music (royalty-free: Epidemic Sound, Artlist)
6. Add chapter markers
7. Export: MP3, 128 kbps, mono, 44100 Hz
```

**AI Voice Synthesis** (for AI-generated episodes):

Use `csp-fal-ai-media` for TTS, or dedicated services:

| Service | Quality | Languages | Cost |
|---------|---------|-----------|------|
| ElevenLabs | Highest | 29 languages | ~$5/month |
| CSM-1B (fal.ai) | Conversational | English | Per-use |
| 剪映/CapCut TTS | Good | 中文, English | Free |
| Azure TTS | Very good | 100+ languages | ~$0.016/min |

### Step 5: Show Notes & Publishing

**Show notes template:**

```markdown
---
episode: EP01
title: "[Title]"
published: YYYY-MM-DD
duration: "25 min"
---

## Episode Summary
[3-4 sentences — what this episode covers and why listen]

## Timestamps
- 00:00 — Cold open
- 01:30 — [Segment 1 title]
- 08:00 — [Segment 2 title]
- 15:00 — [Segment 3 title]
- 20:00 — Takeaways
- 23:00 — Outro

## Key Takeaways
1. [Takeaway 1]
2. [Takeaway 2]
3. [Takeaway 3]

## Links & Resources
- [Link 1]: [Description]
- [Link 2]: [Description]

## Guest Info
- Name: [Guest name]
- Social: [Links]
- Their work: [Description]
```

**Publishing platforms:**

| Platform | Audience | Best For |
|----------|----------|----------|
| 小宇宙 | Chinese podcast listeners | 中文播客首选 |
| 喜马拉雅 | Mass market Chinese audience | Broad reach |
| Apple Podcasts | Global, iOS users | International distribution |
| Spotify | Global, discovery algorithm | Music + podcast crossover |
| 荔枝FM | Chinese audio community | Live audio, community |

**Publishing workflow:**
1. Upload audio to podcast host (Anchor/Transistor/Buzzsprout)
2. Add show notes and timestamps
3. Set publish date/time
4. Host distributes to Apple/Spotify automatically
5. Manually publish to Chinese platforms (小宇宙/喜马拉雅)

## Key Principles

- **Audio-first thinking** — Describe visuals; listeners can't see your screen
- **One episode, one big idea** — Depth over breadth; don't cram too much
- **Good audio > good content** — Bad audio makes people leave before they hear your ideas
- **Show notes are SEO** — Well-written show notes drive discovery

## Verification Checklist

- [ ] Episode plan complete (format, segments, duration target)
- [ ] Script or question list prepared
- [ ] Audio recorded at proper levels (-12 to -6 dB)
- [ ] Edited: noise reduced, silences cut, normalized to -16 LUFS
- [ ] Intro/outro music added (royalty-free, properly licensed)
- [ ] Show notes written with timestamps
- [ ] Export: MP3, 128 kbps, mono, 44100 Hz
- [ ] Published to target platforms

## Examples

### Example: Start an AI tools podcast

```
Input: "帮我在小宇宙开一个AI工具推荐的播客"

Process:
  1. Format: Solo monologue, 20 min, weekly
  2. Branding: "AI工具说明书" — practical, no-hype AI tool reviews
  3. Episode 1 plan:
     Title: "EP01: 我用AI工具替代了3个付费软件，每个月省了500块"
     Segments:
       - Cold open: "你有没有算过，你每个月花在软件订阅上的钱？"
       - Main: Review 3 free AI alternatives to paid tools
       - Takeaways: Total savings, setup guide
       - Outro: Next episode tease

  Recording: USB mic + Audacity + quiet room
  Editing: Descript (AI transcription + filler word removal)
  Publishing: 小宇宙 + Apple Podcasts via Anchor

Output:
  ✅ Episode script ready
  ✅ Recording setup guide
  ✅ Show notes template
  ✅ Publishing checklist
```

## Related Skills

- [[csp-fal-ai-media]] — AI 语音合成（CSM-1B, ElevenLabs）
- [[csp-creator-content-strategy]] — 播客内容日历和选题
- [[csp-creator-publish-pipeline]] — 多平台发布
- [[csp-article-writing]] — 节目笔记/文案撰写
- [[csp-video-editing]] — 视频编辑技能（如需视频版播客）