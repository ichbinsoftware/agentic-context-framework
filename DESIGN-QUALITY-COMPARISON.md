# Design Quality Comparison — With ACF vs Without

The [task benchmarks](BENCHMARK-TASKS.md) show aggregate scores. The [accuracy benchmarks](BENCHMARK-ACCURACY.md) show error counts. This document shows what the quality difference actually looks like — two agent responses to the same prompt on the same codebase, side by side.

**Repo:** [petshop-api](https://github.com/petshop-system/petshop-api) (Go, hexagonal architecture, ports & adapters)
**Prompt:** "add a new payment endpoint, receive a standard transaction json input"

---

## Without ACF — Pattern-matched design

The agent correctly identified the hexagonal architecture pattern:

- Domain → Ports → Service → DB adapter → Handler → Router → Main wiring
- Proposed a `PaymentDomain` struct
- Listed 8 files to create/modify
- Offered 3 paths: full vertical slice, handler-only MVP, service + handler without DB

### What it produced

```go
type PaymentDomain struct {
    ID              int64
    CustomerID      int64
    Amount          float64
    Currency        string
    Method          string    // e.g. "credit_card", "pix", "boleto"
    Status          string    // e.g. "pending", "completed", "failed"
    TransactionDate time.Time
    Description     string
}
```

8 files listed. No SQL migration. No test mocks. No connection to existing domain entities.

### What it didn't do

- Did not read the database schema (`configuration/db/petshop_api.sql`)
- Did not check if any payment-related tables or fields already exist
- Did not notice `schedule.price` or `service.price` fields
- Did not connect `PaymentDomain` to any existing entity (no `ScheduleID`)
- Did not check how the cache adapter works (single shared struct vs per-entity)
- Did not include SQL migration or test mock files in the plan

---

## With ACF — Source-grounded design

The agent identified the same hexagonal pattern, then went further:

- Read `configuration/db/petshop_api.sql` — found no payment table exists
- Found `schedule` table has a `price` field and references pets + service attention slots
- Found `service` table has a `price` field
- Noted the Redis cache adapter is a single shared struct reused across all resources
- Connected the payment domain to the existing schedule/booking concept

### What it produced

- 11 files listed (not 8) — included SQL migration, DB mock, and service mock
- Proposed `ScheduleID` on `PaymentDomain` to tie payments to existing bookings
- Offered Path 3: extend the Schedule resource instead of a new vertical slice — a legitimate alternative the no-ACF response never considered
- Noted "no payment table exists" as a concrete finding, not an assumption

### What it did differently

1. **Read the database schema** before designing the domain struct
2. **Connected to existing entities** (`schedule`, `service` via `ScheduleID`)
3. **Identified the cache pattern** (single shared Redis struct, not one per entity)
4. **Included full scope** (SQL migration, mock files for testing)
5. **Offered a domain-aware alternative** (extend Schedule rather than new resource)

---

## Comparison

| Dimension | Without ACF | With ACF |
|---|---|---|
| Architecture understanding | Correct | Correct |
| Source verification | Did not read schema or related tables | Read schema, found existing price fields |
| Domain awareness | Generic payment struct, no relationship to existing entities | Connected to schedule/service, proposed ScheduleID |
| Implementation scope | 8 files, missing migration + mocks | 11 files, complete vertical slice |
| Alternatives | 3 paths, all isolated from existing domain | 3 paths, including domain-integrated option |
| Cache understanding | Not mentioned | Correctly identified shared Redis adapter pattern |
| Would the plan work if followed? | Would fail — no table to write to | Would work end-to-end |

**The core difference:** Without ACF, the agent designed from the pattern. With ACF, the agent designed from the source.

The no-ACF response saw "hexagonal architecture" and produced a template-correct plan that could apply to any hexagonal Go project. The ACF response saw "hexagonal architecture" and then asked: what's already in this specific codebase that the payment feature should connect to?

---

## Why This Happens

Without ACF documentation, the agent has no orientation. It explores the codebase, identifies the architectural pattern, and designs from that pattern. The architecture is correct. The design is disconnected from the codebase's actual domain model, existing tables, and infrastructure patterns.

With ACF documentation, the agent loads the architecture overview and retrieval discipline first — knows the layers, knows which files matter, knows the conventions. Then it reads the affected source files to verify the design against what actually exists. The documentation tells it *where to look*. The source tells it *what to build*.

Both agents understood the architecture. Only one understood the codebase.

---

## What ACF Provides Here

Three specific ACF-generated sections made the difference:

1. **Retrieval Discipline** — told the agent to read the database layer before designing a new resource. Without this, the agent skipped the schema entirely.

2. **Architecture Rules** — documented the ports-and-adapters pattern with specific file conventions (`port/input/`, `port/output/`, `adapter/output/database/`). The agent knew the complete vertical slice without guessing.

3. **Design Task Guidance** — told the agent to verify that existing structure doesn't already support the feature before proposing changes. This is why the agent checked for existing `price` fields and proposed extending Schedule as an alternative.

None of these require the agent to be smarter. They require the agent to look in the right places before designing. That's what ACF does — it replaces speculation with targeted source reads.
