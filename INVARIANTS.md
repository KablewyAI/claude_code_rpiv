# System Invariants

Things that must NEVER break, regardless of what feature is being built. These are not tests — they're human-readable contracts that every change must respect.

**When to check:** During `/validate_plan` and code review. If a change could violate any invariant, it's a blocking issue.

**When to add entries:** When you discover a constraint that (1) applies globally, not just to one feature, and (2) would cause data loss, security breach, or corruption if violated.

---

## Data Isolation

- [Add invariants about data boundaries — e.g., tenant isolation, user-scoped access, no cross-account data leaks]

## Authentication & Authorization

- [Add invariants about auth — e.g., unauthenticated requests never reach business logic, secrets never appear client-side]

## Data Integrity

- [Add invariants about data safety — e.g., writes are idempotent, migrations run on all existing data, schema constraints enforced]

## Error Handling

- [Add invariants about error behavior — e.g., dependency outages never masquerade as auth failures, error types are differentiated]

## Compliance

- [Add invariants about regulatory requirements — e.g., PII never logged, external packages pass compliance gate, sensitive files never committed]

## Deployment

- [Add invariants about deploy safety — e.g., main is always deployable, production deploys require human approval]

## Example Entries (DELETE THESE — they show the format)

### Data Isolation
- **A user must NEVER see another tenant's data.** Every database query, cache lookup, and storage path must be scoped to the authenticated tenant. There is no cross-tenant query path.

### Error Handling
- **A database outage must NEVER return 401.** Returning "auth failed" for a DB error causes users to retry credentials, hammering the database during recovery. DB errors must return 503.
- **Error responses must differentiate dependency failures from user errors.** 503 for service issues, 400 for bad input, 401 for auth failures. Never conflate them.

### Deployment
- **`main` is always deployable.** No broken tests, no partial features, no "will fix later" commits on main.
- **Production deploys require explicit human permission.** Automated deploys target staging only.

---

*Last updated: YYYY-MM-DD*
*To add an invariant: It must be GLOBAL (not feature-specific), CRITICAL (violation = data loss/security/corruption), and ACTIONABLE (a developer can check compliance).*
