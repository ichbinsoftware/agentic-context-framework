---
date: 2026-02-27
id: ADC-2026-02-27--external-user-entity
related: []
status: implemented
---

> **Agent:** Do not read this file unless explicitly instructed, an ADC ID is referenced in your task, or you are performing architectural analysis. See `docs/adc/README.md` for the full retrieval policy.

# External User Entity and Service

## 1. Summary (What Changed)

Introduced support for users authenticated via external identity providers.

- Introduced `ExternalUserEntity` mapping to `external_users` table
- Introduced `ExternalUserDto` model in `ExampleApp.Models`
- Introduced `ExternalUserService` with external ID lookup capability
- Modified `EntityMappingProfile` to include `ExternalUserEntity → ExternalUserDto` mapping
- Added unit tests for `ExternalUserService`

**Quick read**: New entity and service to support external authentication, mirroring the existing `UserEntity`/`UserService` pattern with an added `ExternalId` field for third-party identity correlation.

---

## 2. Motivation (Why)

### Problem
The existing `UserEntity` only supports internal authentication. Integration with external identity providers (OAuth, SAML, etc.) requires tracking external system identifiers alongside internal user records.

### Goals
- Enable lookup of users by external identity provider ID
- Maintain parity with existing `UserEntity` structure
- Support future external authentication flows
- Follow established architecture patterns

### Non-goals
- Implementing actual OAuth/SAML authentication flows (auth logic)
- Modifying existing `UserEntity` or `UserService`
- Cross-service authentication coordination
- Identity provider integration

---

## 3. Approach (What It Entails)

### Architecture Decisions

**Separate Entity vs. Extension**
- Created new `ExternalUserEntity` rather than adding `ExternalId` to `UserEntity`
- Rationale: Keeps external auth concerns isolated, avoids migration of the existing `users` table

**Mirror UserEntity Structure**
- Copied all fields from `UserEntity` to maintain consistency
- Preserved existing foreign key relationships
- Applied identical ORM configurations

**Service Pattern**
- Extends `BaseService` (standard pattern)
- Uses direct ORM queries with `ProjectTo<T>()` for efficient mapping
- Filters disabled users automatically
- Accepts `CancellationToken` on all async methods

### Key Implementation Details

```
ExampleApp.Data
  └── ExternalUserEntity.cs (entity, maps to external_users table)

ExampleApp.Models
  └── ExternalUserDto.cs (implements IUser interface)

ExampleApp.Setup/Mappers
  └── EntityMappingProfile.cs (ExternalUserEntity → ExternalUserDto)

ExampleApp.Services
  └── ExternalUserService.cs (GetUserByExternalIdAsync, GetUserByUserIdAsync)
```

**Entity Configuration:**
- Table: `external_users`
- Primary Key: `user_id`
- New field: `external_id` (varchar 255)
- Same column mappings as `users` table

### Alternatives Considered

**Option A: Extend UserEntity with nullable ExternalId**
- Rejected: Would require schema migration on heavily-used `users` table
- Rejected: Mixes internal and external authentication concerns

**Option B: Junction table linking UserEntity to external IDs**
- Rejected: Additional join complexity for every lookup
- Rejected: Over-engineering for current requirements

**Option C: Store external ID in an existing field**
- Rejected: Data integrity issues, no proper indexing

---

## 4. Impact / Blast Radius

### Components / Services

**Affected:**
- `ExampleApp.Data` — new entity
- `ExampleApp.Models` — new model
- `ExampleApp.Setup` — mapper profile addition
- `ExampleApp.Services` — new service
- `ExampleApp.Tests` — new test class

**Not Affected:**
- Existing `UserEntity` and `UserService` (unchanged)
- API controllers (no endpoints created yet)
- Authentication pipeline (`ExampleApp.Auth`)
- Cross-service communication

### Data Model / Migrations

**Database Requirements:**
- Assumes `external_users` table exists with schema matching `users` table + `external_id` column
- No automatic migration provided
- DBA must create table manually before deployment

**Schema:**
```sql
-- Assumed structure (not created by this change)
CREATE TABLE external_users (
    user_id     VARCHAR(50) PRIMARY KEY,
    external_id VARCHAR(255),
    -- ... all other columns from users table
)
```

### APIs / Contracts

**No API endpoints created** — service layer only.

