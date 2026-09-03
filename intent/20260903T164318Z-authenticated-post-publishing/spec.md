# Specification: Authenticated post publishing
Author: Patricio Mac Adden. Timestamp: 2026-09-03T18:14:20Z. Status: accepted.

## Applied skills and versions
- design: SHA-256 `a6a2b23c00bf63d8569a48986cfcfcc4313a3b222eb1dbe1246c0224e4267441`; source: `.agents/skills/design/SKILL.md` (untracked, locally managed).
- rails-best-practices-core: SHA-256 `bcf53cedde5f8dcc5adb06e7206f2fe371f57a021c38206e872738c163d57224`; source: `.agents/skills/rails-best-practices-core/SKILL.md` (untracked, locally managed).
- frontend-design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md` (externally managed).

## Summary
Authenticated users need to publish and manage their own posts. Every post is publicly readable: public visitors can browse a paginated list and read individual posts. A post requires a title and can include an original URL and/or body; the public presentation shows the author’s email address and its `created_at` timestamp as the publication time. Posts are not moderated or drafted.

## Users and primary journeys
- **Public visitor:** Browse the public post list, newest first, in pages of 20; open a post from its title; read its title, author email, publication time, optional body, and optional original-URL link.
- **Authenticated author:** Open a paginated list of only their posts; create a post; revise its fields; or delete it. A successful creation or update is visible on the public views immediately because drafts are out of scope.
- **Unauthenticated visitor attempting author actions:** Is directed through the existing sign-in flow before reaching the requested author action.

## Functional requirements
- **FR-1:** A post has a required title, an optional original URL, and an optional body. A post may have neither an original URL nor a body. **Source:** intent, Proposed outcome; product-owner feedback.
- **FR-2:** An authenticated user can create, list, edit, and delete only posts they authored. **Source:** intent, Proposed outcome; product-owner feedback.
- **FR-3:** The authenticated author list contains only the current user’s posts, ordered newest first, and uses standard page-based pagination with 20 posts per page. Each item presents the same post information as the public list, links its title to the public show page, and provides edit and delete actions. **Source:** intent, Proposed outcome; product-owner decision.
- **FR-4:** A public visitor can view a public list of all posts, ordered newest first and using standard page-based pagination with 20 posts per page, and can view each individual post without authentication. **Source:** intent, Proposed outcome; product-owner decision.
- **FR-5:** Each public list item presents a title that links to its show page, the author’s email address, the publication time, and any supplied body and original URL. Each public show page presents the same information. **Source:** product-owner decisions.
- **FR-6:** When an original URL is supplied, it is presented as a separately labelled outbound link, not as the post-title link. The form accepts an HTTP(S) URL or a bare domain such as `google.com`; a bare domain is normalized to an HTTPS URL before storage or linking. **Source:** product-owner decision.
- **FR-7:** No administration/moderation, drafts, comments, media, tags, or user-profile work is included. **Source:** intent, Constraints.

## UX and design requirements
- **UX-1:** The semantic mockups in `mockups/`, revision 2026-09-03, approved for design input by product owner Patricio Mac Adden, inform FR-1 through FR-6. Each file represents one page. They use plain semantic HTML and intentionally add no visual styles. **Source:** product-owner mockup decision.
- **UX-2:** Public list and show pages must use a clear page heading; each item’s title must be the link to that post; and an original URL, when present, must be a distinct link labelled “Original URL.” **Source:** product-owner decision; frontend-design.
- **UX-3:** Creation and editing forms must have programmatically associated labels, identify title as required, preserve entered values after validation errors, and present errors so keyboard and assistive-technology users can identify and correct them. **Source:** frontend-design.
- **UX-4:** Pagination controls must be in a navigation landmark with a descriptive accessible name, expose the current page programmatically, and do not present unavailable previous/next actions as operable controls. **Source:** frontend-design; product-owner pagination decision.
- **UX-5:** The authenticated author list mirrors the public list’s per-post presentation, with separately labelled edit and destructive delete actions added for each post. Delete must not be available for a post the current user does not own. **Source:** product-owner decision; intent, Proposed outcome; frontend-design.

## Non-functional requirements
- **NFR-1:** Pagination must be performed by the database query, not by loading all posts and slicing in memory. **Source:** rails-best-practices-core.
- **NFR-2:** The design must use Rails conventions and built-ins before introducing a dependency; pagination must not add a gem without a separately justified decision. **Source:** rails-best-practices-core.
- **NFR-3:** Automated tests must accompany the behavior, covering model validation, authorization boundaries, public access, pagination, and primary author journeys. **Source:** rails-best-practices-core.

## Security, privacy, and compliance requirements
- **SPC-1:** Public read access is limited to the list and show views. Creating, listing an author’s own posts, editing, and deleting require the existing authentication mechanism. **Source:** intent, Proposed outcome; existing authentication integration.
- **SPC-2:** Authorization must be enforced through ownership-scoped record lookup so an authenticated user cannot view, edit, or delete another user’s author-management record by changing an identifier. **Source:** rails-best-practices-core.
- **SPC-3:** Post input must be allowlisted to title, original URL, and body. Post content and the author email must be rendered as text unless safely escaped by the framework; no user-controlled content may be interpolated as trusted HTML. **Source:** rails-best-practices-core.
- **SPC-4:** The author’s existing email address is intentionally displayed on public list and show pages; the product owner has confirmed this public disclosure is permitted. **Source:** product-owner decision.
- **SPC-5:** An original URL must be validated and rendered so it cannot create an executable or otherwise unsafe outbound link. Only HTTP(S) URLs are permitted after normalization; a bare domain is normalized to HTTPS. **Source:** product-owner decision; security risk identified during design.

## Constraints applied
- **rails-best-practices-core:** Use conventional Rails CRUD and ownership scoping, database-backed hard invariants, SQL pagination, strong parameters, and tests; do not add a dependency without justification.
- **frontend-design:** Use direct, consistent action labels and plain semantic HTML; ensure keyboard access, labelled inputs, clear errors, and accessible pagination. The requested unstyled mockup is the deliberate design direction for this stage.
- **design:** Preserve the accepted intent, isolate unresolved privacy and URL-safety decisions, and require product-owner acceptance before planning.
- **Security, privacy, legal/compliance policy skills:** No applicable repository policy skill was available. Compliance with a specific organizational policy is not claimed.

## Assumptions and open questions
- The current `created_at` timestamp is the publication time because drafts and a separate publication state are out of scope. This is a confirmed product-owner decision.
- Both public and author lists are ordered newest first.
- A bare original-URL domain is normalized to HTTPS; malformed or non-HTTP(S) URLs are rejected with a validation error.
- No repository security, privacy, legal, brand, or accessibility policy skill was available beyond the applied general engineering and frontend-design skills. Confirm whether an organizational policy applies before release.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** An authenticated user can create a post with only a title, and can create or edit a post with a title plus either or both optional fields. **Covers:** FR-1, FR-2.
- **AC-2:** An authenticated user sees only their own author-management list, where each post has the same presentation as the public list, a title link to its public show page, and edit and delete actions; attempts to access another user’s author-management record are denied without exposing it. **Covers:** FR-2, FR-3, UX-5, SPC-1, SPC-2.
- **AC-3:** Public visitors can open the newest-first paginated public list and individual posts without signing in; both the public and author lists show at most 20 posts per page and provide accessible page navigation. **Covers:** FR-3, FR-4, UX-4, NFR-1.
- **AC-4:** A public list item’s title opens its show page; public list and show pages show the author email and publication time, and show only the optional body and separately labelled original-URL link when present. **Covers:** FR-5, FR-6, UX-2, SPC-4.
- **AC-5:** The create and edit forms provide associated labels, required-title indication, retained submitted values, and actionable validation errors; delete is clearly identified as destructive. **Covers:** UX-3, UX-5.
- **AC-6:** Tests demonstrate allowlisted input, safe rendering of user-controlled post fields, normalization of a bare domain to HTTPS, and rejection of malformed or non-HTTP(S) original URLs. **Covers:** NFR-3, SPC-3, SPC-5.
- **AC-7:** No routes, UI, or data model support is added for administration/moderation, drafts, comments, media, tags, or user profiles. **Covers:** FR-7.

## Planning readiness
Conditionally ready: the core CRUD, public views, fields, pagination, sort order, public email disclosure, URL policy, and publication-time semantics are specified. The lack of repository security, privacy, legal, brand, and accessibility policy skills should be resolved before release.
