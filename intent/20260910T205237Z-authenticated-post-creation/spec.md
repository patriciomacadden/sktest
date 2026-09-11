# Specification: authenticated post creation
Author: Patricio Mac Adden. Timestamp: 2026-09-11T16:04:55Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Use conventional Rails CRUD and ownership associations, put authorization meaning in model predicates, use database constraints for hard invariants, and ship tests with behavior changes; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use clear, user-controlled language, semantic controls, visible keyboard focus, responsive layouts, and useful error and empty states; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
Authenticated people need to publish and manage their own posts in a shared feed. This release introduces posts with a required title, optional HTTP(S) URL, and plain-text body. The public post list replaces the existing homepage as the root page, lists every post newest first, and lets authenticated authors create, edit, and delete only posts they created.

## Users and primary journeys
- A visitor can read the public root post list, including posts authored by authenticated users, but is directed to sign in before attempting a protected post-management route.
- An authenticated person creates a post with a title and, optionally, a web URL and body; after success, they see it at the top of the root post list.
- An authenticated author revises their own post and sees the saved content in the feed.
- An authenticated author deletes their own post and sees it removed from the feed.
- An authenticated person who does not own a post cannot edit or delete it.

## Functional requirements
- **FR-1:** A post belongs to its creator, an authenticated user, and has `title: string` (required), `url: string` (optional), and `body: text` (optional). A post cannot exist without its creator or title. **Source:** Intent constraints; product-owner feedback; Rails Best Practices Core.
- **FR-2:** Authenticated users can create posts through a standard create form. Submission with a blank title or malformed supplied URL does not create a post and shows field-level guidance. **Source:** Intent proposed outcome; product-owner decision.
- **FR-3:** When supplied, a post URL must be an absolute `http` or `https` URL. **Source:** Product-owner decision.
- **FR-4:** The existing homepage is removed. The root page is the public post list, which lists posts from all creators in reverse creation order (newest first). **Source:** Intent proposed outcome; product-owner feedback.
- **FR-5:** Each post in the list shows its title, its URL when supplied, and an author-and-creation-time line. **Source:** Product-owner feedback.
- **FR-6:** The root post list displays a clear invitation to create the first post when no posts exist. **Source:** Product-owner decision; Frontend Design.
- **FR-7:** Each post exposes edit and delete controls only to its creator. An author can update or delete their own post through conventional RESTful routes. **Source:** Intent proposed outcome; Rails Best Practices Core.
- **FR-8:** Requests to create, edit, update, or delete a post require authentication. Requests targeting a post owned by another user are denied and do not alter that post. **Source:** Intent constraints; Rails Best Practices Core.

## UX and design requirements
- **UX-1:** Retain the application's existing plain Rails visual language; do not introduce custom visual styling in this release. **Source:** Product-owner decision.
- **UX-2:** The root post list, empty state, post form, post metadata, and author-only management controls use semantic headings, text, links, labels, inputs, textareas, and buttons. They remain usable by keyboard and expose visible focus. **Source:** Frontend Design.
- **UX-3:** Form controls use clear sentence-case labels and actions: “Create post”, “Save changes”, “Edit”, and “Delete”. Invalid title and URL input has actionable, field-associated error text. **Source:** Frontend Design.
- **UX-4:** The body is rendered as plain text, with line breaks preserved; it is never interpreted as HTML. A supplied URL is presented as a link. **Source:** Product-owner decision.

## Non-functional requirements
- **NFR-1:** Use Rails conventions and built-in facilities; do not add a third-party authorization, rich-text, or URL-validation dependency for this scope. **Source:** Rails Best Practices Core.
- **NFR-2:** Query and order the shared feed in the database rather than filtering or sorting post records in memory. **Source:** Rails Best Practices Core.
- **NFR-3:** Automated regression tests cover creation, validation failures, root-list ordering, item metadata, empty state, owner update and deletion, unauthenticated protection, and non-owner denial. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** Post mutation endpoints require the application's existing authenticated session boundary. **Source:** Intent constraints; existing authentication architecture.
- **SPC-2:** Ownership authorization is enforced server-side for every edit, update, and delete request; hiding controls alone is insufficient. **Source:** Intent constraints; Rails Best Practices Core.
- **SPC-3:** User-supplied titles and bodies are rendered safely as text. Only validated HTTP(S) URLs are emitted as outbound links. **Source:** Product-owner decision.

## Constraints applied
- Rails Best Practices Core: Model creator ownership with a conventional association and a model-level ownership predicate; use resourceful routes, controller authorization checks, database foreign-key/null constraints, and tests.
- Frontend Design: Use direct action labels, semantic HTML, responsive native controls, visible focus, and informative error and empty states. Custom styling is explicitly out of scope.

## Assumptions and open questions
- The root post list is public; only post creation and management require authentication.
- The specification intentionally does not impose title, URL, or body length limits because none were supplied.
- The list's author label uses the creator's email address because accounts currently have no separate display name. Deletion confirmation is not specified; planning must not add it without a product decision.
- No organization-specific security, privacy, legal, or compliance policy skill is available in this repository; no compliance claim is made beyond the requirements above.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** An authenticated user can create a post with a title alone or with optional valid HTTP(S) URL and plain-text body; on success it appears at the top of the root post list. **Covers:** FR-1, FR-2, FR-3, FR-4.
- **AC-2:** A blank title or malformed supplied URL prevents creation or update, retains submitted input, and identifies the field that needs correction. **Covers:** FR-2, FR-3, UX-3.
- **AC-3:** The root page is a public post list, not the prior homepage. It lists every creator’s posts newest first; each item shows its title, optional URL, and author-and-creation-time line; and an empty list invites people to create the first post. **Covers:** FR-4, FR-5, FR-6.
- **AC-4:** Only a post’s creator sees management controls and can successfully edit or delete it; a non-owner cannot alter it by direct request. **Covers:** FR-7, FR-8, SPC-2.
- **AC-5:** An unauthenticated request to a post mutation route is handled by the existing authentication boundary, while visitors can read the root post list; rendered post title/body content is not interpreted as HTML. **Covers:** FR-4, FR-8, UX-4, SPC-1, SPC-3.
- **AC-6:** The affected flows have automated regression coverage using conventional Rails tests, and no new dependency is introduced for authorization, rich text, or URL validation. **Covers:** NFR-1, NFR-2, NFR-3.

## Planning readiness
Ready. The root post list, public visibility, data shape, content validation, item presentation, and ownership boundaries are defined.
