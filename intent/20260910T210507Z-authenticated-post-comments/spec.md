# Specification: authenticated post comments
Author: Patricio Mac Adden. Timestamp: 2026-09-11T19:54:40Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Use conventional Rails CRUD and ownership associations, model authorization as simple predicates, enforce hard data invariants in the database where feasible, and ship tests with behavior changes; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use direct, user-controlled language, semantic controls, visible keyboard focus, responsive native controls, and useful empty and error states; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
Authenticated users need to discuss public posts and respond directly within existing discussions. This release adds a public post-detail page containing a chronological, infinitely nestable comment thread. Signed-in users can add top-level comments and replies, and can soft-delete only comments they authored. A deleted comment remains in its place with its replies, its stored content is retained, its rendered body becomes `[deleted]`, and it cannot receive further replies.

## Users and primary journeys
- A visitor opens a post from the public root feed, reads the post and its nested public thread, including deleted-comment placeholders, and sees a sign-in path rather than comment-creation controls.
- A signed-in user follows a post title to its detail page, adds a required plain-text top-level comment, and sees it at the end of that post's thread.
- A signed-in user replies to an active comment; the reply appears indented beneath that parent. Users may continue replying at any nesting level.
- An author deletes their own active comment. The thread retains the comment's location and all replies, renders `[deleted]` in place of its body, and no longer offers or accepts replies to that comment.

## Functional requirements
- **FR-1:** A comment belongs to one post and one creator (an authenticated user). It stores a required plain-text body, an optional parent comment, and an optional `deleted_at` timestamp. A comment cannot exist without its post, creator, or body. **Source:** Intent constraints; product-owner decision; Rails Best Practices Core.
- **FR-2:** A comment may be top-level or reply to another comment on the same post. Reply nesting has no application-defined depth limit. **Source:** Intent constraints.
- **FR-3:** The public root feed links each post title to a dedicated public post-detail page and displays that post's comment count. The count includes every retained comment, including soft-deleted comments. **Source:** Product-owner decision.
- **FR-4:** The public post-detail page displays the post and its complete comment thread. Top-level comments and replies at each level are ordered oldest first; each reply appears within and visually indented beneath its parent. **Source:** Intent constraints; product-owner decision.
- **FR-5:** An authenticated user can create a top-level comment on a post or a reply to an active comment. A blank body does not create a comment and presents field-level guidance. **Source:** Intent proposed outcome; product-owner decision.
- **FR-6:** An authenticated user can delete only an active comment they created. Deletion records `deleted_at` without removing or changing the stored comment body, without deleting its replies, and without changing the comment count. Comment editing is not included in this release. **Source:** Intent constraints; product-owner decision.
- **FR-7:** A deleted comment renders `[deleted]` in place of its body while retaining its position and replies. No user can create a reply to a deleted comment. **Source:** Intent constraints; product-owner decision.
- **FR-8:** Deleting a post deletes all comments associated with that post. This does not change the soft-deletion behavior for an individually deleted comment. **Source:** Product-owner decision.
- **FR-9:** Visitors can read post-detail pages and comment threads but cannot create or delete comments. The application directs them to sign in before protected comment actions. **Source:** Product-owner decision; existing public post behavior.

## UX and design requirements
- **UX-1:** Preserve the established plain Rails presentation; do not introduce custom visual styling or a design mockup in this release. **Source:** Product-owner decision.
- **UX-2:** The post-detail page uses semantic headings and an accessible nested thread structure. Comment forms have an associated body label, and controls use direct sentence-case labels: “Add comment”, “Reply”, and “Delete”. Keyboard focus remains visible. **Source:** Frontend Design.
- **UX-3:** A reply control and form are available for every active comment to signed-in users. Deleted comments show `[deleted]`, do not expose a reply control or form, and retain readable author/time context and nested replies. **Source:** Intent constraints; product-owner decision.
- **UX-4:** Invalid comment input retains the submitted body and identifies the body field with actionable, field-associated error text. An empty thread clearly invites a signed-in user to add the first comment, or a visitor to sign in to participate. **Source:** Frontend Design.
- **UX-5:** Comment bodies are rendered as plain text with line breaks preserved and never interpreted as HTML. **Source:** Product-owner decision.

