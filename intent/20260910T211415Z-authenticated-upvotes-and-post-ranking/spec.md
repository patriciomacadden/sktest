# Specification: authenticated upvotes and post ranking
Author: Patricio Mac Adden. Timestamp: 2026-09-15T14:00:14Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Use conventional Rails resources and ownership associations, model authorization as simple predicates, enforce hard data invariants in the database, perform ranking in the database, and ship tests with behavior changes; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use direct user-controlled language, semantic native controls, visible keyboard focus, responsive behavior, and useful empty/error states; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
Authenticated users need to express approval of posts and comments, while readers need a feed that can surface posts with the most recent community support. This change adds a single toggleable upvote per user on each post and comment, displays totals and the signed-in user's current state, and makes `Hot` the default public root-feed order with a visible `New` link.

## Users and primary journeys
- A visitor opens the public root feed ordered by `Hot`, may select `New`, sees each post's total upvotes, and can follow a sign-in path to vote. On a post-detail page, the visitor sees the post and every comment's total but cannot mutate votes.
- A signed-in user toggles an upvote on a post from a feed or post-detail page and immediately sees the correct total and selected state.
- A signed-in user toggles an upvote on any comment in its post-detail thread and immediately sees the correct total and selected state.
- A reader selects `Hot` to see posts ranked by upvotes received in the preceding 24 hours, or `New` to see posts by most-recent creation time.

## Functional requirements
- **FR-1:** An upvote is an association between one authenticated user and exactly one voteable target: a post or a comment. A user may have no more than one upvote on a given post and no more than one upvote on a given comment. **Source:** Intent constraints; Rails Best Practices Core.
- **FR-2:** An authenticated user can add an upvote to, and remove their own upvote from, any post or comment. Adding an existing upvote or removing a non-existent upvote must not create duplicate state or alter another user's vote. **Source:** Intent proposed outcome; intent constraints.
- **FR-3:** Post listings, the post-detail page, and every rendered comment display that target's upvote total. For an authenticated user, each target also displays whether that user has upvoted it and provides the corresponding add or remove control. **Source:** Intent proposed outcome; product-owner decision.
- **FR-4:** Visitors can read every upvote total but cannot add or remove votes. Wherever an authenticated voting control would otherwise appear, provide a sign-in path. **Source:** Intent constraints; product-owner decision; existing public post and comment behavior.
- **FR-5:** The public root feed defaults to `Hot` and provides a visible `New` link that orders posts by creation time descending. `New` is a user-facing order name; the internal Post scope is named `newest` to avoid conflicting with Rails record construction. The active ordering is identifiable in the URL and visually distinguishable without relying on color alone. **Source:** Intent proposed outcome; product-owner feedback; Frontend Design.
- **FR-6:** `Hot` orders posts by the descending number of upvotes created during the 24 hours immediately before the ranking query. Posts tied on that count are ordered by post creation time descending. Posts with no qualifying recent upvotes remain in the result. **Source:** Intent constraints; product-owner decision.
- **FR-7:** Deleting a post, comment, or user removes its associated upvotes so no upvote can remain without its user and voteable target. **Source:** Rails Best Practices Core; existing destructive ownership behavior.

## UX and design requirements
- **UX-1:** Preserve the established plain Rails presentation; custom visual styling and a design mockup are out of scope. **Source:** Existing accepted post and comment specifications; product scope.
- **UX-2:** Each upvote control uses a semantic native control with a direct sentence-case action that describes its current available action (for example, “Upvote” or “Remove upvote”), exposes its selected state programmatically, and retains visible keyboard focus. A total is readable without relying on the selected-state styling. **Source:** Intent proposed outcome; Frontend Design.
- **UX-3:** `Hot` and `New` are clear, keyboard-operable links. The current order is conveyed in text or semantic state, not color alone. **Source:** Product-owner decision; Frontend Design.
- **UX-4:** The controls and totals work at existing responsive widths. A failed protected action directs the user to sign in and preserves the intended destination through the existing authentication flow. **Source:** Existing authentication behavior; Frontend Design.

