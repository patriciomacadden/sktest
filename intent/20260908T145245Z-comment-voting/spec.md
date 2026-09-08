# Specification: comment voting
Author: Patricio Mac Adden. Timestamp: 2026-09-08T15:15:58Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: model a vote as a domain record, enforce the one-vote invariant in the database, use resource-oriented routes, scope removal through the current user, and include tests; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Rails Security + Multi-Tenancy: authorization must fail closed and record access must be scoped through ownership rather than an unscoped vote lookup; source: `.agents/skills/rails-security-multitenancy/SKILL.md`.
- Rails Migrations: make schema changes reversible and use database uniqueness indexes for invariants; source: `.agents/skills/rails-migrations/SKILL.md`.
- Rails Testing: cover domain invariants and full request authorization behavior using Minitest fixtures without duplicating behavior across layers; source: `.agents/skills/rails-testing/SKILL.md`.

## Summary
Readers need a lightweight way to signal support for individual comments. Signed-in users will be able to add or remove one upvote for each non-deleted comment, including comments they authored. All readers will see each comment's vote total, including zero. This change does not add downvotes, notifications, activity entries, or other engagement features.

## Users and primary journeys
- A signed-in reader viewing a live comment can add one upvote and receives confirmation that it was added; the displayed total reflects the change.
- A signed-in reader who has already voted can remove that vote and receives confirmation; the displayed total reflects the change.
- A signed-out reader can see every live comment's total and is directed to sign in when attempting to vote.
- Any reader viewing a deleted comment can see its retained total, but no voting control is available.

## Functional requirements
- **FR-1:** Every comment has a publicly readable, non-negative vote total that starts at zero. **Source:** intent Proposed outcome and Decisions.
- **FR-2:** An authenticated user can create one upvote for a live comment, including a comment they authored. **Source:** intent Constraints and Decisions.
- **FR-3:** An authenticated user who has upvoted a live comment can remove only their own upvote. **Source:** intent Proposed outcome.
- **FR-4:** A user can have at most one active upvote per comment. Concurrent or repeated create attempts must not produce duplicate votes or inflate the total. **Source:** intent Proposed outcome; Rails Best Practices Core; Rails Migrations.
- **FR-5:** Deleted comments retain their pre-existing vote total but do not accept new votes or vote removals. **Source:** product-owner design decision, 2026-09-08.
- **FR-6:** Creating or removing a comment upvote does not create a notification or activity entry. **Source:** intent Decisions.

## UX and design requirements
- **UX-1:** Render the vote control and total within each non-deleted comment's existing action/presentation area, following the established post-vote visual and accessibility pattern. **Source:** product-owner decision to use existing comment/post UI patterns, 2026-09-08.
- **UX-2:** For signed-in users, the control must communicate whether activation adds or removes their vote, expose its pressed state to assistive technology, and include the current total in its accessible name. **Source:** UX-1; intent Proposed outcome.
- **UX-3:** For signed-out users, render an accessible sign-in affordance in place of the mutating control while keeping the current total visible. **Source:** intent Constraints.
- **UX-4:** Display the count when it is zero and update the rendered total after a successful add or removal. **Source:** intent Decisions; FR-1 through FR-3.
- **UX-5:** A deleted comment displays its retained total but no voting affordance. **Source:** FR-5.

## Non-functional requirements
- **NFR-1:** The displayed total must remain consistent with persisted votes after successful add, duplicate-rejection, and removal operations. **Source:** FR-1; FR-4.
- **NFR-2:** The feature must use the application's existing Rails/Turbo navigation and feedback conventions; no new client-side framework or dependency is introduced. **Source:** Rails Best Practices Core; product-owner mockup decision.

## Security, privacy, and compliance requirements
- **SPC-1:** Only an authenticated current user may mutate comment votes; unauthenticated mutation attempts follow the application's sign-in behavior and create no vote. **Source:** intent Constraints; Rails Security + Multi-Tenancy.
- **SPC-2:** Vote removal must locate the vote through the current user's association and the target comment, so a user cannot remove another user's vote. **Source:** FR-3; Rails Security + Multi-Tenancy.
- **SPC-3:** The vote endpoint must identify the comment only within the requested post and reject invalid or mismatched records without mutation. **Source:** Rails Security + Multi-Tenancy.
- **SPC-4:** A vote records only the actor and comment needed to enforce the feature; it creates no notification or activity data. **Source:** FR-6.

## Constraints applied
- Rails Best Practices Core: preserve thin controllers, put vote invariants and associations in models, represent add/remove as CRUD on a nested singular resource, and rely on a database uniqueness constraint rather than validation alone.
- Rails Security + Multi-Tenancy: authorize every mutation from the authenticated user's ownership boundary and fail closed for unavailable or ineligible records.
- Rails Migrations: add a reversible schema change with indexes that protect the one-vote invariant and support comment vote lookup.
- Rails Testing: add focused model and request/integration coverage for counts, uniqueness, authenticated behavior, unauthorized removal, deleted-comment behavior, and signed-out behavior; use existing named fixtures where suitable.

## Assumptions and open questions
- Comments remain publicly readable under the same visibility rules as their posts; this feature does not change post or comment visibility.
- The existing post-vote interaction is the approved visual/accessibility reference. No separate mockup was requested.
- No rate limit is specified for comment votes. Existing application-level abuse controls, if any, remain unchanged.

## Flagged concerns

`None identified.`

## Acceptance criteria
- **AC-1:** A live comment with no votes renders a visible total of `0`; all readers can see it. **Covers:** FR-1, UX-4.
- **AC-2:** A signed-in user can upvote their own or another user's live comment once, and the persisted/displayed total increases by one. **Covers:** FR-2, FR-4, UX-1, UX-2, UX-4.
- **AC-3:** Repeating an upvote request for the same user and comment does not create a second vote or increase the total again. **Covers:** FR-4, NFR-1.
- **AC-4:** A signed-in user can remove their own live-comment vote, and the persisted/displayed total decreases by one. **Covers:** FR-3, UX-2, UX-4, NFR-1.
- **AC-5:** A user cannot remove another user's vote, and that attempt leaves the vote and total unchanged. **Covers:** FR-3, SPC-2.
- **AC-6:** A signed-out vote attempt is redirected to sign in and creates no vote; the rendered affordance communicates that sign-in is required. **Covers:** UX-3, SPC-1.
- **AC-7:** A deleted comment continues to display its existing total and offers no voting action; direct mutation attempts create or remove no vote. **Covers:** FR-5, UX-5, SPC-3.
- **AC-8:** Adding or removing a vote creates no notification or activity entry. **Covers:** FR-6, SPC-4.

## Planning readiness
Ready. The product owner has selected the vote behavior, access rules, self-voting rule, zero-count display, deleted-comment treatment, notification/activity scope, and visual reference.
