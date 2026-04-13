# Benchmark: Agent Task Performance — ACF vs No ACF

How well do agents perform real tasks **with** ACF documentation vs **without** it?

17 open-source repositories across Python, JavaScript, TypeScript, Go, C#, Rust, Swift, PowerShell, and Bicep. Same model (Claude Sonnet 4.6), same prompts, same repos. The only difference: whether ACF-generated docs (`AGENTS.md`, `docs/ARCHITECTURE-OVERVIEW.md`, deep-dives) are present in the repo.

Each repo was tested with two prompts:
- **Describe** — a detailed architectural question requiring source-level understanding
- **Plan** — a feature change requiring an architectural decision record + execution plan

An independent reviewer (Claude Opus 4.6) scored both responses across 8 dimensions (4 per prompt): Answer Accuracy, Architectural Awareness, File Coverage, Specificity (Describe); Architectural Fit, Implementation Correctness, Completeness, Actionability (Plan).

---

## Results

| Repo | Language | Size | Verdict | ACF Wins | Desc Tokens | Plan Tokens | Desc Tools | Plan Tools | Desc Files | Plan Files |
|---|---|---|---|---|---|---|---|---|---|---|
| [se-hello-printer](https://github.com/wojciech11/se_hello_printer_app) | python | tiny | **Significant** | 3/8 | -15% | -2% | -17% | -48% | 0% | -18% |
| [cowsay](https://github.com/piuccio/cowsay) | javascript | tiny | **Marginal** | 3/8 | -80% | -62% | -68% | -69% | -43% | -60% |
| [prettytable](https://github.com/jazzband/prettytable) | python | small | **Significant** | 5/8 | -69% | -76% | -70% | -65% | +150% | 0% |
| [petshop-api](https://github.com/petshop-system/petshop-api) | go | small | **Significant** | 3/8 | -76% | -48% | -70% | -54% | -60% | -55% |
| [travel-booking-api](https://github.com/Nedal-Esrar/Travel-and-Accommodation-Booking-Platform) | csharp | small | **Marginal** | 1/8 | -81% | -65% | -73% | -70% | -63% | -69% |
| [appservice-landing-zone](https://github.com/Azure/appservice-landing-zone-accelerator) | bicep | small | **Significant** | 7/8 | -77% | -70% | -73% | -69% | -59% | -61% |
| [nextjs14-app](https://github.com/yaseenmustapha/nextjs14-app) | typescript | small | **Significant** | 6/8 | -51% | -58% | -48% | -64% | -35% | -54% |
| [miniblog-core](https://github.com/madskristensen/Miniblog.Core) | csharp | small | **Significant** | 4/8 | +16% | -62% | +20% | -56% | +67% | -25% |
| [logicappdocs](https://github.com/stefanstranger/logicappdocs) | powershell | small | **Significant** | 5/8 | -87% | -49% | -82% | -32% | -43% | -9% |
| [clean-architecture-swiftui](https://github.com/nalexn/clean-architecture-swiftui) | swift | small | **Significant** | 4/8 | +25% | -42% | -30% | -62% | -14% | -62% |
| [hyperfine](https://github.com/sharkdp/hyperfine) | rust | small | **Significant** | 4/8 | -84% | -84% | -78% | -71% | -55% | -61% |
| [run-aspnetcore-microservices](https://github.com/aspnetrun/run-aspnetcore-microservices) | csharp | medium | **Significant** | 5/8 | -74% | -35% | -62% | -70% | -40% | -75% |
| [gluesql](https://github.com/gluesql/gluesql) | rust | medium | **Significant** | 5/8 | -1% | -71% | -58% | -63% | -22% | -52% |
| [azure-deployment-framework](https://github.com/brwilkinson/AzureDeploymentFramework) | bicep | medium | **Significant** | 4/8 | -69% | -62% | -48% | -42% | -56% | -60% |
| [hamilton](https://github.com/DAGWorks-Inc/hamilton) | python | medium | **Significant** | 6/8 | -67% | -76% | -51% | -75% | +30% | -10% |
| [gridland](https://github.com/thoughtfulllc/gridland) | typescript | large | **Significant** | 1/8 | -76% | -71% | -66% | -73% | -36% | -33% |
| [alz-bicep](https://github.com/Azure/ALZ-Bicep) | bicep | large | **Significant** | 4/8 | -21% | -44% | -17% | -24% | +80% | 0% |

**Negative percentages = ACF used less** (fewer tokens, fewer tool calls, fewer files read). Positive = ACF explored more than baseline for that metric.

---

## Verdict Definitions

| Verdict | Meaning |
|---|---|
| **Significant** | ACF wins 3+ dimensions, or has a critical finding (concrete bug caught that baseline missed), or total lead ≥ 4 |
| **Marginal** | 1-2 ACF wins, no critical finding, lead < 4 |
| **None** | Baseline ties or wins overall |

---

## Aggregate

| Metric | Value |
|---|---|
| **Significant** | 15 / 17 repos (88%) |
| **Marginal** | 2 / 17 repos (12%) |
| **None** | 0 / 17 repos (0%) |
| Avg ACF wins per repo | 3.9 / 8 |
| Avg lead in ACF's favor | +5.1 points |
| Median Describe tool call reduction | -65% |
| Median Plan tool call reduction | -63% |
| Haiku subagent delegation (ACF) | 0% in 16/17 runs (vs 0-78% baseline) |

---

## What This Tells You

**Quality:** ACF-documented repos produce better answers on 15 of 17 repos. The quality advantages concentrate on:
- Codebase-specific traps that exploration alone doesn't reliably surface
- Architectural fit for design tasks (correct layer placement, convention compliance)
- Concrete bugs found (petshop-api cache key bug, cowsay async inconsistency, nextjs14-app race condition, alz-bicep enforcement logic bug)

**Efficiency:** Agents using ACF docs consistently use 60-70% fewer tool calls and tokens. They don't need to explore — the docs tell them where to look. Zero Haiku subagent delegation in 16/17 ACF runs means the primary model works directly instead of farming out exploration to a cheaper model.

**Where ACF didn't win:** travel-booking-api (ACF over-scoped the design) and cowsay (baseline caught a TypeScript integration ACF missed). Both scored Marginal — ACF was still net-positive on efficiency, just not on quality.

---

## Methodology

- **Spec version:** ACF v2.0.1 (787 lines + Design Task Guidance section)
- **ACF pipeline:** Stages 1 → 1.5 → 2 → 3 → 3.5 → 4 (generation + 3 verification passes)
- **Baseline:** Same model, same prompt, bare repo (no ACF docs, no agent spec)
- **Scoring:** Claude Opus 4.6, independent session, receives both responses anonymised
