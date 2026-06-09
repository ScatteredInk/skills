#!/usr/bin/env bash
# check-setup.sh — nudge to run /setup-matt-pocock-skills when a repo that uses
# the engineering-skills workflow hasn't been configured yet. Silent otherwise.
#
# Designed for a SessionStart hook (fires every session, regardless of whether a
# skill is invoked — the failure mode a per-skill preflight can't catch) and/or
# a skill preflight. Never blocks: always exits 0.
set -uo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Per-repo opt-out: a repo that uses ADRs/CONTEXT.md but is NOT on this workflow
# can drop a `.no-agent-skills` file at its root to silence the check for good.
if [ -e "$root/.no-agent-skills" ]; then
  exit 0
fi

# Already configured? The `## Agent skills` block (CLAUDE.md/AGENTS.md) or docs/agents/.
if grep -qsE '^##[[:space:]]+Agent skills' "$root/CLAUDE.md" "$root/AGENTS.md" 2>/dev/null \
   || [ -d "$root/docs/agents" ]; then
  exit 0
fi

# Does this repo use the workflow? Domain docs (CONTEXT.md / docs/adr) are the
# signal. If absent, stay silent so unrelated repos are never nagged.
if [ -f "$root/CONTEXT.md" ] || [ -d "$root/docs/adr" ]; then
  cat <<'MSG'
⚠️  Agent-skills setup not detected here: no "## Agent skills" block in CLAUDE.md/AGENTS.md and no docs/agents/, but this repo has CONTEXT.md/ADRs — so it uses the engineering-skills workflow.

Run /setup-matt-pocock-skills before using triage, to-issues, to-prd, diagnose, tdd, improve-codebase-architecture, or zoom-out: they rely on the issue-tracker, triage-label, and domain-doc config it writes. Skipping it is what silently goes wrong — an agent ends up working off stale issue criteria instead of the ADRs.
MSG
fi
exit 0
