# Agentic Context Framework (ACF)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Organisations are investing heavily in AI coding tools and agentic DevOps workflows, but getting inconsistent results. The tools are powerful, but they're working blind.

AI agents don't understand your architecture, your team's conventions, or why you made the decisions you made. Without this context, they generate code that works but doesn't fit — leading to rework, architectural drift, and eroded trust in the tooling.

**The missing layer isn't better models. It's better context.**

The Agentic Context Framework (ACF) is a structured approach to providing AI agents with the architectural knowledge, guardrails, and decision history they need to generate code that fits your system — not just code that compiles.

It treats agent context as a first-class engineering artefact: versioned in the repo, maintained alongside the code, and reviewed in every PR.

> Before adopting ACF, read [WHEN-ACF-WORKS.md](WHEN-ACF-WORKS.md) to understand where it delivers and where it doesn't. See [LIMITATIONS.md](LIMITATIONS.md) for an honest account of its gaps.

---

## 🏛️ The Three Pillars of ACF

| Pillar | What it is | Where it lives |
| :--- | :--- | :--- |
| **Agent Instructions** | Generated, repo-specific architectural boundaries, naming conventions, and risk triggers that require human review | `AGENTS.md` |
| **Architecture Docs** | High-level system maps, service boundaries, and deep-dive documentation | `docs/` |
| **Agent Decision Context (ADC)** | Decision records and execution plans that capture the "why" behind the code | `docs/adc/` |

A 50-line architecture doc costs far fewer tokens than an agent scanning 20 source files to infer the same information.

---

## 🚀 Quick Start

**1. Copy the agent file for your AI tool** into the **root of your repo/project**:

| Tool | Copy this folder |
| :--- | :--- |
| Claude Code | `.claude/agents/` |
| Gemini CLI | `.gemini/agents/` |
| GitHub Copilot | `.github/agents/` |
| Codex | `.codex/agents/` |
| Cursor | `.cursor/agents/` |

You only need the folder for the tool(s) you use.

**2. Run Stage 1** in your AI tool's chat interface:

> "Run Stage 1: Onboard"

**3. Follow the stages in order** (1–4) for initial setup.

**4. After Stage 4 is complete**, copy `docs/adc/` from this repo into your project's `docs/` folder. This provides the ADC template (`_TEMPLATE.md`), plan template, and retrieval policy that agents and developers use when recording decisions going forward.

**5. Schedule Stage 5** to keep docs current. Stage 5 is the only maintenance path — Stages 1–4 are not re-run. Treat it like a dependency update cycle: schedule it after significant sprints or releases rather than relying on memory. Wire it into your sprint cadence or CI schedule if possible.

> **ACF is a collaboration, not a generation-and-forget workflow.** Agents generate the baseline from code. Humans bring the context that code can't express — business constraints, tribal knowledge, regulatory requirements, and the reasoning behind legacy decisions. Review and enrich the generated docs at each stage before moving on.

---

## 🤖 The `acf-context-agent` Workflow

The `acf-context-agent` automates the generation and maintenance of all three pillars through a 5-stage lifecycle:

| Platform | Invocation |
| :--- | :--- |
| Claude Code | `@acf-context-agent Run Stage 1: Onboard` |
| Gemini CLI | `@acf-context-agent Run Stage 1: Onboard` |
| Cursor | Select `acf-context-agent` from the agent picker, then: `Run Stage 1: Onboard` |
| GitHub Copilot | Select `acf-context-agent` from the agent list, then: `Run Stage 1: Onboard` |
| Codex | `Run Stage 1: Onboard` *(agent loaded automatically)* |

### 1. Onboard
`Run Stage 1: Onboard`

Scans the repository to produce a high-level "map of the system" in `docs/ARCHITECTURE-OVERVIEW.md`. Identifies entry points, key technologies, architectural styles, and cross-cutting concerns.

### 2. Instructions
`Run Stage 2: Instructions`

Generates repo-specific instruction files (`AGENTS.md` and a platform-specific pointer file). Includes a **Retrieval Discipline** section that tells AI agents exactly how to incrementally load context for this specific repo.

### 3. DeepDive
`Run Stage 3: DeepDive`

Sequentially generates detailed documentation for every complex area identified during Onboard (e.g., Auth, Message Processing, Database Schema).

### 4. Review
`Run Stage 4: Review`

Audits the generated documentation against the actual codebase using a different model, identifying gaps, inconsistencies, or unverified claims. A model reviewing its own output exhibits confirmation bias — a different model brings genuine independence.

### 5. Update *(Maintenance)*
`Run Stage 5: Update`

