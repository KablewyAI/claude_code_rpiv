# Business Rules

Non-obvious business logic and "this looks wrong but is correct because..." decisions. This file captures the WHY behind rules that would be lost if the person who made the decision left.

**When to add entries:** Whenever you encounter a business rule that isn't self-evident from the code. If a future developer (or AI) would look at the code and think "this seems wrong," it belongs here.

**Format:** Each entry explains what the rule IS, why it EXISTS, and what would break if you "fixed" it.

---

## [System/Feature Area]

### [Rule Name]
- **Rule**: [What the code does that isn't obvious]
- **Why**: [The business reason this exists]
- **What would break**: [What goes wrong if someone "fixes" this]

### [Rule Name with Past Incident]
- **Rule**: [What the code does]
- **Why**: [The business reason]
- **What would break**: [Consequence of changing it]
- **Past incident**: [Optional — describe a time this rule was violated and what happened]
- **Source**: [Optional — link to code, doc, or decision record]

## Example Entries (DELETE THESE — they show the format)

### Trial Period Starts After Onboarding, Not Signup
- **Rule**: New accounts get `status = 'pending_setup'`, not `'trial'`, at signup time.
- **Why**: Starting the trial clock at signup penalizes users who sign up on Friday and don't configure until Monday. The trial should start when they actually begin using the product.
- **What would break**: Changing the default to 'trial' burns trial days during setup, increasing churn.

### Legacy IDs Are Strings, Not Integers
- **Rule**: User IDs in the `legacy_users` table are VARCHAR, not INT, even though they look numeric.
- **Why**: The original system used alphanumeric IDs for enterprise customers. Migrating to INT would break all external integrations that pass these IDs as strings.
- **What would break**: Casting to INT silently drops leading zeros and breaks lookups for ~2% of accounts.
- **Past incident**: A 2024 "cleanup" PR changed the column type. Reverted within 2 hours after 200+ support tickets from enterprise customers.

---

*Last updated: YYYY-MM-DD*
*To add a rule: Include what it IS, why it EXISTS, and what would BREAK if changed.*