Consuming APIs must:
- Register `ExternalUserService` in DI container
- Create controller endpoints if external user access is needed
- Apply appropriate authorisation policies

### Security Considerations

- External ID field is not encrypted (assumes external provider handles security)
- Disabled user filtering prevents access to inactive accounts
- No built-in rate limiting on external ID lookups
- Assumes `external_id` is unique per external provider (not enforced at DB level)

### Performance Considerations

**Positive:**
- ORM `ProjectTo<T>()` generates efficient SQL projections
- Eager loading of related entities minimises N+1 queries

**Potential Issues:**
- `external_id` column should be indexed for lookup performance
- No caching strategy implemented

### Observability / Logging / Alerts

- No custom logging added (relies on base service logging)
- No metrics or telemetry for external user access
- Consider adding:
  - External ID lookup success/failure metrics
  - Audit logging for external user authentication events

---

## 5. Rollout & Operations

### Safe Introduction

**Prerequisites:**
1. DBA creates `external_users` table in target environments
2. Index `external_id` column for performance
3. Populate table with initial external user data (if migrating)

**Deployment Steps:**
1. Deploy code with new entity/service (no immediate impact)
2. Register `ExternalUserService` in consuming API when needed
3. Create API endpoints for external user access
4. Configure external auth provider integration

**Backward Compatibility:**
- 100% backward compatible
- No changes to existing `UserEntity` or `UserService`
- Consuming code must explicitly opt-in by injecting `ExternalUserService`

### Rollback Plan

**If issues arise:**
1. Remove `ExternalUserService` DI registration from consuming APIs
2. Remove any controllers using `ExternalUserService`
3. Redeploy without external user endpoints

**Database rollback:**
- `external_users` table can remain (no harm if unused)
- Drop table if full rollback needed: `DROP TABLE external_users`

**Code rollback:**
- Revert commits affecting:
  - `ExampleApp.Data/Entities/ExternalUserEntity.cs`
  - `ExampleApp.Models/ExternalUserDto.cs`
  - `ExampleApp.Services/ExternalUserService.cs`
  - `ExampleApp.Setup/Mappers/EntityMappingProfile.cs`

---

## 6. Risks & Tradeoffs

### Risks

**Low Risk:**
- Isolated new code, no changes to existing services
- Follows established patterns (minimal learning curve)

**Medium Risk:**
- Database table must exist before code deployment (coordination required)
- No uniqueness constraint on `external_id` (data integrity risk)
- No validation of external ID format

**Tradeoffs:**

**Added Complexity:**
- Additional entity/model/service to maintain
- Duplication of `UserEntity` structure (schema changes require parallel updates)

**No Lock-in:**
- Standard ORM patterns, easy to refactor if needed

**Future Constraints:**
- Multiple external providers may require a provider discriminator column

---

## 7. Follow-ups / Future Work

- Implement bulk lookup: `GetUsersByExternalIdsAsync(IEnumerable<string> externalIds)`
- Add unique constraint on `external_id` column (database-level)
- Add validation for external ID format
- Implement caching strategy for frequently accessed external users
- Add audit logging for external user access
- Consider `ExternalProviderId` column to support multiple identity providers
- Add integration tests against live database
- Create API controller and endpoints if external user access is needed

---

## 8. Notes

**Entity Configuration:**
- `ExternalId` property placed first for visibility
- All column mappings copied from `UserEntity` to ensure consistency
- `external_id` column max length set to 255 (standard for OAuth sub claims)

**Mapper Profile:**
- Mapping logic identical to `UserEntity → UserDto`
- `Roles` property ignored (populated separately if needed)

**Service Methods:**
- `GetUserByExternalIdAsync`: Primary lookup by external provider ID
- `GetUserByUserIdAsync`: Fallback lookup by internal user ID (for dual-mode users)

**Related Code Reference:**
```csharp
// Context: ADC-2026-02-27--external-user-entity
public async Task<ExternalUserDto> GetUserByExternalIdAsync(
    string externalId,
    CancellationToken cancellationToken)
```

**If schema differs from assumption, update `ExternalUserEntity.cs` mappings accordingly.**

---

**Status:** Implemented (2026-02-27)
**Plan File:** `docs/adc/plans/2026-02-27--external-user-entity-service.plan.md`
