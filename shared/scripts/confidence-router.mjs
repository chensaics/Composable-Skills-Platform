// shared/scripts/confidence-router.mjs
// Confidence scoring router: keyword + intent + context → ranked skills
// Runs standalone (argv / CLAUDE_USER_PROMPT) or as a UserPromptSubmit hook
// (prompt arrives via stdin JSON payload).

import { readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { parseSimpleYaml } from './lib/yaml.mjs';

const PROJECT_ROOT = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const CSP_ROOT = resolve(import.meta.dirname, '..', '..', 'csp-router');

function loadYaml(file) {
  try {
    return parseSimpleYaml(readFileSync(join(CSP_ROOT, file), 'utf8'));
  } catch {
    return null;
  }
}

function loadState() {
  try {
    return JSON.parse(readFileSync(join(PROJECT_ROOT, '.csp', 'state.json'), 'utf8'));
  } catch {
    return { git_status: 'unknown', tech_stack: [], phase: 'building' };
  }
}

function readInput() {
  const fromEnv = process.env.CLAUDE_USER_PROMPT || process.argv.slice(2).join(' ');
  if (fromEnv) return fromEnv;
  // Hook context: UserPromptSubmit payload is JSON on stdin.
  if (!process.stdin.isTTY) {
    try {
      const payload = JSON.parse(readFileSync(0, 'utf8'));
      return payload.prompt || '';
    } catch {
      return '';
    }
  }
  return '';
}

function addScore(scores, skill, value) {
  scores[skill] = (scores[skill] || 0) + value;
}

function keywordScore(input, triggers) {
  const lower = input.toLowerCase();
  const scores = {};

  for (const [keyword, entry] of Object.entries(triggers.trigger_index || {})) {
    const skills = entry?.skills;
    const weight = Number(entry?.weight) || 0;
    if (!Array.isArray(skills) || skills.length === 0) continue;
    if (lower.includes(keyword.toLowerCase())) {
      for (const skill of new Set(skills)) {
        addScore(scores, skill, weight / 50); // Normalize to 0-1
      }
    }
  }
  return scores;
}

function matchPattern(input, pattern) {
  // Patterns may be plain substrings or regexes (e.g. "re\\s*factor",
  // "production.*issue"). Try regex first, fall back to substring.
  try {
    return new RegExp(pattern, 'i').test(input);
  } catch {
    return input.toLowerCase().includes(String(pattern).toLowerCase());
  }
}

function intentScore(input, triggers) {
  const scores = {};

  for (const [, entry] of Object.entries(triggers.intent_patterns || {})) {
    const patterns = entry?.patterns;
    const skills = entry?.skills;
    const weight = Number(entry?.weight) || 0;
    if (!Array.isArray(patterns) || !Array.isArray(skills)) continue;
    if (patterns.some(p => matchPattern(input, p))) {
      for (const skill of new Set(skills)) {
        addScore(scores, skill, weight / 50);
      }
    }
  }
  return scores;
}

function contextScore(metadata, state) {
  const scores = {};
  if (!metadata?.skills) return scores;

  const currentPhase = state.phase;
  const topLang = state.tech_stack?.[0]?.lang;

  for (const [skill, meta] of Object.entries(metadata.skills)) {
    // Phase match bonus
    if (meta.phase && meta.phase === currentPhase) {
      addScore(scores, skill, 0.2);
    }

    // Tech stack match bonus
    if (meta.domain === 'language' && topLang) {
      if (skill.toLowerCase().includes(topLang.toLowerCase())) {
        addScore(scores, skill, 0.15);
      }
    }

    // Git state bonuses
    if (state.git_status === 'dirty' && skill.includes('debug')) {
      addScore(scores, skill, 0.1);
    }
    if (state.git_status === 'conflict' && (skill.includes('git-recovery') || skill.includes('merge'))) {
      addScore(scores, skill, 0.15);
    }
  }
  return scores;
}

function capScores(map) {
  return Object.fromEntries(Object.entries(map).map(([k, v]) => [k, Math.min(v, 1)]));
}

function mergeScores(...scoreMaps) {
  const merged = {};
  for (const map of scoreMaps) {
    for (const [skill, score] of Object.entries(map)) {
      merged[skill] = (merged[skill] || 0) + score;
    }
  }
  return merged;
}

function main() {
  const input = readInput();
  if (!input) return;

  const triggers = loadYaml('triggers.yaml');
  const metadata = loadYaml('skill-metadata.yaml');
  const state = loadState();

  if (!triggers) return;

  // Component scores, each capped at 1 before weighting
  const kwScores = capScores(keywordScore(input, triggers));
  const intentScores = capScores(intentScore(input, triggers));
  const ctxScores = capScores(contextScore(metadata, state));

  const final = mergeScores(
    Object.fromEntries(Object.entries(kwScores).map(([k, v]) => [k, v * 0.4])),
    Object.fromEntries(Object.entries(intentScores).map(([k, v]) => [k, v * 0.3])),
    Object.fromEntries(Object.entries(ctxScores).map(([k, v]) => [k, v * 0.3]))
  );

  const ranked = Object.entries(final)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5);

  if (ranked.length === 0) return;

  const lines = ranked.map(([skill, score], i) => {
    const confidence = Math.min(Math.round(score * 100), 99);
    const meta = metadata?.skills?.[skill] || {};
    const phaseTag = meta.phase ? ` [${meta.phase}]` : '';
    return `  ${i + 1}. ${skill}${phaseTag} — ${confidence}%`;
  });

  console.log('[router] Confidence-ranked skills:');
  console.log(lines.join('\n'));

  const topScore = ranked[0]?.[1] || 0;
  if (topScore > 0.8) {
    console.log(`[router] Decision: Direct route → ${ranked[0][0]}`);
  } else if (topScore > 0.5) {
    console.log(`[router] Decision: Top 3 candidates — user should confirm`);
  } else {
    console.log(`[router] Decision: Low confidence — consider /csp-interview-me`);
  }
}

main();