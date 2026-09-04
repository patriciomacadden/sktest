# Specification: Post voting
Author: Patricio Mac Adden. Timestamp: 2026-09-04T20:47:46Z. Status: accepted.

## Applied skills and versions
- Design: SHA-256 `a6a2b23c00bf63d8569a48986cfcfcc4313a3b222eb1dbe1246c0224e4267441`; source: `.agents/skills/design/SKILL.md` (untracked, locally managed).
- Rails Best Practices Core: SHA-256 `bcf53cedde5f8dcc5adb06e7206f2fe371f57a021c38206e872738c163d57224`; source: `.agents/skills/rails-best-practices-core/SKILL.md` (untracked, locally managed).
- Frontend Design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md` (externally managed).
- Braun design system: Git commit `a35c48fcb815fdf9df8bdf8f7e5cfc7b4b214b2d`; source: `DESIGN.md`.

## Summary
Authenticated users need a way to vote for public web posts so the public post list can surface popular posts. A user can have one active vote per post and may remove and later recast that vote. The public list ranks posts by vote total, highest first, with vote totals visible on public list and show pages.

## Users and primary journeys
- **Authenticated voter:** On a public post list or show page, identifies the compact up-arrow control, casts a vote, sees its selected state and the updated total, and can activate it again to remove the vote.
- **Signed-out visitor:** Can see public posts and vote totals. Activating a vote control takes them to sign in rather than recording a vote; after signing in, they return to the originating post.
- **Public reader:** Uses the list ordered by vote total; ties are ordered newest first.

The reviewed design input is `vote-mockup.html`, revision 1, 2026-09-04, approved by product owner Patricio Mac Adden. It informs UX-1 through UX-4 and is an input only, not implementation authorization.

## Functional requirements
- **FR-1:** An authenticated user can create one active vote for a given post and can remove that active vote. After removal, the user can create an active vote for that post again. **Source:** Intent: Proposed outcome and Constraints.
- **FR-2:** The system must prevent more than one active vote for the same user and post, including under concurrent requests. **Source:** Intent: Constraints; Rails Best Practices Core.
- **FR-3:** Public post list pages must order posts by active vote total descending. Posts with equal totals must be ordered newest first. **Source:** Intent: Proposed outcome; product-owner decision, 2026-09-04.
- **FR-4:** Public post list and show pages must display each post's current active vote total. **Source:** Intent: Proposed outcome and Constraints.
- **FR-5:** A signed-out visitor who activates a post's vote control must be directed to sign in, no vote may be created, and after successful sign-in the visitor must return to the originating post. **Source:** Product-owner decisions, 2026-09-04.

## UX and design requirements
- **UX-1:** Each public list item and public show page must provide an up-arrow vote control adjacent to the post title. It uses the muted gray design-system color when not voted and utility orange when voted; the control has no background or border in either state. **Source:** Reviewed mockup revision 1; Braun design system.
- **UX-2:** The vote total must appear before the author and timestamp in the post metadata on list and show pages. **Source:** Product-owner feedback; reviewed mockup revision 1.
- **UX-3:** The control must expose its state and action to assistive technology (for example, an accessible name that distinguishes voting from removing a vote and includes the current total), must be keyboard operable, and must retain a visible keyboard focus indicator. Color alone must not convey vote state. **Source:** Reviewed mockup revision 1; Frontend Design.
- **UX-4:** The list control’s arrow must be optically aligned with its title without changing the separately tuned show-page alignment for its larger title. The show-page arrow must be visually centered against the show-page title line. **Source:** Product-owner annotation; reviewed mockup revision 1.

## Non-functional requirements
- **NFR-1:** Vote totals and ranking must be derived in database-backed queries; the application must not load all posts or votes into memory to calculate or sort the public list. **Source:** Rails Best Practices Core.
- **NFR-2:** The data model must support efficient retrieval of each post's active vote total for paginated public list and show-page rendering. **Source:** Rails Best Practices Core.
- **NFR-3:** Vote changes must be reflected consistently in the returned/rendered page state, including the control state and displayed total. **Source:** Intent: Proposed outcome.

## Security, privacy, and compliance requirements
- **SPC-1:** Only the authenticated current user may create or remove that user's vote; a request must not be able to create or remove a vote on behalf of another user. **Source:** Intent: Authenticated users; Rails Best Practices Core.
- **SPC-2:** The one-active-vote-per-user-per-post invariant must be enforced by a database constraint in addition to application behavior. **Source:** Rails Best Practices Core.
- **SPC-3:** No new personal data is required beyond the existing authenticated-user and post relationship needed to represent a vote. **Source:** Intent scope.

## Constraints applied
- **Rails Best Practices Core:** Model voting as a domain record, keep authorization at the controller/model boundary, and enforce the uniqueness invariant in the database; use database ordering and avoid new dependencies unless justified.
- **Frontend Design:** Preserve visible keyboard focus, reduced-motion support, plain action-oriented labels, and a disciplined interface rather than generic decoration.
- **Braun design system:** Use the established muted gray, utility-orange, industrial visual language; reserve orange for the selected interactive state and do not introduce a new accent or gradients.

## Assumptions and open questions
- The existing public post list pagination retains its current behavior after vote-based reordering. **Source:** Product-owner decision, 2026-09-04.
- Vote moderation, rate limiting, abuse reporting, and administrative vote management are outside this change; future intents may address them. **Source:** Product-owner decision, 2026-09-04.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** An authenticated user can vote an unvoted post, sees one active vote and the increased displayed total, removes that vote, and can vote the same post again. **Covers:** FR-1, FR-4, NFR-3.
- **AC-2:** Repeated or concurrent attempts to vote the same post as the same user leave exactly one active vote. **Covers:** FR-2, SPC-2.
- **AC-3:** The public post list is sorted by active vote total descending; posts with the same total are ordered newest first. **Covers:** FR-3.
- **AC-4:** Every public list item and show page displays the current vote total before author metadata. **Covers:** FR-4, UX-2.
- **AC-5:** A signed-out visitor cannot create a vote, is sent to sign in when activating the vote control, and returns to the originating post after successful sign-in. **Covers:** FR-5, SPC-1.
- **AC-6:** The public vote control uses a borderless up arrow, gray when inactive and orange when active; its accessible name communicates action and total, it is keyboard operable with visible focus, and it does not rely on color alone to communicate state. **Covers:** UX-1, UX-3.
- **AC-7:** The list and show-page arrow alignments match the approved mockup: the list arrow is tightly aligned with the list title, and the show-page arrow is centered against its larger title without changing the list alignment. **Covers:** UX-4.
- **AC-8:** Post-list vote totals and ordering are retrieved through database-backed queries without in-memory aggregation or sorting of all posts/votes. **Covers:** NFR-1, NFR-2.

## Planning readiness
Ready — functional scope, reviewed UI behavior, pagination behavior, and post-sign-in return behavior are defined. Vote moderation and related controls are explicitly deferred to future intents.
