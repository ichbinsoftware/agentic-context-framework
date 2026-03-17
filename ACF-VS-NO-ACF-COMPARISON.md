# ACF vs No ACF — Side-by-Side Comparison

A real-world comparison of the same prompt, same repo, and same model (Claude Sonnet 4.6 via GitHub Copilot), with and without ACF context in place.

**Prompt:** Add a new ProductService that queries a new `products` database table (Id, Name, CreatedDate) with Get All and Get By Id methods.

**Repo:** A .NET layered API with Resolved services, EF Core entities (prefixed naming convention), AutoMapper profiles, model DTOs, and a JSON-based route configuration.

---

## Summary

### With ACF

- Started with `ARCHITECTURE-OVERVIEW.md` and `DATA-ACCESS-LAYER.md` — knew the layers before touching source
- Targeted globs: `App.Service/Services/*.cs`, `App.Data/Entities/Tables/Ent*.cs`
- Read 3 representative services (MessageService, NotificationsService, OrderHistoryService) to triangulate the pattern
- Checked the mapper profile, a model DTO, a test file, and Routes.json once each
- Arrived at a correct 6-file plan:
  1. `EntProduct.cs` — entity
  2. `Product.cs` — model/DTO
  3. `EntityMapperProfile.cs` — mapper entry
  4. `ProductService.cs` — dynamic service
  5. `Routes.json` — route registration
  6. `ProductServiceTests.cs` — unit tests
- ~15 tool calls from start to plan

### Without ACF

- Opened with a generic "explore" agent that returned temp files it then had to re-read via shell
- Used `find`, `grep`, `head`, `tail`, `cat`, `xargs`, `wc`, `ls` across the repo instead of targeted reads
- Read `OrderCancelService.cs` (1 line) and `MiscService.cs` (empty) — wasted calls on stub files
- Searched `Routes.json` 4 separate times with different grep patterns
- Searched for entity/DbContext registration 3 times, eventually concluding it must be in a NuGet package
- Explored `ScaffoldDb/Program.cs`, `App.Data.csproj`, `EntCountry.cs`, `ShippingService.cs` — none needed for the task
- Said "now I have a clear picture" 3 times, each time followed by more exploration
- 30+ tool calls and still hadn't started writing code by the end of the log
- Reached roughly the same understanding eventually, but at 2x the cost and without ever being confident enough to stop exploring

---

## With ACF — Session Log

```
User:
  I need to add a new Service - ProductService that will query the (new)
  products database table.
  - The products database table will just have Id (int), Name (varchar 64),
    CreatedDate (DateTime)
  - The service can just be initially Get All & Get ById

Agent:
  Let me start by reading the AGENTS.md file and understanding the
  architecture before planning.

  ● Read docs/ARCHITECTURE-OVERVIEW.md                        ← Step 2 of Retrieval Discipline
    └ 223 lines read

  ● Read docs/DATA-ACCESS-LAYER.md                            ← Deep-dive doc for the affected layer
    └ 133 lines read

  Now I know the layers: Entity → Model → Mapper → Resolved Service
  → Routes.json → Tests. Let me verify the patterns from source.

  ● Glob "App.Service/Services/*.cs"                          ← Targeted search
    └ 11 files found

  ● Glob "App.Data/Entities/Tables/Ent*.cs"                   ← Confirms Ent* naming convention
    └ 178 files found

  ● Read App.Service/Services/MessageService.cs               ← Simple service example
    └ 54 lines read

  ● Read App.Service/Services/AppBaseService.cs               ← Base class
    └ 18 lines read

  ● Read App.Unit.Tests/App.Service/ReferenceServiceTest.cs   ← Test pattern
    └ 35 lines read

  ● Read App.Data/Entities/Tables/EntMessage.cs               ← Entity pattern
    └ 138 lines read

  ● Read App.Api/Routes.json (first 60 lines)                 ← Route config
    └ 61 lines read

  ● Read App.Service/Services/Resolved/NotificationsService.cs ← Resolved service pattern
    └ 60 lines read

  ● Read App.Common.Setup/Mappers/EntityMapperProfile.cs      ← Mapper pattern
    └ 60 lines read

  ● Read App.Common/Models/Notification.cs                    ← Model/DTO pattern
    └ 24 lines read

  ● Read App.Service/Services/Resolved/OrderHistoryService.cs  ← Second example to confirm
    └ 50 lines read

  ● Read App.Unit.Tests/App.Service/OrderHistoryTest.cs       ← Test pattern confirmation
    └ 42 lines read

  I have a clear picture. Here is the plan:

  1. EntProduct.cs          — Entity in App.Data/Entities/Tables/
  2. Product.cs             — Model/DTO in App.Model/
  3. EntityMapperProfile    — Add EntProduct → Product mapping
  4. ProductService.cs      — Resolved service in App.Service/Services/Resolved/
  5. Routes.json            — Register GET all and GET by ID routes
  6. ProductServiceTests    — Unit tests in App.Unit.Tests/

  ~15 tool calls. Ready to implement.
```

---

## Without ACF — Session Log

