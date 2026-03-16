> **Agent:** Do not read this file unless you are actively executing a specific task that references this plan by ID, or you have been explicitly instructed to consult it. See `docs/adc/README.md` for the full retrieval policy.

# Implementation Plan: [Feature Name]

**Date:** YYYY-MM-DD
**Feature:** Brief description of what is being implemented
**ADC:** [ADC-YYYY-MM-DD--short-slug](../YYYY-MM-DD--short-slug.md) *(omit if no ADC)*
**Status:** Planning | In Progress | Implemented | Blocked | Abandoned
**Effort:** Small | Medium | Large

---

## Overview

Brief description of what is being built and why.

### Out of Scope

What this plan intentionally does not cover. Helps prevent scope creep during implementation.

- [Thing explicitly excluded and why]

---

## Requirements

- **[Component A]:** What it must do
- **[Component B]:** What it must do

---

## Prerequisites

Inputs, values, or external actions required before implementation can begin. Omit if none.

| Input | Description | Provided? |
|-------|-------------|-----------|
| [Value name] | What it is and who provides it | Yes / No |

---

## Decisions, Constraints & Assumptions

Key findings, limitations, or trade-offs that shaped the plan. Keep brief — if the decision warrants full context, create an ADC and link it. Omit if straightforward.

- **[Decision]:** What was chosen and why. What was rejected.

### Assumptions

Things believed to be true but not yet verified. If an assumption proves wrong, revisit the plan.

- [Assumption and what would change if it's wrong]

---

## Configuration & Naming

Reference tables for resource names, environment-specific values, or other structured data that implementers need during execution. Omit if not applicable.

| Resource | Value |
|----------|-------|
| [Resource type] | [Name or value] |

---

## Affected Components

```
[Project/Module]
  └── path/to/File.ext    [NEW | MODIFY — describe change]
```

---

## Implementation Steps

### 1. [Step name]

**File:** `path/to/File.ext`

- What to create or change

**Dependencies:** None

### 2. [Step name]

**File:** `path/to/File.ext`

- What to create or change

**Dependencies:** Step 1

---

## Verification

How to confirm the implementation is correct. Include commands, checks, or acceptance criteria.

- [ ] [Validation step]
- [ ] [Validation step]

---

## Infrastructure Considerations

Note any schema changes, migrations, external dependencies, or prerequisites outside this repo. Omit if not applicable.