A recurring stage designed to be run weeks or months later. Scans for "architectural drift" by comparing source code and new ADC records against existing documentation, ensuring your AI context never goes out of date.

---

## 📋 Agent Decision Context (ADC)

Architecture docs explain *what* the system is. ADCs explain *why* it is that way — what changed, why, what was rejected, what it affects, and how to deploy and roll back safely.

Each ADC has two parts:

- **ADC Record** (`docs/adc/`) — the decision and its context: motivation, approach, alternatives rejected, impact, and rollout.
- **Execution Plan** (`docs/adc/plans/`) — optional step-by-step implementation sequence tied to that decision.

ADCs are referenced in code comments and PR descriptions. Agents only read them when explicitly needed — not by default.

See the included example:
- [`adc-example/docs/adc/2026-02-27--external-user-entity.md`](adc-example/docs/adc/2026-02-27--external-user-entity.md)
- [`adc-example/docs/adc/plans/2026-02-27--external-user-entity-service.plan.md`](adc-example/docs/adc/plans/2026-02-27--external-user-entity-service.plan.md)

---

## 💡 Why This Matters

### For AI Coding Tools
Most teams stop at "install the extension and run a workshop." ACF is what comes after — the structural investment that turns a productivity tool into a force multiplier. It's the difference between a developer with access to Stack Overflow and one who's been properly onboarded.

### For Agentic DevOps
As AI agents move from code suggestions to autonomous task execution — raising PRs, resolving incidents, migrating systems — the stakes increase dramatically. An agent operating without architectural context isn't just unhelpful, it's dangerous. ACF is a prerequisite for safe, effective agentic workflows at scale.

### For Legacy Modernisation
When AI agents help migrate or modernise legacy systems, the biggest risk isn't the technology — it's the loss of institutional knowledge. ADCs capture the decisions embedded in legacy code ("this workaround exists because of a vendor limitation") before they're lost in translation.

---

## 📈 Maturity Model

ACF is designed to be adopted incrementally. Start at Level 1 and progress as your team grows confidence:

| Level | State | Characteristics |
| :--- | :--- | :--- |
| **0** | **Ad Hoc** | No agent context. AI tools generating generic, often incorrect code. High rework rate. Developers lose trust in the tooling. |
| **1** | **Basic** | Instructions only (`AGENTS.md`). Agents follow core conventions. Common mistakes reduced but agents still lack system understanding. |
| **2** | **Informed** | Instructions + Docs. Architecture docs provide the system map. Agents generate structurally correct code. Onboarding time drops for both humans and AI. |
| **3** | **Trusted** | **Full ACF.** Instructions + Docs + ADC. Agents respect past decisions, follow patterns, and flag risk triggers. Rework drops. Autonomous agentic workflows become viable. |

---

## 🎯 Benefits

| Stakeholder | Benefit | Impact |
| :--- | :--- | :--- |
| **Developers** | Faster onboarding — read docs instead of reverse-engineering the codebase | New developers and agents start contributing sooner |
| **Developers** | Prevents regression — explicit "why we didn't do X" records | Settled decisions stay settled |
| **Teams** | Clear boundaries and shared context — agents follow deterministic rules, not inferred patterns | Less back-and-forth correction on AI-generated code |
| **Teams** | Reduced rework — violations caught early, decisions respected | Problems caught before review, not after |
| **Business** | Knowledge resilience — tribal knowledge becomes a documented asset | New team members inherit the reasoning, not just the code |
| **Business** | Lower AI costs and tool-agnostic investment — structured docs instead of full codebase scans | Fewer tokens per request; works with any AI tool now and in future |

---

## 🛠️ AI Tool Setup

> **Before invoking the agent**, make sure you have copied the relevant folder from this repo into the **root of your repo/project** (see Quick Start above). The agent file must be present at the root for your AI tool to detect it.

### Claude Code
Install Claude Code. Copy `.claude/agents/` into your repo root. The `acf-context-agent` will then be available by name in chat.

### Gemini CLI
Install Gemini CLI. Copy `.gemini/agents/` into your repo root. Invoke the agent using the `acf-context-agent` name.

### GitHub Copilot
- **VS Code:** Install the GitHub Copilot and GitHub Copilot Chat extensions. Copy `.github/agents/` into your repo root. In the chat panel, select `acf-context-agent` from the agent list.
- **CLI:** Install GitHub Copilot in the CLI. Copy `.github/agents/` into your repo root. Invoke the agent using the `acf-context-agent` name.

### Codex
Install Codex CLI. Copy `.codex/agents/` into your repo root. The agent is loaded automatically.

### Cursor
Install Cursor. Copy `.cursor/agents/` into your repo root. Select `acf-context-agent` from the agent list.