### Design mockup
- **Export:** `intent/20260910T211415Z-authenticated-upvotes-and-post-ranking/upvote-ui-mockup.html` (interactive static mockup) and `intent/20260910T211415Z-authenticated-upvotes-and-post-ranking/upvote-ui-mockup.png` (1280px-wide review capture).
- **Revision:** 1, 2026-09-15.
- **Design:** A narrow tally rail holds a native upvote button and fixed count beside each post and comment. Yellow confirms the signed-in user's vote; explicit button text and `aria-pressed` communicate state independently of color. The existing blue, yellow, and sans-serif visual language is retained.
- **Approving product owner:** Patricio Mac Adden, 2026-09-15.
- **Informs:** FR-3, FR-4, FR-5, UX-1, UX-2, UX-3, and UX-4. This mockup is design input only, not implementation authorization.

## Non-functional requirements
- **NFR-1:** Use Rails conventions and built-in facilities; do not add a third-party voting, ranking, authorization, or client-side state dependency for this scope. **Source:** Rails Best Practices Core.
- **NFR-2:** The single-vote invariant is enforced by database constraints, including a uniqueness constraint covering user, voteable type, and voteable ID. **Source:** Intent constraints; Rails Best Practices Core.
- **NFR-3:** Totals, an authenticated user's vote state, and `Hot` ranking are derived with database-backed queries rather than per-target query loops, in-memory sorting, or in-memory counting. **Source:** Rails Best Practices Core.
- **NFR-4:** Automated regression tests cover post and comment toggling, totals and selected-state rendering, duplicate-vote prevention, unauthenticated protection, ownership-safe removal, both feed orders, the 24-hour boundary, deterministic hot ties, and removal of votes when associated records are destroyed. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** Every endpoint that adds or removes an upvote requires the existing authenticated session boundary. **Source:** Intent constraints; existing authentication architecture.
- **SPC-2:** The server scopes removal to the current user's upvote and validates the voteable target server-side; concealing controls alone is insufficient. A user cannot remove another user's vote by manipulating a request. **Source:** Intent constraints; Rails Best Practices Core.
- **SPC-3:** Upvote data exposes only aggregate totals and the current authenticated user's own selected state; it does not expose a list of voters in this scope. **Source:** Intent proposed outcome; scope boundary.

## Constraints applied
- Rails Best Practices Core: Model the vote as a domain record with explicit user and target ownership, conventional resourceful routes, model-level authorization predicate(s), database foreign-key/null/unique constraints, database-backed ranking, and regression tests.
- Frontend Design: Use direct action labels, semantic controls and navigation, programmatic selected state, visible focus, responsive native controls, and a useful sign-in path. The established plain Rails visual language is retained.

## Assumptions and open questions
- The rolling 24-hour window is evaluated from the time the feed ranking query is made; an upvote exactly at the cutoff is included.
- An upvote does not create notifications, reputation changes, voter lists, downvotes, or a comment-ranking feature.
- No organization-specific security, privacy, legal, or compliance policy skill is available in this repository; no compliance claim is made beyond the requirements above.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** A signed-in user can add and remove exactly one upvote on any post and comment from every specified presentation, sees the matching total and selected state, and cannot create duplicate votes. **Covers:** FR-1, FR-2, FR-3, UX-2, NFR-2.
- **AC-2:** A visitor sees post and comment totals plus a sign-in path but cannot mutate vote data. Direct unauthenticated mutation requests and attempts to remove another user's vote do not change data. **Covers:** FR-4, UX-4, SPC-1, SPC-2.
- **AC-3:** The root feed defaults to `Hot` and visibly links to `New`. The internal `newest` scope sorts newest first, while `Hot` sorts by qualifying upvotes in the preceding 24 hours, includes zero-vote posts, and breaks count ties by newest post first. **Covers:** FR-5, FR-6, UX-3.
- **AC-4:** Deleting a post, comment, or user leaves no associated upvotes, and the application reveals no voter list. **Covers:** FR-7, SPC-3.
- **AC-5:** The affected behavior has automated regression coverage, uses database-backed totals, state, and ranking, and introduces no voting, ranking, authorization, or client-side-state dependency. **Covers:** NFR-1, NFR-3, NFR-4.

## Planning readiness
Ready. The scope, default `Hot` feed, user-facing `New` link backed by the internal `newest` scope, voting interactions, ownership boundary, and ranking rules are defined. Product-owner review and explicit acceptance are required before planning.
