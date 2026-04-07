# AI Tool Setup

Before invoking the agent, copy the relevant folder from this repo into the **root of your repo/project**. The agent file must be present at the expected path for your AI tool to detect it.

Each tool has two ways to run the pipeline:

- **Automated (recommended)** — copy the runner script from `scripts/` into your repo and run it. The script executes stages 1 → 1.5 → 2 → 3 → 3.5 → 4 in sequence with model switching between generation and verification stages, each in a fresh CLI session.
- **Manual** — invoke the agent yourself, one stage at a time. Use a fresh session for every verification stage (1.5, 3.5, 4).

Jump to: [Claude Code](#claude-code) · [Gemini CLI](#gemini-cli) · [GitHub Copilot](#github-copilot) · [Codex](#codex) · [Cursor](#cursor)

---

## Claude Code

Install Claude Code. Copy `.claude/agents/` into your repo root.

**Automated (recommended):** Copy `scripts/acf-run-claude.sh` into your repo root and run it:
```bash
./acf-run-claude.sh
```

**Manual — interactive:** `use acf-context-agent` in the chat interface, then `Run Stage 1: Onboard`.

**Manual — CLI:** `claude --agent acf-context-agent -p "Run Stage 1: Onboard"`

---

## Gemini CLI

Install Gemini CLI. Copy `.gemini/agents/` into your repo root.

**Automated (recommended):** Copy `scripts/acf-run-gemini.sh` into your repo root and run it:
```bash
./acf-run-gemini.sh
```

**Manual:** Enter `Use 'acf-context-agent' and Run Stage 1: Onboard`.

---

## GitHub Copilot

Copy `.github/agents/` into your repo root.

**Automated (recommended):** Copy `scripts/acf-run-copilot.sh` into your repo root and run it:
```bash
./acf-run-copilot.sh
```

**Manual — VS Code:** Install the GitHub Copilot and GitHub Copilot Chat extensions. In the chat panel, select `acf-context-agent` from the agent list.

**Manual — CLI:** Install GitHub Copilot in the CLI. Invoke the agent using the `acf-context-agent` name.

---

## Codex

Install Codex CLI. Copy `.codex/agents/` into your repo root.

**Automated (recommended):** Copy `scripts/acf-run-codex.sh` into your repo root and run it:
```bash
./acf-run-codex.sh
```

**Manual:** Enter `Use 'acf-context-agent' and Run Stage 1: Onboard`.

---

## Cursor

Install Cursor. Copy `.cursor/agents/` into your repo root.

No runner script is provided — Cursor's chat interface is the supported entrypoint. Select `acf-context-agent` from the agent list, then invoke each stage manually starting with `Run Stage 1: Onboard`. Start a new chat for every verification stage (1.5, 3.5, 4).

---

## Runner scripts — defaults & overrides

| Tool | Script | Generate model | Verify/Review model |
| :--- | :--- | :--- | :--- |
| Claude Code | [`scripts/acf-run-claude.sh`](scripts/acf-run-claude.sh) | `claude-sonnet-4-6` | `claude-opus-4-6` |
| Codex | [`scripts/acf-run-codex.sh`](scripts/acf-run-codex.sh) | `gpt-5.4` | `gpt-5.4` |
| GitHub Copilot | [`scripts/acf-run-copilot.sh`](scripts/acf-run-copilot.sh) | `gpt-5.4` | `claude-opus-4.6` |
| Gemini CLI | [`scripts/acf-run-gemini.sh`](scripts/acf-run-gemini.sh) | `gemini-2.5-pro` | `gemini-2.5-pro` |

All models are overridable via environment variables, e.g.:

```bash
GENERATE_MODEL=claude-sonnet-4-6 VERIFY_MODEL=claude-opus-4-6 ./acf-run-copilot.sh
```

**Notes:**

- Run scripts from your **target repo root**, not from the ACF repo. Each script expects the corresponding agent folder (`.claude/agents/`, `.gemini/agents/`, etc.) to exist in the current working directory.
- Stage 5 (Update) is not part of the runner scripts. Run it separately on a schedule, after significant releases, to detect drift.
- If a stage exits non-zero, the script logs a warning and continues. Re-run individual stages manually if needed.

**Windows:** The runner scripts are bash and require WSL2 or Git Bash. If neither is available, use the manual invocation steps for your tool — every stage can be triggered by typing the prompt into the chat. The agent specs, generated docs, and CLI tools themselves are fully cross-platform.
