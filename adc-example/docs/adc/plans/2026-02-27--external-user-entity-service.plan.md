> **Agent:** Do not read this file unless you are actively executing a specific task that references this plan by ID, or you have been explicitly instructed to consult it. See `docs/adc/README.md` for the full retrieval policy.

# Implementation Plan: External User Entity & Service

**Date:** 2026-02-27
**Feature:** Add ExternalUserEntity and ExternalUserService with external ID support
**Status:** Implemented

---

## Overview

Add a new entity `ExternalUserEntity` that mirrors `UserEntity` with an additional `ExternalId` field, and a corresponding `ExternalUserService` that provides a `GetUserByExternalIdAsync` method for lookup by external system identifiers.

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

## Architecture & Layer Impact

### Affected Components

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

### Architecture Rules Compliance

✅ Service layer owns business logic
✅ Entity follows project naming convention
✅ Service extends `BaseService`
✅ All async methods accept `CancellationToken`
✅ Mapper profiles in `ExampleApp.Setup/Mappers/`
✅ Models in `ExampleApp.Models`
✅ No direct data access from API layer

---

## Implementation Steps

### 1. Create ExternalUserEntity

**File:** `ExampleApp.Data/Entities/ExternalUserEntity.cs`

**Actions:**
- Copy structure from `UserEntity.cs`
- Add `ExternalId` property (string)
- Implement entity type configuration
- Configure entity mapping:
  - Table: `external_users`
  - Primary key: `user_id`
  - Add `ExternalId` column mapping: `external_id`
  - Copy all column configurations from `UserEntity`
  - Maintain same foreign key relationships
  - Add index on `ExternalId`

**Dependencies:** None

---

### 2. Create ExternalUserDto

**File:** `ExampleApp.Models/ExternalUserDto.cs`

**Actions:**
- Create model class mirroring `UserDto`
- Add `ExternalId` property
- Include all relevant user properties
- Add `Roles` collection property

**Dependencies:** None

---

### 3. Add Mapper Profile Entry

**File:** `ExampleApp.Setup/Mappers/EntityMappingProfile.cs`

**Actions:**
- Add mapping: `CreateMap<ExternalUserEntity, ExternalUserDto>()`
- Map `ExternalId` property
- Copy mapping logic from `UserEntity → UserDto`
- Explicitly `.Ignore()` unmapped destination members
- Ignore `Roles` (populated separately)

**Dependencies:** Step 1 (ExternalUserEntity), Step 2 (ExternalUserDto)

---

### 4. Create ExternalUserService

**File:** `ExampleApp.Services/ExternalUserService.cs`

**Actions:**
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
- Pass `cancellationToken` to all async calls
- Consider adding `GetUserByUserIdAsync` (fallback lookup)

**Dependencies:** Step 1, Step 2, Step 3

---

### 5. Register Service in DI

**File:** `ExampleApp.Api/Startup.cs`

**Actions:**
- Add service registration:
  ```csharp
  services.AddScoped<ExternalUserService>();
  ```

**Dependencies:** Step 4

---

### 6. Add DbContext Configuration

**File:** `ExampleApp.Data/AppDbContext.cs`

**Actions:**
- Add `DbSet<ExternalUserEntity>` property
- Ensure entity is included in `OnModelCreating`

**Dependencies:** Step 1

---

### 7. Create Unit Tests

**File:** `ExampleApp.Tests/Services/ExternalUserServiceTests.cs`

**Actions:**
- Test `GetUserByExternalIdAsync`:
  - Returns user when found
  - Returns null when not found
  - Filters disabled users
  - Passes cancellation token
- Follow project naming convention: `Method_ShouldResult_WhenCondition`

**Test Cases:**
```
GetUserByExternalIdAsync_ShouldReturnUser_WhenExternalIdExists
GetUserByExternalIdAsync_ShouldReturnNull_WhenExternalIdNotFound
GetUserByExternalIdAsync_ShouldReturnNull_WhenUserIsDisabled
GetUserByExternalIdAsync_ShouldPassCancellationToken_WhenCalled
```

**Dependencies:** Step 4

---

### 8. (Optional) Create API Controller

**File:** `ExampleApp.Api/Controllers/ExternalUserController.cs`

**Actions:**
- Create controller if API endpoint is needed
- Inject `ExternalUserService`
- Add `GET` endpoint: `/api/external-users/{externalId}`
- Add appropriate authorisation attributes
- Return appropriate HTTP status codes

**Dependencies:** Step 4, Step 5

---

### 9. (Optional) Add Integration Tests

**File:** `ExampleApp.Tests/Integration/ExternalUserServiceIntegrationTests.cs`

**Actions:**
- Test against live database (if required)
- Verify ORM query execution
- Test navigation properties load correctly
- Test projection to `ExternalUserDto`

**Dependencies:** All previous steps

---

## Database Migration Considerations

**Note:** This plan assumes the `external_users` table already exists with:
- All columns from `users` table
- Additional column: `external_id` (varchar 255)
- Primary key: `user_id`
- Index on `external_id` for lookup performance

**If table does not exist:** A database migration script will be needed (not part of this plan).

---

## Risk Assessment

### Low Risk
- New entity/service follows existing patterns
- No changes to existing `UserService` or `UserEntity`

### Medium Risk
- Entity configuration complexity (copying all `UserEntity` mappings)
- Potential for mapping errors if column names differ

### Risk Triggers (None present)
- ❌ No changes to existing API contracts
- ❌ No changes to authentication pipeline
- ❌ No cross-service communication changes
- ❌ No shared infrastructure changes

---

## Testing Strategy

1. **Unit Tests:** Mock dependencies, test service logic in isolation
2. **Integration Tests:** Optional, test against real DB if needed
3. **Manual Testing:** Verify ORM queries execute correctly

---

## Pre-Merge Checklist

- [ ] Build passes
- [ ] Unit tests pass
- [ ] Mapper profile explicitly ignores unmapped members
- [ ] All async methods include `CancellationToken` parameter
- [ ] Service extends `BaseService`
- [ ] Entity follows project naming convention
- [ ] No secrets committed

---

## Follow-ups / Future Considerations

- Consider bulk operations (`GetUsersByExternalIds`)
- Consider caching strategy if frequently accessed
- Add audit logging for external user access
- Consider `ExternalProviderId` column to support multiple identity providers
- Add validation for `ExternalId` format

---

## Notes

- `ExternalId` field should be indexed in database for performance
- Consider whether `ExternalId` should have a unique constraint
- Determine if roles/permissions work the same way as `UserService`

---

## Execution Status

**Status:** Implemented (2026-02-27)

All steps completed. See ADC-2026-02-27--external-user-entity for the full decision record.
