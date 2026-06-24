#!/usr/bin/env node
const fs = require('fs')

let data = {}
try {
  data = JSON.parse(fs.readFileSync(0, 'utf8'))
} catch {}

const model = data.model?.display_name || 'Claude'
const transcript = data.transcript_path

let contextTokens = 0
if (transcript && fs.existsSync(transcript)) {
  const lines = fs.readFileSync(transcript, 'utf8').trim().split('\n')
  for (let i = lines.length - 1; i >= 0; i--) {
    let entry
    try {
      entry = JSON.parse(lines[i])
    } catch {
      continue
    }
    if (entry.isSidechain) continue
    const usage = entry.message?.usage
    if (entry.type === 'assistant' && usage) {
      contextTokens =
        (usage.input_tokens || 0) +
        (usage.cache_read_input_tokens || 0) +
        (usage.cache_creation_input_tokens || 0)
      break
    }
  }
}

const limit =
  data.exceeds_200k_tokens || contextTokens > 200000 ? 1000000 : 200000
const pct = Math.round((contextTokens / limit) * 100)
const usedK = Math.round(contextTokens / 1000)
const limitK = Math.round(limit / 1000)

const color = pct > 85 ? '\x1b[31m' : pct > 60 ? '\x1b[33m' : '\x1b[2m'
const reset = '\x1b[0m'

process.stdout.write(
  `\x1b[2m${model}${reset} ${color}ctx ${usedK}k/${limitK}k (${pct}%)${reset}`,
)
