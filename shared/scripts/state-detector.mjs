// shared/scripts/state-detector.mjs
// Pre-router hook: detect project state and inject context for routing

import { execSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, resolve } from 'node:path';

// Parse the YAML configuration using regex - simplified approach for our specific format
function parseYAML(yamlStr) {
  const result = {
    git: {},
    tech_stack: { indicators: {} },
    phase: { signals: {} },
    test_status: {}
  };

  // Extract git section
  const gitSection = yamlStr.match(/git:\s*\n((?:\s+.+\n?)+?)(?=\n\w|$)/);
  if (gitSection) {
    // Extract command
    const commandMatch = gitSection[1].match(/command:\s*"([^"]+)"/);
    if (commandMatch) result.git.command = commandMatch[1];

    // Extract states
    result.git.states = {};
    const statesSection = gitSection[1].match(/states:\s*\n((?:\s+.+\n?)+?)(?=\n\s*\w+:|$)/);
    if (statesSection) {
      const statesLines = statesSection[1].split('\n');
      let currentState = null;
      for (const line of statesLines) {
        const stateMatch = line.match(/^\s*(\w+):\s*$/);
        if (stateMatch) {
          currentState = stateMatch[1];
          result.git.states[currentState] = {};
        } else if (currentState) {
          const patternMatch = line.match(/\s*pattern:\s*"([^"]+)"/);
          const descMatch = line.match(/\s*description:\s*"([^"]+)"/);
          if (patternMatch) result.git.states[currentState].pattern = patternMatch[1];
          if (descMatch) result.git.states[currentState].description = descMatch[1];
        }
      }
    }
  }

  // Extract tech_stack section
  const techStackSection = yamlStr.match(/tech_stack:\s*\n((?:\s+.+\n?)+?)(?=\n\w|$)/);
  if (techStackSection) {
    const indicatorsSection = techStackSection[1].match(/indicators:\s*\n((?:\s+.+\n?)+?)(?=\n\s*\w+:|$)/);
    if (indicatorsSection) {
      const lines = indicatorsSection[1].split('\n');
      let currentLang = null;
      let currentProperty = null;

      for (const line of lines) {
        const langMatch = line.match(/^\s*(\w+):\s*$/);
        if (langMatch) {
          currentLang = langMatch[1];
          result.tech_stack.indicators[currentLang] = {};
        } else if (currentLang) {
          const filesMatch = line.match(/\s*files:\s*\[(.*)\]/);
          const confMatch = line.match(/\s*confidence:\s*([\d.]+)/);
          const globMatch = line.match(/\s*glob:\s*\[(.*)\]/);

          if (filesMatch) {
            result.tech_stack.indicators[currentLang].files = filesMatch[1]
              .split(',')
              .map(item => item.trim().replace(/"/g, '').replace(/'/g, ''))
              .filter(item => item.length > 0);
          }
          if (confMatch) {
            result.tech_stack.indicators[currentLang].confidence = parseFloat(confMatch[1]);
          }
          if (globMatch) {
            result.tech_stack.indicators[currentLang].glob = globMatch[1]
              .split(',')
              .map(item => item.trim().replace(/"/g, '').replace(/'/g, ''))
              .filter(item => item.length > 0);
          }
        }
      }
    }
  }

  // Extract phase section
  const phaseSection = yamlStr.match(/phase:\s*\n((?:\s+.+\n?)+?)(?=\n\w|$)/);
  if (phaseSection) {
    const signalsSection = phaseSection[1].match(/signals:\s*\n((?:\s+.+\n?)+?)(?=\n\s*\w+:|$)/);
    if (signalsSection) {
      const lines = signalsSection[1].split('\n');
      let currentPhase = null;

      for (const line of lines) {
        const phaseMatch = line.match(/^\s*(\w+):\s*$/);
        if (phaseMatch) {
          currentPhase = phaseMatch[1];
          result.phase.signals[currentPhase] = {};
        } else if (currentPhase) {
          const filesMatch = line.match(/\s*files:\s*\[(.*)\]/);
          const weightMatch = line.match(/\s*weight:\s*([\d.]+)/);

          if (filesMatch) {
            result.phase.signals[currentPhase].files = filesMatch[1]
              .split(',')
              .map(item => item.trim().replace(/"/g, '').replace(/'/g, ''))
              .filter(item => item.length > 0);
          }
          if (weightMatch) {
            result.phase.signals[currentPhase].weight = parseFloat(weightMatch[1]);
          }
        }
      }
    }
  }

  // Extract test_status section
  const testStatusSection = yamlStr.match(/test_status:\s*\n((?:\s+.+\n?)+?)(?=\n\w|$)/);
  if (testStatusSection) {
    const cmdMatch = testStatusSection[1].match(/command:\s*"([^"]+)"/);
    const fallbackMatch = testStatusSection[1].match(/fallback:\s*"([^"]+)"/);

    if (cmdMatch) result.test_status.command = cmdMatch[1];
    if (fallbackMatch) result.test_status.fallback = fallbackMatch[1];
  }

  return result;
}

const PROJECT_ROOT = process.env.CLAUDE_PROJECT_DIR || process.cwd();
// Config ships with the router data, not with the target project: resolve
// relative to this script (shared/scripts → repo root → csp-router), with a
// project-root copy as fallback for custom installs.
const CONFIG_PATH = [
  resolve(import.meta.dirname, '..', '..', 'csp-router', 'state-config.yaml'),
  resolve(PROJECT_ROOT, 'csp-router', 'state-config.yaml'),
].find(p => existsSync(p));

function loadConfig() {
  try {
    const raw = readFileSync(CONFIG_PATH, 'utf8');
    return parseYAML(raw);
  } catch (error) {
    console.error('Failed to load config:', error.message);
    return null;
  }
}

function run(cmd, timeout = 2000) {
  try {
    return execSync(cmd, { cwd: PROJECT_ROOT, timeout, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch {
    return '';
  }
}

function detectGitState(config) {
  const output = run(config.git.command);
  for (const [state, { pattern }] of Object.entries(config.git.states)) {
    if (new RegExp(pattern, 'm').test(output)) return state;
  }
  if (output) return 'dirty';
  // Empty output means clean only inside a git repo; otherwise unknown.
  return existsSync(join(PROJECT_ROOT, '.git')) ? 'clean' : 'unknown';
}

function detectTechStack(config) {
  const stacks = [];
  for (const [lang, { files, confidence, glob }] of Object.entries(config.tech_stack.indicators)) {
    const conf = typeof confidence === 'number' ? confidence : 0.5;
    if (Array.isArray(files) && files.some(f => existsSync(join(PROJECT_ROOT, f)))) {
      stacks.push({ lang, confidence: conf });
    } else if (Array.isArray(glob)) {
      const matched = glob.some(g => run(`ls ${g} 2>/dev/null | head -1`));
      if (matched) stacks.push({ lang, confidence: conf * 0.8 });
    }
  }
  // Sort by confidence desc, return top match
  stacks.sort((a, b) => b.confidence - a.confidence);
  return stacks;
}

function detectPhase(config) {
  const phases = [];
  for (const [phase, { files, weight }] of Object.entries(config.phase.signals)) {
    if (!Array.isArray(files)) continue;
    const found = files.some(f => existsSync(join(PROJECT_ROOT, f)));
    if (found) phases.push({ phase, weight: typeof weight === 'number' ? weight : 0 });
  }
  phases.sort((a, b) => b.weight - a.weight);
  return phases[0]?.phase || 'building'; // default
}

function detectTestStatus(config) {
  if (!config.test_status?.command) return 'unknown';
  try {
    const raw = run(config.test_status.command);
    if (!raw || raw.includes('unknown')) return 'unknown';
    const data = JSON.parse(raw);
    return data.status || 'unknown';
  } catch {
    return config.test_status.fallback || 'unknown';
  }
}

async function main() {
  const config = loadConfig();
  if (!config) {
    console.log('[state] config not found - skipping'); // For debugging
    process.exit(0); // No config = skip silently
  }

  const state = {
    git_status: detectGitState(config),
    tech_stack: detectTechStack(config),
    phase: detectPhase(config),
    test_status: detectTestStatus(config),
    detected_at: new Date().toISOString(),
  };

  // Write to .csp/state.json for other hooks to read
  const statePath = join(PROJECT_ROOT, '.csp', 'state.json');
  try {
    mkdirSync(join(PROJECT_ROOT, '.csp'), { recursive: true });
    writeFileSync(statePath, JSON.stringify(state, null, 2));
  } catch {
    // Non-fatal
  }

  // Output context hint for the agent
  const topStack = state.tech_stack[0]?.lang || 'unknown';
  const hints = [
    `[state] git=${state.git_status}`,
    `lang=${topStack}`,
    `phase=${state.phase}`,
  ];
  if (state.test_status !== 'unknown') hints.push(`tests=${state.test_status}`);
  console.log(hints.join(' | '));
}

main().catch((error) => {
  console.error('State detector error:', error);
  process.exit(0);
});