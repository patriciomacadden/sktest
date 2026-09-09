# Specification: Community posts, comments, and voting
Author: Patricio Mac Adden. Timestamp: 2026-09-09T14:25:38Z. Status: accepted.

## Applied policies
- rails-best-practices-core: Use Rails conventions and built-ins, model ownership and voting as domain records, enforce hard invariants in the database, and authorize through explicit model predicates; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- frontend-design: Give this public discussion product a deliberate, accessible visual identity rather than a generic default; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
Create a public discussion application where anyone can discover posts and their associated discussions. People can create an email/password account, reset their password, publish posts, comment at unlimited depth, and upvote posts and comments. Authors retain control of their own posts and comments.

## Users and primary journeys
- **Visitor:** Browse the public post list, open a post, follow its nested comment thread, and choose to register or sign in to participate.
- **Registered user:** Register with email and password, receive/use the password-reset flow when needed, publish a post, read any post, add a top-level comment or reply, and add or remove an upvote on a post or comment.
- **Content author:** Edit or delete their own posts and comments; they cannot edit or delete another user’s content.

## Functional requirements
- **FR-1:** The public post list displays each published post’s title and vote total, ordered by vote total from highest to lowest, and permits a visitor to open the post detail page. **Source:** intent Constraints; product-owner decision.
- **FR-2:** A post has a required title and optional URL and body. The post detail page displays its content and its comments publicly. **Source:** intent Constraints.
- **FR-3:** Visitors can register and sign in with email and password, sign out, and request and complete a password reset. **Source:** intent Constraints.
- **FR-4:** Only authenticated users can create posts. **Source:** intent Proposed outcome.
- **FR-5:** Authenticated users can create comments on every post and reply to any non-deleted comment. A reply belongs to its immediate parent comment; nesting is not artificially depth-limited. **Source:** intent Constraints; product-owner decision.
- **FR-6:** Authenticated users can add or remove one upvote on each post and on each comment. The displayed vote total reflects the current votes; duplicate votes by the same user on the same target are prevented. **Source:** intent Constraints; rails-best-practices-core.
- **FR-7:** A user can edit and delete only posts and comments they authored. Deleting a post hard-deletes the post and all of its comments and votes. Deleting a comment retains it as a non-replyable placeholder whose body is `[deleted]`, while retaining its existing replies. **Source:** intent Constraints; product-owner decision.
- **FR-8:** Posts, comments, and votes associate with their creator so authorization and vote uniqueness are enforced at the ownership boundary. **Source:** rails-best-practices-core.

## UX and design requirements
- **UX-1:** The public list, post detail, and comment thread are usable without signing in; actions requiring authentication clearly lead to registration or sign-in rather than silently failing. **Source:** intent Constraints.
- **UX-2:** Post detail presents the title with its optional URL, then a metadata line containing the vote total/control, post author email, and creation timestamp, followed by its optional body and discussion. The optional URL opens in the same tab. Posts are published immediately when created; there is no separate publication date. **Source:** intent Constraints; product-owner decision.
- **UX-3:** Replies render within their parent comment and with a visible indentation relationship. The hierarchy remains understandable on narrow viewports and at deep nesting levels. **Source:** intent Constraints.
- **UX-4:** Create and edit forms expose required versus optional post fields, retain entered values after validation errors, and present actionable errors. **Source:** intent Constraints.
- **UX-5:** Controls state their action plainly and consistently (for example, “Upvote”, “Remove upvote”, “Reply”, “Save changes”, and “Delete”). Keyboard focus is visible and motion, if any, respects reduced-motion preferences. **Source:** frontend-design.
- **UX-6:** The visual design uses a simple, dense discussion-board direction informed by Hacker News but is not a visual clone: a warm paper surface, a distinct Threadwell wordmark, a narrow centered reading surface, an orange top rule and join control, text-first metadata, and indentation as the primary comment-hierarchy signal. The draft detail and list mockups inform UX-1 through UX-6 and remain subject to product-owner review. **Source:** frontend-design; product-owner decision.