```
User:
  I need to add a new Service - ProductService that will query the (new)
  products database table.
  - The products database table will just have Id (int), Name (varchar 64),
    CreatedDate (DateTime)
  - The service can just be initially Get All & Get ById

Agent:
  Let me explore the codebase to understand the structure before planning.

  ● Explore (background agent)                                ← Generic exploration
    └ Agent started

  ● shell: wc -l BaseService.cs                               ← Counting lines via shell
    └ 2 lines

  ● shell: cat /var/folders/.../copilot-tool-output-*.txt      ← Reading agent temp files
    └ 8 lines

  ● shell: head -300 /var/folders/.../copilot-tool-output-*.txt
    └ 301 lines

  ● shell: tail -300 /var/folders/.../copilot-tool-output-*.txt
    └ 301 lines

  Now I have a comprehensive understanding. Let me look at Resolved
  services since ProductService should follow that pattern.

  ● Explore (second background agent)                         ← Another generic explore
    └ Agent started

  ● Read App.Data/Entities/Tables/EntPartner.cs               ← Entity example
    └ 101 lines read

  ● shell: cat /var/folders/.../copilot-tool-output-*.txt      ← Reading second agent temp files
    └ 8 lines

  ● shell: ls App.Service/Services/Resolved/                    ← Listing services
    └ 33 files

  ● Read OrderCancelService.cs                                 ← Dead end: 1 line stub
    └ 1 line read

  ● shell: find ... -name "MapperProfile.cs"                   ← Searching for mapper
    └ 2 results

  ● shell: find ... -name "AppBaseService.cs" ...              ← Searching for base service
    └ 2 results

  ● Read OrderCancelService.cs (again, with line range)        ← Re-reading the same stub
    └ 60 lines read

  ● Read AppBaseService.cs                                     ← Base class
    └ 18 lines read

  ● shell: head -60 MapperProfile.cs                           ← Mapper via shell
    └ 61 lines

  Now I have a good picture. Let me look at a simpler dynamic service
  and the DbContext registration.                              ← Still exploring

  ● shell: ls App.Service/Services/Resolved/                    ← Listed this directory already
    └ 33 files

  ● shell: find ... -name "AppDbContext.cs" ...                ← Searching for DbContext
    └ No results

  ● shell: grep "modelBuilder.ApplyConfiguration" ... -l       ← Searching for entity registration
    └ 1 result

  ● shell: head -50 Routes.json                                ← Routes.json attempt #1
    └ 52 lines

  ● Read NotificationsService.cs                               ← Resolved service example
    └ 60 lines read

  ● shell: find ... "ApplyConfigurationsFromAssembly" ... -l   ← Entity registration search #2
    └ 3 results

  ● shell: find ... | xargs grep "OnModelCreating" ...         ← Entity registration search #3
    └ 1 result

  ● shell: grep -A20 "ReferenceService" Routes.json            ← Routes.json attempt #2
    └ 1 line (no match)

  ● shell: grep -B2 -A8 '"Http": "GET"' Routes.json           ← Routes.json attempt #3
    └ 81 lines

  ● shell: find ... "IEntityTypeConfiguration" ... | head      ← Entity config search
    └ 6 results

  Now I have a clear picture. Let me check ShippingService and
  how entities are picked up by DbContext.                     ← Still exploring

  ● shell: cat ShippingService.cs | head -80                   ← Unrelated service
    └ 81 lines

  ● shell: find ... -name "*.cs" | xargs grep "DbContext" ...  ← DbContext search #2
    └ 3 results

  ● shell: head -100 ScaffoldDb/Program.cs                     ← Dead end: scaffolding tool
    └ 15 lines

  ● shell: ls App.Data/Entities/Tables/ | grep -i "product"    ← Looking for existing product entity
    └ No match

  ● Read EntCountry.cs                                         ← Simple entity example (not needed)
    └ 20 lines read

  ● shell: cat App.Data/App.Data.csproj                        ← Checking NuGet packages
    └ 19 lines

  Now I have all the information I need. Let me check one more thing.  ← Still exploring

  ● shell: tail -30 Routes.json                                ← Routes.json attempt #4
    └ 30 lines

  ● shell: ls DBScripts/                                       ← Checking DB scripts folder
    └ 3 files

  Now I have everything I need. Let me create the plan...

  30+ tool calls. Still hadn't written any code.
```

---

## Key Takeaways

| | With ACF | Without ACF |
|:---|:---|:---|
| **First action** | Read architecture docs | Generic repo explore |
| **Navigation strategy** | Layer-by-layer walkthrough | Undirected shell commands |
| **Tool calls to plan** | ~15 | 30+ (and still exploring) |
| **Dead-end reads** | 1 (MiscService) | 5+ (stubs, csproj, ScaffoldDb, NuGet inference) |
| **Route config searches** | 1 | 4 |
| **Entity registration searches** | 0 (docs explained it) | 3 |
| **False confidence cycles** | 0 | 3 ("now I have a clear picture" → more exploring) |
| **DB schema knowledge** | Docs explained schema is managed in a separate repo — no time wasted searching | Searched for `ScaffoldDb/`, `DBScripts/`, and `.csproj` trying to find migration/schema tooling that doesn't exist in this repo |
| **Outcome** | Correct plan, ready to implement | Same understanding, 2x the cost, no code written |

**Same prompt. Same repo. Same model. The only difference was structured context.**