## Non-functional requirements
- **NFR-1:** Use Rails conventions and built-in facilities; do not add a third-party nested-comment, authorization, or rich-text dependency for this scope. **Source:** Rails Best Practices Core.
- **NFR-2:** Query thread order and feed comment counts in the database rather than filtering, sorting, or counting comment records in memory. **Source:** Rails Best Practices Core.
- **NFR-3:** Automated regression tests cover public reading, feed navigation and count, empty state, top-level and nested creation, validation failure, chronological ordering, unlimited-depth behavior, deletion presentation and data retention, reply prevention after deletion, unauthenticated protection, and non-owner denial. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** All comment creation and deletion endpoints require the existing authenticated session boundary. **Source:** Intent constraints; existing authentication architecture.
- **SPC-2:** Ownership authorization is enforced server-side for every deletion request. A user cannot delete another user's comment by manipulating a request. **Source:** Intent constraints; Rails Best Practices Core.
- **SPC-3:** The server rejects a reply whose specified parent is deleted or belongs to another post; hiding reply controls alone is insufficient. **Source:** Intent constraints; Rails Best Practices Core.
- **SPC-4:** User-supplied comment bodies render safely as text and are not interpreted as HTML. **Source:** Product-owner decision.

## Constraints applied
- Rails Best Practices Core: Use conventional resourceful routes, a creator ownership association and model-level authorization predicate, database foreign-key/null constraints for the comment relationship, server-side authorization, database-backed ordering/counting, and regression tests.
- Frontend Design: Use plain action labels, semantic nested content and native controls, visible focus, and clear empty/error states. The product owner explicitly retains the current plain Rails visual language and declined the optional mockup branch.

## Assumptions and open questions
- The post-detail page presents the existing post fields using the same plain-text and safe-link behavior specified for posts; this specification does not otherwise expand post management.
- The specification intentionally does not impose a comment body length limit because none was supplied.
- No organization-specific security, privacy, legal, or compliance policy skill is available in this repository; no compliance claim is made beyond the requirements above.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** A visitor can follow any root-feed post title to a public detail page, read the post and its complete nested thread, and see a count that includes soft-deleted comments. **Covers:** FR-3, FR-4, FR-9.
- **AC-2:** A signed-in user can add a required plain-text top-level comment or reply to any active comment, and replies render indented beneath their parent with siblings oldest first at every depth. **Covers:** FR-1, FR-2, FR-4, FR-5, UX-2, UX-5.
- **AC-3:** A blank comment body creates no record, retains submitted content, and identifies the body field with actionable guidance. **Covers:** FR-5, UX-4.
- **AC-4:** Only a comment's creator can delete it; deletion records `deleted_at`, leaves the stored body and replies intact, renders `[deleted]` in place of the body, retains author/time context and the feed count, and permits no new replies to it. **Covers:** FR-6, FR-7, UX-3, SPC-2, SPC-3.
- **AC-5:** Visitors can read threads but cannot create or delete comments, and direct unauthenticated or non-owner mutation requests do not change comment data. Deleting a post removes its comments. **Covers:** FR-8, FR-9, SPC-1, SPC-2.
- **AC-6:** The affected behavior has automated regression coverage, ordering/counting is database-backed, comment content is safely rendered as text, and no nested-comment, authorization, or rich-text dependency is introduced. **Covers:** NFR-1, NFR-2, NFR-3, SPC-4.

## Planning readiness
Ready. Comment content, post-detail navigation, public visibility, thread ordering, nesting, feed count semantics, and soft-deletion behavior are defined. Product-owner review and explicit acceptance are required before planning.