## Design mockup
- **Artifacts:** `intent/20260909T141931Z-community-posts-comments-voting/mockup.html` (post detail) and `intent/20260909T141931Z-community-posts-comments-voting/mockup-list.html` (post list).
- **Revision/date:** Draft 3, 2026-09-09 (simplified Hacker News-informed direction with a distinct visual treatment and post-list mockup).
- **Approving product owner:** Patricio Mac Adden (approved 2026-09-09).
- **Informs:** UX-1, UX-2, UX-3, UX-5, UX-6.

## Non-functional requirements
- **NFR-1:** Ownership and one-vote-per-user-per-target are database-enforced invariants, with user-facing validation where helpful. **Source:** rails-best-practices-core.
- **NFR-2:** Public reading pages and authenticated write flows use Rails’ conventional HTML application patterns unless a reviewed design requires otherwise; no new dependency is assumed. **Source:** rails-best-practices-core.
- **NFR-3:** Behavior is covered by automated tests in the same implementation change, including authorization and voting invariants. **Source:** rails-best-practices-core.

## Security, privacy, and compliance requirements
- **SPC-1:** Only authenticated users may perform post, comment, or vote writes. Authorization checks must prevent editing or deleting another author’s posts or comments. **Source:** intent Constraints; rails-best-practices-core.
- **SPC-2:** Password credentials and reset tokens must use Rails-supported secure authentication/reset mechanisms; plaintext passwords and reset tokens must not be stored or exposed. **Source:** intent Constraints; product owner confirmed no additional organization-specific security, privacy, legal, or accessibility requirements apply.
- **SPC-3:** Public content, including the post author’s email address, is intentionally readable without authentication. No moderation, reporting workflow, content screening, email verification, rate limiting, spam prevention, display name, or account-recovery flow other than password reset is included in this scope. **Source:** intent Constraints; product-owner decision.

## Constraints applied
- **rails-best-practices-core:** Prefer Rails conventions over new dependencies; use domain records and database constraints for votes and ownership-scoped model predicates for authorization.
- **frontend-design:** Establish a specific visual direction before implementation; ensure responsive, keyboard-accessible interaction and reduced-motion support.

## Assumptions and open questions
None identified.

## Flagged concerns

`None identified.`

## Acceptance criteria
- **AC-1:** An unauthenticated visitor can view posts ordered from most to fewest votes, open a post with an optional URL in the same tab and/or body, see its author email and creation timestamp, and read its nested comments without being prompted to sign in. **Covers:** FR-1, FR-2, UX-1, UX-2, UX-3, SPC-3.
- **AC-2:** A visitor can register, sign in, sign out, and complete a password-reset flow using email and password credentials. **Covers:** FR-3, SPC-2.
- **AC-3:** A signed-in user can create a post and comment or reply to every non-deleted comment in a post’s discussion, including a reply below existing nested comments. **Covers:** FR-4, FR-5, UX-4.
- **AC-4:** A signed-in user can add one upvote to a post or comment, sees its displayed total change, can remove that upvote, and cannot create a second simultaneous upvote for the same target. **Covers:** FR-6, NFR-1.
- **AC-5:** A content author can edit and delete their own post or comment, while a different signed-in user cannot edit or delete it. Deleting a post removes it and all of its comments and votes; deleting a comment renders `[deleted]`, preserves its replies, and prevents new replies to it. **Covers:** FR-7, FR-8, SPC-1.
- **AC-6:** Public reading and authenticated interaction are usable by keyboard and on narrow viewports, with visible focus and reduced-motion support. **Covers:** UX-3, UX-5, UX-6.
- **AC-7:** Automated tests exercise authorization and the one-vote-per-user-per-target invariant. **Covers:** NFR-1, NFR-3, SPC-1.

## Planning readiness
Ready for product-owner acceptance: the core scope, deletion semantics, URL behavior, applied constraints, and approved mockups are specified.
