---
date: 2026-02-27
id: ADC-2026-02-27--external-user-entity
related: []
status: implemented
---

> **Agent:** Do not read this file unless explicitly instructed, an ADC ID is referenced in your task, or you are performing architectural analysis. See `docs/adc/README.md` for the full retrieval policy.

# External User Entity and Service

## 1. Summary

Introduced support for users authenticated via external identity providers.

- Introduced `ExternalUserEntity` mapping to `external_users` table
- Introduced `ExternalUserDto` model in `ExampleApp.Models`
- Introduced `ExternalUserService` with external ID lookup capability
- Modified `EntityMappingProfile` to include `ExternalUserEntity → ExternalUserDto` mapping
- Added unit tests for `ExternalUserService`

**Quick read**: New entity and service to support external authentication, mirroring the existing `UserEntity`/`UserService` pattern with an added `ExternalId` field for third-party identity correlation.

---

## 2. Motivation

The existing `UserEntity` only supports internal authentication. Integration with external identity providers (OAuth, SAML, etc.) requires tracking external system identifiers alongside internal user records.

**Goals:**
- Enable lookup of users by external identity provider ID
- Maintain parity with existing `UserEntity` structure
- Support future external authentication flows
- Follow established architecture patterns

**Non-goals:**
- Implementing actual OAuth/SAML authentication flows (auth logic)
- Modifying existing `UserEntity` or `UserService`
- Cross-service authentication coordination
- Identity provider integration

---

## 3. Approach

### Solution

Created a new `ExternalUserEntity` rather than extending `UserEntity`, keeping external auth concerns isolated and avoiding migration of the existing `users` table. The entity mirrors `UserEntity` with an additional `ExternalId` field.

The service extends `BaseService`, uses `ProjectTo<T>()` for efficient mapping, filters disabled users automatically, and accepts `CancellationToken` on all async methods.

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

Entity configuration: table `external_users`, primary key `user_id`, new field `external_id` (varchar 255).

### Alternatives Considered

- **Extend UserEntity with nullable ExternalId** — rejected: requires schema migration on heavily-used `users` table, mixes internal and external auth concerns
- **Junction table linking UserEntity to external IDs** — rejected: additional join complexity, over-engineering for current requirements
- **Store external ID in an existing field** — rejected: data integrity issues, no proper indexing

---

## 4. Impact

- **Components:** `ExampleApp.Data` (new entity), `.Models` (new DTO), `.Setup` (mapper addition), `.Services` (new service), `.Tests` (new test class). Existing `UserEntity`, `UserService`, controllers, and auth pipeline are unchanged.
- **Data / migrations:** Assumes `external_users` table exists with schema matching `users` + `external_id` column. No automatic migration — DBA must create table before deployment.
- **APIs / contracts:** No endpoints created. Service layer only. Consumers must register `ExternalUserService` in DI and create controller endpoints if needed.
- **Security:** External ID not encrypted (assumes provider handles security). Disabled user filtering prevents inactive account access. No uniqueness constraint on `external_id` (not enforced at DB level).
- **Performance:** `ProjectTo<T>()` generates efficient SQL projections. `external_id` column should be indexed for lookup performance. No caching strategy implemented.
- **Observability:** No custom logging (relies on base service). Consider adding external ID lookup metrics and audit logging.
- **Risks / tradeoffs:** Database table must exist before deployment (coordination required). Duplication of `UserEntity` structure means schema changes require parallel updates. Multiple external providers may require a provider discriminator column in future.

---

## 5. Rollout

- **Deploy strategy:** (1) DBA creates `external_users` table and indexes `external_id`. (2) Deploy code — no immediate impact. (3) Register service in DI and create endpoints when ready. (4) Configure external auth provider integration.
- **Backward compatible:** Yes. No changes to existing entities or services. Consumers opt-in by injecting `ExternalUserService`.
- **Rollback:** Remove DI registration and controllers, redeploy. Table can remain (no harm if unused) or be dropped.
- **Follow-ups:** Bulk lookup (`GetUsersByExternalIdsAsync`), unique constraint on `external_id`, ID format validation, caching, audit logging, `ExternalProviderId` column for multi-provider support, integration tests, API controller.

---

**Plan:** `docs/adc/plans/2026-02-27--external-user-entity-service.plan.md`

---
> **Created by:** claude-sonnet-4-6
> **Created:** 2026-02-27
> **Updated by:** claude-sonnet-4-6
> **Updated:** 2026-02-27
