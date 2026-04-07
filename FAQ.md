# Frequently Asked Questions

## Setup

**Do I need to copy all the agent folders or just one?**
Just one — the folder for the AI tool you use. The others can be ignored.

**What if my codebase is messy — will Stage 1 still produce useful output?**
It depends on how messy. Stage 1 infers architecture from what it can find. If the codebase has no coherent structure, the output will reflect that. See [LIMITATIONS.md](LIMITATIONS.md) for an honest assessment.

**Stage 2 generated a pointer file (`CLAUDE.md`, `GEMINI.md`, `.cursorrules`, etc.) — do I need it?**
Stage 2 generates a pointer file to `AGENTS.md` as a safe default. If your AI tool already reads `AGENTS.md` directly, the pointer file is redundant and you can safely delete it. Check your tool's documentation to confirm which files it reads on startup. **When in doubt, keep the pointer file — it ensures the agent is correctly anchored to your repository's rules.**

---

## Existing Documentation

**What if I already have an `AGENTS.md` or a `docs/` folder?**
The `acf-context-agent` is opinionated and code-verified. It generates its own structure to ensure the Retrieval Discipline and ADC Policy are correctly implemented. Stage 2 will **overwrite** your existing `AGENTS.md`.

**How do I reconcile my existing documentation with ACF?**
1. **Backup:** Rename your existing `AGENTS.md` to `AGENTS.legacy.md`.
2. **Generate:** Run Stages 1–3 to let the agent produce its code-verified baseline.
3. **Manual Merge:** Copy your specific tribal knowledge (that isn't inferable from code) into the new `AGENTS.md`.
4. **Review:** Run Stage 4. It will catch gaps between the generated docs and the codebase — but it won't automatically incorporate your old docs. Any remaining knowledge from your legacy files needs to be merged manually.

**Why doesn't the agent just append to my existing files?**
The documentation must be verified against the current codebase. Appending leads to stale instructions. Starting from a clean, code-verified generation ensures the context layer is accurate.

---

## The Stages

**Why are there verification stages (1.5 and 3.5)?**
The generation stages (1, 2, 3) produce documentation, but they make errors — wrong counts, fabricated names, behavioral assumptions from training data. Verification stages run in fresh sessions to catch these errors before they propagate. A fresh session is sufficient — the model can no longer validate what it previously wrote. Using a higher-capability model tier (e.g., Opus verifying Sonnet's output) adds additional rigour but is optional.

**Why do I need a fresh session for Stage 4?**
A model reviewing its own output in the same session exhibits confirmation bias — it validates what it wrote rather than challenges it. A fresh session eliminates this bias and is sufficient for most teams. Switching to a different provider gives maximum independence but is optional. See [LIMITATIONS.md](LIMITATIONS.md) for more detail.

**Do I need to run all stages in one session?**
No — in fact, you should not. Each stage is designed to run in a fresh session. This is especially important for verification stages (1.5, 3.5, 4) where fresh context prevents confirmation bias. The runner scripts in `scripts/` (one per tool) handle this automatically — each stage is invoked as a fresh CLI call. See [SETUP.md](SETUP.md) for the script for your tool.

**How often should I run Stage 5?**
Treat it like a dependency update cycle — schedule it rather than relying on memory. After significant sprints or releases is a good default.

---

## Retrieval Discipline

**What is the Retrieval Discipline?**
A section generated in `AGENTS.md` during Stage 2 that tells AI agents exactly how to incrementally load context for your specific repo — which files to read, in what order, and when to stop. It is generated from your actual codebase structure, so it reflects your real layers and terminology rather than generic advice.

The Retrieval Discipline is the most reliably accurate section ACF produces. This is because it follows a fixed procedural template: agents execute procedures reliably, but they skip guidelines. The numbered-step, dependency-chained format is intentional.

---

## ADCs

**What's the difference between an ADC and an ADR?**
An ADR captures a decision — what was decided, why, and the consequences. An ADC captures the full context of a change — the decision is one part, but it also includes impact, rollout, rollback, and an optional linked execution plan. ADRs are backward-looking ("what we decided"). ADCs are both backward and forward-looking ("what we decided + how to execute it safely"). They're designed for both humans and selective AI agent retrieval.

**When should I create an ADC vs just writing a code comment?**
Code comments explain implementation detail. ADCs explain architectural decisions — why this approach over another, what was rejected, what the wider impact is. If the decision only makes sense in the context of that function, a comment is enough. If it affects patterns, contracts, or future architectural choices, create an ADC.

**What if a developer makes a significant change without using an agent — will an ADC be created?**
No. ADC creation is only automatic when an agent is doing the work. For human-authored changes, a PR review checklist is the most practical enforcement mechanism. See [LIMITATIONS.md](LIMITATIONS.md).

---

## Team & Process

**What if only some developers on my team use AI tools?**
ACF still delivers value. The generated docs benefit all developers regardless of whether they use AI tools — clearer architecture docs and decision records help everyone. Adoption can be incremental.

**How do I enforce ADC creation for human-authored changes?**
There is no CI hook or automated enforcement. A PR review checklist is the most practical approach — reviewers check whether a significant change warrants an ADC before approving.

**Do all developers need to install the same AI tool?**
No. ACF is tool-agnostic. Multiple agent folders can coexist in the same repo — one developer can use Claude Code while another uses Cursor or Copilot. The generated docs are shared regardless of which tool produced them.

---

## General

**What if I switch AI tools — do I lose my docs?**
No. All generated docs are plain markdown files versioned in your repo. They are not tied to any AI tool or platform.

**Does this work with monorepos?**
Yes. Run the `acf-context-agent` stages from the root of each project or service you want to document. The docs and ADCs live within that project's folder structure.

**How does ACF relate to spec-driven development tools?**
They're complementary. ACF provides the architectural context layer — it tells agents how the codebase works, what conventions to follow, and what constraints exist. Spec-driven tools provide the change layer — they tell agents what to build next. ACF runs first: without it, an agent executing a spec knows *what* to change but not *how this codebase works*. With both, agents understand the system and receive structured work orders against it.
