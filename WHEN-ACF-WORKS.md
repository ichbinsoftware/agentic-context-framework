# When ACF Works Best

ACF delivers the most value in specific conditions. Understanding where it fits — and where it doesn't — will save you from investing in the wrong place.

---

## It works best on legacy codebases with no documentation and no existing agent integration

This is the highest-value scenario. A legacy codebase with no architecture docs and no AI tooling set up is exactly where ACF delivers the most immediate, tangible return: there's nothing to migrate from, no existing conventions to reconcile, and no agent context to replace.

The `acf-context-agent` generates the entire documentation layer from scratch — architecture overview, deep-dive docs, agent instruction files — directly from the codebase. The team doesn't author anything from scratch. They trigger the agent, review what it produces, and start benefiting immediately.

For teams in this position, ACF is the fastest path from zero context to a working, agent-ready documentation layer. 

It works equally well on active codebases that have simply never prioritised documentation.

---

## It works best when agents and developers work together

Developers and agents collaborate most effectively when agents have the context to make good decisions and developers have the confidence to trust and extend what agents produce. ACF provides that shared foundation — developers don't have to constantly correct agents, and agents don't have to guess at patterns and conventions.

Even small amounts of context (starting at Level 1) improve the day-to-day experience. The value compounds as agent involvement deepens.

---

## It is a prerequisite for safe agentic DevOps

As agents move from suggestions to autonomous execution — resolving incidents, migrating systems, raising PRs independently — the risk of operating without architectural context increases dramatically. An agent that doesn't know your auth pipeline, your shared contracts, or your risk triggers isn't just unhelpful, it's dangerous.

For teams moving toward agentic DevOps, ACF is not optional — it's the safety layer.

---

## It is particularly valuable for legacy modernisation

When AI agents help migrate or modernise legacy systems, the biggest risk isn't the technology — it's institutional knowledge loss. Legacy code is full of decisions that made sense at the time: workarounds for vendor limitations, tradeoffs made under constraints that no longer exist, patterns that can't be changed without breaking downstream consumers.

ADCs capture this context before it's lost in translation. Without them, an AI agent will modernise the code and delete the memory.

---

## It is tool-agnostic by design

ACF is markdown in your repo. It works with Claude Code, GitHub Copilot, Gemini CLI, Cursor, Codex, and any future tool that reads file context. You're not buying into a platform or a vendor — you're building a documentation asset that compounds over time.

---

## It does not work well when

- The codebase has no coherent structure for the agent to infer from — Stage 1 will produce weak output
- There is no buy-in from the team — one person maintaining ADCs for a team that ignores them is wasted effort
- AI agents are only used for trivial, low-risk tasks where context doesn't affect output quality
- There is no capacity to run Stage 5 periodically — docs will drift and erode trust in the framework

---

For a deeper look at the technical constraints, error classes that survive verification, and the maintenance burden of running ACF in practice, see [LIMITATIONS.md](LIMITATIONS.md).
