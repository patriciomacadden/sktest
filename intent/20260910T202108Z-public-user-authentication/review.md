# Review

## Review basis
- Compared: `3893bb2` against `main` (the repository default branch); implementation assessed from `c6c0c33..3893bb2` after the accepted plan.
- Reviewed revision: `3893bb2` (`Add public user authentication`).
- Policy and context read: `REVIEW.md`, `AGENTS.md`, the accepted intent, specification, and plan; Rails Best Practices Core and Frontend Design skills named by the specification.
- Limitations: `.agents/` and `.playwright-cli/` are untracked and were not part of the reviewed commit. No production email-delivery configuration exists by design.

## Findings

### R1 — Bugs (Important) — Registration accepts non-email addresses
- Location: `app/models/user.rb:5-7`
- Why it matters: A direct request can create an account with an empty or malformed `email_address`; the HTML `required` and `type="email"` constraints do not protect the server. Such an account cannot receive a password-reset email, so it does not meet the intended email/password account flow.
- Evidence: The model only normalizes `email_address` and checks uniqueness. The database migration rejects `NULL` but permits empty and malformed strings, and `RegistrationsController#create` saves the model directly. The accepted specification requires registration with an email address (FR-1) and a working password-reset journey (FR-4).
- Suggested direction: Add server-side presence and email-format validation, retaining the database unique index; add request/model coverage for rejected blank and malformed addresses.
- Outcome: Fixed — `62e9b28`; `bin/rails test test/models/user_test.rb test/controllers/registrations_controller_test.rb` (7 runs, 27 assertions) and targeted RuboCop passed.

## Review passes
- Bugs: Findings above.
- Security: No findings.
- Compliance: Findings above; the invalid-address path conflicts with FR-1 and FR-4. Otherwise, the reviewed implementation follows the accepted plan's Rails-generator and semantic-HTML approach.

## Learning

### Proposed AGENTS.md update
None.

### Proposed REVIEW.md update
None.