---

## ❓ FAQ

### Setup

**Do I need to copy all the agent folders or just one?**
Just one — the folder for the AI tool you use. The others can be ignored.

**What if my codebase is messy — will Stage 1 still produce useful output?**
It depends on how messy. Stage 1 infers architecture from what it can find. If the codebase has no coherent structure, the output will reflect that. See [LIMITATIONS.md](LIMITATIONS.md) for an honest assessment.

**Stage 2 generated a pointer file (`CLAUDE.md`, `GEMINI.md`, `.cursorrules`, etc.) — do I need it?**
Stage 2 generates a pointer file to `AGENTS.md` as a safe default. If your AI tool already reads `AGENTS.md` directly, the pointer file is redundant and you can safely delete it. Check your tool's documentation to confirm which files it reads on startup.

---

### Existing Documentation

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

### The Stages

**Why do I need to switch models for Stage 4?**
A model reviewing its own output exhibits confirmation bias — it validates what it wrote rather than challenges it. A different model from a different provider brings genuine independence. At minimum, start a fresh session so the model has no prior context from Stages 1–3. See [LIMITATIONS.md](LIMITATIONS.md) for more detail.

**Do I need to run all stages in one session?**
No. Each stage is designed to stop and wait for your instruction. You can run them across multiple sessions.

**How often should I run Stage 5?**
Treat it like a dependency update cycle — schedule it rather than relying on memory. After significant sprints or releases is a good default.

---

### Retrieval Discipline

**What is the Retrieval Discipline?**
A section generated in `AGENTS.md` during Stage 2 that tells AI agents exactly how to incrementally load context for your specific repo — which files to read, in what order, and when to stop. It is generated from your actual codebase structure, so it reflects your real layers and terminology rather than generic advice. The goal is to prevent agents from scanning the entire codebase when only a small part is relevant to the task.

---

### ADCs

**What's the difference between an ADC and an ADR?**
An ADR captures a decision — what was decided, why, and the consequences. An ADC captures the full context of a change — the decision is one part, but it also includes impact, rollout, rollback, and an optional linked execution plan. ADRs are backward-looking ("what we decided"). ADCs are both backward and forward-looking ("what we decided + how to execute it safely"). They're designed for both humans and selective AI agent retrieval.

**When should I create an ADC vs just writing a code comment?**
Code comments explain implementation detail. ADCs explain architectural decisions — why this approach over another, what was rejected, what the wider impact is. If the decision only makes sense in the context of that function, a comment is enough. If it affects patterns, contracts, or future architectural choices, create an ADC.

**What if a developer makes a significant change without using an agent — will an ADC be created?**
No. ADC creation is only automatic when an agent is doing the work. For human-authored changes, a PR review checklist is the most practical enforcement mechanism. See [LIMITATIONS.md](LIMITATIONS.md).

---

### Team & Process

**What if only some developers on my team use AI tools?**
ACF still delivers value. The generated docs benefit all developers regardless of whether they use AI tools — clearer architecture docs and decision records help everyone. Adoption can be incremental.

**How do I enforce ADC creation for human-authored changes?**
There is no CI hook or automated enforcement. A PR review checklist is the most practical approach — reviewers check whether a significant change warrants an ADC before approving.

**Do all developers need to install the same AI tool?**
No. ACF is tool-agnostic. Multiple agent folders can coexist in the same repo — one developer can use Claude Code while another uses Cursor or Copilot. The generated docs are shared regardless of which tool produced them.

---

### General

**What if I switch AI tools — do I lose my docs?**
No. All generated docs are plain markdown files versioned in your repo. They are not tied to any AI tool or platform.

**Does this work with monorepos?**
Yes. Run the `acf-context-agent` stages from the root of each project or service you want to document. The docs and ADCs live within that project's folder structure.

---

## 🤝 Contributing

Contributions are welcome. If you've used ACF on a real project and found gaps, improvements, or new patterns worth capturing, please share them.

**To contribute:**

1. Fork the repository and create a branch from `main`
2. Make your changes — keep them focused and minimal
3. Open a pull request with a clear description of what changed and why
4. For significant changes to the agent instructions or framework structure, include a brief rationale in the PR description

**Good areas to contribute:**

- Improvements to the `acf-context-agent` stages
- Additional ecosystem examples for the Retrieval Discipline steps (new tech stacks, frameworks)
- Corrections or improvements to the ADC template
- Real-world ADC examples (anonymised) that would help illustrate the format

**Please avoid:**

- Generic documentation improvements without grounding in real usage
- Adding new pillars or stages without strong justification — the framework is intentionally lean

For bugs or questions, open an issue.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
