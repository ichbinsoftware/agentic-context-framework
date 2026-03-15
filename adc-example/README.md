# ADC Example — ExampleApp

This directory contains a real-world ADC example based on a fictional .NET application called **ExampleApp**.

## The Fictional System

ExampleApp is a layered .NET API that handles user management and authentication. It follows a clean separation of concerns across seven projects:

| Project | Role |
| :--- | :--- |
| `ExampleApp.Data` | EF Core entities mapped to SQL tables (`users`, `external_users`) |
| `ExampleApp.Models` | DTOs (e.g. `UserDto`, `ExternalUserDto`) implementing shared interfaces (`IUser`) |
| `ExampleApp.Services` | Business logic; services extend `BaseService` and use `ProjectTo<T>()` for efficient mapping |
| `ExampleApp.Setup` | AutoMapper profiles in `Mappers/EntityMappingProfile.cs` |
| `ExampleApp.Api` | Controllers, DI registration (`Startup.cs`), HTTP endpoints |
| `ExampleApp.Auth` | Authentication pipeline (OAuth/SAML integration layer) |
| `ExampleApp.Tests` | Unit tests following the `Method_ShouldResult_WhenCondition` naming convention |

Key conventions in this codebase:
- All async methods accept a `CancellationToken`
- Services are registered as scoped in DI
- Disabled users are filtered at the service layer, not the controller
- Mapper profiles explicitly `.Ignore()` unmapped members

## What the Example Shows

- [`docs/adc/2026-02-27--external-user-entity.md`](docs/adc/2026-02-27--external-user-entity.md) — An ADC record for adding `ExternalUserEntity` and `ExternalUserService` to support OAuth/SAML identity provider correlation. Demonstrates all 5 ADC sections: Summary, Motivation, Approach, Impact, and Rollout.

- [`docs/adc/plans/2026-02-27--external-user-entity-service.plan.md`](docs/adc/plans/2026-02-27--external-user-entity-service.plan.md) — The matching execution plan with step-by-step implementation instructions, architecture compliance checklist, and pre-merge checklist.

## How to Read These Files

Start with the ADC record to understand the decision — what changed, why, and what was rejected. Then read the plan if you want to see how the implementation was sequenced. This mirrors how an AI agent would consume them: ADC for context, plan for execution.
