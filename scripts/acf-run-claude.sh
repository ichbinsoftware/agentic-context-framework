#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# ACF Onboarding — Claude Code
# Runs the full ACF pipeline (7 stages) using Claude Code CLI.
# Usage: ./acf-run-claude.sh  (run from the target repo root)
# ============================================================================

# Models
GENERATE_MODEL="${GENERATE_MODEL:-claude-sonnet-4-6}"
VERIFY_MODEL="${VERIFY_MODEL:-claude-opus-4-6}"
REVIEW_MODEL="${REVIEW_MODEL:-claude-opus-4-6}"

# Limits
MAX_TURNS="${MAX_TURNS:-200}"
MAX_BUDGET="${MAX_BUDGET:-30.00}"

# ---- Logging ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${BLUE}[acf]${NC} $*"; }
ok()   { echo -e "${GREEN}[ok]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; }

# ---- Dependencies ----
command -v claude >/dev/null 2>&1 || { err "Required: claude CLI (npm i -g @anthropic-ai/claude-code)"; exit 1; }

if [ ! -f ".claude/agents/acf-context-agent.md" ]; then
    err ".claude/agents/acf-context-agent.md not found in $(pwd)"
    err "Copy .claude/agents/ from the ACF repo into your repo root"
    exit 1
fi

# ---- Run a stage ----
run_stage() {
    local stage_name="$1"
    local model="$2"
    local prompt="$3"

    log "Stage $stage_name — model=$model"

    local start_ts end_ts duration exit_code
    start_ts=$(date +%s)

    set +e
    claude --model "$model" \
           --max-turns "$MAX_TURNS" \
           --max-budget-usd "$MAX_BUDGET" \
           --dangerously-skip-permissions \
           -p "$prompt"
    exit_code=$?
    set -e

    end_ts=$(date +%s)
    duration=$((end_ts - start_ts))

    if [ "$exit_code" -eq 0 ]; then
        ok "Stage $stage_name complete — ${duration}s"
    else
        warn "Stage $stage_name exited with code $exit_code — ${duration}s"
    fi

    return $exit_code
}

# ---- Main ----
echo ""
log "=========================================="
log "ACF Onboarding — Claude Code"
log "Repo:     $(pwd)"
log "Pipeline: 1 → 1.5 → 2 → 3 → 3.5 → 4"
log "Models:   generate=$GENERATE_MODEL  verify=$VERIFY_MODEL  review=$REVIEW_MODEL"
log "Budget:   \$$MAX_BUDGET per stage"
log "=========================================="
echo ""

run_start=$(date +%s)

# Stage 1: Onboard
run_stage "1" "$GENERATE_MODEL" "Use \"acf-context-agent\" and run Stage 1: Onboard" || true

# Stage 1.5: Verify
run_stage "1.5" "$VERIFY_MODEL" "Use \"acf-context-agent\" and run Stage 1.5: Verify" || true

# Stage 2: Instructions
run_stage "2" "$GENERATE_MODEL" "Use \"acf-context-agent\" and run Stage 2: Instructions" || true

# Stage 3: DeepDive
if ! run_stage "3" "$GENERATE_MODEL" "Use \"acf-context-agent\" and run Stage 3: DeepDive"; then
    warn "Stage 3 interrupted — re-running to complete remaining docs"
    run_stage "3" "$GENERATE_MODEL" "Use \"acf-context-agent\" and run Stage 3: DeepDive" || true
fi

# Stage 3.5: Audit
run_stage "3.5" "$VERIFY_MODEL" "Use \"acf-context-agent\" and run Stage 3.5: Audit" || true

# Stage 4: Review
run_stage "4" "$REVIEW_MODEL" "Use \"acf-context-agent\" and run Stage 4: Review" || true

run_end=$(date +%s)
total_duration=$((run_end - run_start))

echo ""
log "=========================================="
ok "ACF onboarding complete — ${total_duration}s"
log "Docs:     $(pwd)/docs/"
log "Agent:    $(pwd)/AGENTS.md"
log "=========================================="
