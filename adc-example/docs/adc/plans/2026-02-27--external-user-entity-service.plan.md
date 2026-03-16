> **Agent:** Do not read this file unless you are actively executing a specific task that references this plan by ID, or you have been explicitly instructed to consult it. See `docs/adc/README.md` for the full retrieval policy.

# Implementation Plan: External User Entity & Service

**Date:** 2026-02-27
**Feature:** Add ExternalUserEntity and ExternalUserService with external ID support
**ADC:** [ADC-2026-02-27--external-user-entity](../2026-02-27--external-user-entity.md)
**Status:** Implemented
**Effort:** Medium

---

## Overview

Add a new entity `ExternalUserEntity` that mirrors `UserEntity` with an additional `ExternalId` field, and a corresponding `ExternalUserService` that provides a `GetUserByExternalIdAsync` method for lookup by external system identifiers.

### Out of Scope

- Implementing actual OAuth/SAML authentication flows — this plan only adds the entity and service layer
- Modifying existing `UserEntity` or `UserService`
- Identity provider integration or cross-service authentication coordination

---

## Requirements

- **Entity:** ExternalUserEntity
  - Copy all fields from `UserEntity`
  - Add new field: `ExternalId` (string)
  - Map to database table: `external_users`
  - Column name for external ID: `external_id`

- **Service:** ExternalUserService
  - Extend `BaseService`
  - Implement `GetUserByExternalIdAsync(string externalId, CancellationToken cancellationToken)`
  - Use direct ORM queries
  - Return mapped DTO type

---

## Decisions, Constraints & Assumptions

- **Separate entity over extending UserEntity:** Keeps external auth concerns isolated and avoids migrating the existing `users` table. Rejected: nullable `ExternalId` on `UserEntity`, junction table approach.

### Assumptions

- The `external_users` table already exists with all columns from `users` plus `external_id` (varchar 255), primary key `user_id`, and an index on `external_id`. If this assumption is wrong, a database migration script will be needed before deployment.
- A single `external_id` column is sufficient — multi-provider support (requiring a provider discriminator column) is not needed yet.

---

## Affected Components

```
ExampleApp.Data
  └── Entities/ExternalUserEntity.cs                [NEW]

ExampleApp.Models
  └── ExternalUserDto.cs                            [NEW]

ExampleApp.Setup
  └── Mappers/EntityMappingProfile.cs              [MODIFY — add ExternalUserEntity → ExternalUserDto mapping]

ExampleApp.Services
  └── ExternalUserService.cs                        [NEW]

ExampleApp.Api (or consuming API)
  └── Startup.cs                                    [MODIFY — register ExternalUserService]
  └── Controllers/ExternalUserController.cs        [NEW — if API endpoint needed]

ExampleApp.Tests
  └── Services/ExternalUserServiceTests.cs         [NEW]
```

---

## Implementation Steps

### 1. Create ExternalUserEntity

**File:** `ExampleApp.Data/Entities/ExternalUserEntity.cs`

- Copy structure from `UserEntity.cs`
- Add `ExternalId` property (string)
- Configure entity mapping: table `external_users`, primary key `user_id`, column `external_id`
- Copy all column configurations from `UserEntity`
- Add index on `ExternalId`

### 2. Create ExternalUserDto

**File:** `ExampleApp.Models/ExternalUserDto.cs`

- Create model class mirroring `UserDto`
- Add `ExternalId` property
- Add `Roles` collection property

### 3. Add Mapper Profile Entry

**File:** `ExampleApp.Setup/Mappers/EntityMappingProfile.cs`

- Add mapping: `CreateMap<ExternalUserEntity, ExternalUserDto>()`
- Copy mapping logic from `UserEntity → UserDto`
- Explicitly `.Ignore()` unmapped destination members

**Dependencies:** Steps 1, 2

### 4. Create ExternalUserService

**File:** `ExampleApp.Services/ExternalUserService.cs`

- Extend `BaseService`
- Implement `GetUserByExternalIdAsync`:
  ```csharp
  public async Task<ExternalUserDto> GetUserByExternalIdAsync(
      string externalId,
      CancellationToken cancellationToken)
  {
      return await _dbContext.Set<ExternalUserEntity>()
          .Where(u => u.ExternalId == externalId && !u.IsDisabled)
          .ProjectTo<ExternalUserDto>(_mapper.ConfigurationProvider)
          .FirstOrDefaultAsync(cancellationToken);
  }
  ```
- Consider adding `GetUserByUserIdAsync` (fallback lookup)

**Dependencies:** Steps 1, 2, 3

### 5. Register Service in DI

**File:** `ExampleApp.Api/Startup.cs`

- Add `services.AddScoped<ExternalUserService>();`

**Dependencies:** Step 4

### 6. Add DbContext Configuration

**File:** `ExampleApp.Data/AppDbContext.cs`

- Add `DbSet<ExternalUserEntity>` property
- Ensure entity is included in `OnModelCreating`

**Dependencies:** Step 1

### 7. Create Unit Tests

**File:** `ExampleApp.Tests/Services/ExternalUserServiceTests.cs`

- Test `GetUserByExternalIdAsync`: returns user when found, returns null when not found, filters disabled users, passes cancellation token
- Follow naming convention: `Method_ShouldResult_WhenCondition`

**Dependencies:** Step 4

### 8. (Optional) Create API Controller

**File:** `ExampleApp.Api/Controllers/ExternalUserController.cs`

- `GET /api/external-users/{externalId}`
- Inject `ExternalUserService`, add authorisation attributes

**Dependencies:** Steps 4, 5

---

## Verification

- [x] `ExternalUserService.GetUserByExternalIdAsync` returns a mapped DTO when a matching, non-disabled user exists
- [x] Returns null when no matching user exists
- [x] Disabled users are filtered out of results
- [x] `CancellationToken` is passed through to all async calls
- [x] `EntityMappingProfile` correctly maps `ExternalUserEntity` to `ExternalUserDto` with no unmapped members
- [x] Service is registered as scoped in DI

---

## Infrastructure Considerations

The `external_users` table must exist before deployment with all columns from `users` plus `external_id` (varchar 255), primary key `user_id`, and an index on `external_id`. DBA must create the table — no automatic migration is included in this plan.
