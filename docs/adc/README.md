# Agent Decision Context (ADC)

## Purpose

The `docs/adc/` directory contains **Agent Decision Context (ADC)**
documents.

These are not just Architectural Decision Records (ADRs). They capture
the **full context of change**, including:

-   What changed
-   Why it changed
-   What it entails
-   What parts of the system were affected
-   Operational and rollout considerations

The goal is long-term clarity for:

-   Future maintainers
-   Refactors
-   Incident analysis
-   Architectural evolution
-   AI/agent-assisted development (when explicitly invoked)

------------------------------------------------------------------------

## When to Create an ADC

Create an ADC when:

-   Introducing a new feature
-   Making a significant architectural change
-   Changing cross-cutting behavior
-   Modifying data models or contracts
-   Introducing new infrastructure or dependencies
-   Implementing non-trivial tradeoffs
-   Performing large refactors with system impact

You do NOT need an ADC for:

-   Minor bug fixes
-   Small refactors with no architectural impact
-   Cosmetic or documentation changes

When unsure: create one. They are cheap and high-value.

------------------------------------------------------------------------

## Naming Convention

Files must follow:

YYYY-MM-DD--short-feature-slug.md

Example:

2026-02-25--feature-flags-for-checkout.md
2026-03-02--oauth-refresh-token-rotation.md

Rules:

-   Use ISO date format (YYYY-MM-DD) for proper sorting.
-   Use lowercase kebab-case for slugs.
-   Keep slugs concise but descriptive.
-   Never rename an ADC after it is merged.

------------------------------------------------------------------------

## Stability & Referencing

Each ADC contains a stable `id` in its frontmatter.

Example:

id: ADC-2026-02-25--feature-flags-for-checkout

You may reference ADCs in:
- PR descriptions
- Code comments
- Issues
- Other ADCs (via `related:`)

Example code comment:

// Context: ADC-2026-02-25--feature-flags-for-checkout

------------------------------------------------------------------------

## Status Lifecycle

An ADC may have the following statuses:

-   proposed
-   accepted
-   implemented
-   superseded
-   rejected

If superseded, reference the replacing ADC in `superseded_by:`.

------------------------------------------------------------------------

## Agent Usage Policy

AI agents MUST NOT read ADC files by default.

Agents may read ADCs only when:

-   Explicitly instructed to
-   Asked for historical context
-   An ADC is referenced in code or task instructions
-   Performing architectural analysis where context is required

This prevents unnecessary context pollution.

------------------------------------------------------------------------

## Design Philosophy

ADCs are:

-   Lightweight
-   Honest about tradeoffs
-   Operationally aware
-   Focused on long-term clarity
-   Designed for both humans and selective agent retrieval

They are NOT:

-   Lengthy design documents
-   Formal approval gates
-   Bureaucratic overhead

Keep them concise but complete.
