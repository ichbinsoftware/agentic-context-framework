# Limitations & Honest Caveats

ACF is a useful framework, but it has limitations worth understanding before you invest in it.

---

## The framework is only as good as what the agent can infer

Stage 1 (Onboard) asks the `acf-context-agent` to scan your repository and produce an accurate architecture overview. If your codebase is inconsistent, undocumented, or structurally messy, the generated docs will reflect that. A well-structured document describing a poorly-structured system is better than nothing — but it's not the force multiplier the framework promises.

**What this means in practice:** Run Stage 1 on a reasonably coherent codebase. If your repo is in poor shape, consider a basic cleanup before onboarding.

---

## ADC discipline still requires team buy-in

The generated `AGENTS.md` tells agents when to create an ADC and how to do it. When an agent is executing a task, it will recognise when an ADC is warranted and produce one. However, there is no CI hook or PR check that enforces this for human-authored changes. If a developer ships a significant architectural change without involving an agent, no ADC will be created.

**What this means in practice:** ADC coverage is strongest when agents are doing the work. For human-only changes, a PR review checklist is the most practical enforcement mechanism.

---

## The Review stage (Stage 4) requires an independent perspective

Stage 4 asks you to review the generated documentation without anchoring to the assumptions of the agent that wrote it. The original design required a different model entirely, but the real requirement is independence — not a specific provider.

In practice, a fresh session with the same model eliminates confirmation bias — the model can no longer validate what it previously wrote — and is sufficient for most teams. Switching to a different provider (Gemini, GPT-4o, etc.) gives maximum independence but is optional.

**What this means in practice:** Start a new conversation and run Stage 4 from there. This costs nothing and removes confirmation bias. A different provider is better, but a fresh session is good enough.

---

## Stage 5 (Update) only runs when someone schedules it

Architectural drift is a slow process. Stages 1–4 are not re-run — Stage 5 is the only maintenance path. The framework provides this stage but has no automated trigger. If Stage 5 isn't wired into a recurring workflow, docs will quietly fall behind the codebase and erode trust in the context layer.

**What this means in practice:** Schedule it explicitly — after significant sprints or releases is a good default. A CI scheduled job, a recurring calendar reminder, or a sprint ritual all work. Do not rely on memory. An undocumented codebase is recoverable; a documentation layer that confidently describes the wrong system is worse than nothing.

**Example: GitHub Actions reminder**

```yaml
# .github/workflows/acf-stage5-reminder.yml
name: ACF Stage 5 Reminder
on:
  schedule:
    - cron: '0 9 1 */2 *'  # 9am on the 1st of every 2nd month
jobs:
  remind:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: 'ACF Stage 5: Check for architectural drift',
              body: 'Scheduled reminder to run `Stage 5: Update` and check for documentation drift.\n\nRun this in your AI tool: `@acf-context-agent Run Stage 5: Update`',
              labels: ['documentation']
            });
```
