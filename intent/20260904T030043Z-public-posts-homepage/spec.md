# Specification: Public posts as homepage
Author: Patricio Mac Adden. Timestamp: 2026-09-04T13:44:05Z. Status: accepted.

## Applied skills and versions
- Design: SHA-256 `a6a2b23c00bf63d8569a48986cfcfcc4313a3b222eb1dbe1246c0224e4267441`; source: `.agents/skills/design/SKILL.md`.
- Rails Best Practices Core: SHA-256 `bcf53cedde5f8dcc5adb06e7206f2fe371f57a021c38206e872738c163d57224`; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.
- Repository design standard (Braun), alpha: SHA-256 `d2639e5da901b05ba7daa21ab5a0771c980a3ee90629ca4ba20d11f42ddd06fa`; source: `DESIGN.md`.

## Summary
The current homepage is no longer useful to public visitors. The root URL will instead present the existing newest-first public-posts list, while `/posts` remains available with the same list. The old homepage content has no preservation requirement.

## Users and primary journeys
Public visitors arrive at the root URL, scan a compact newest-first list of public posts, and open a post or its original URL. They can continue to the next page when more posts are available. Unauthenticated visitors can sign in; authenticated visitors retain access to their existing post-management navigation.

A design mockup informed this specification: `public-posts-homepage-mockup.html`, revision 3, 2026-09-04; approved by product owner Patricio Mac Adden. It is a visual input only and does not authorize implementation.

## Functional requirements
- **FR-1:** A request to `/` must present the public posts index rather than the former homepage content. **Source:** Intent — Proposed outcome; product-owner design approval.
- **FR-2:** `/posts` must remain available and present the same public posts list as `/`. **Source:** Product-owner decision — Keep `/posts`.
- **FR-3:** Both public-list URLs must retain the existing list behavior: newest-first ordering, links to individual posts, author and creation-time metadata, conditional post body and original-URL content, and pagination. **Source:** Intent — Proposed outcome; existing public-posts-list behavior.
- **FR-4:** The public-list navigation must retain the existing signed-out sign-in path and authenticated post-management paths. **Source:** Existing public-posts-list behavior.
- **FR-5:** The root and `/posts` list must have one shared behavior and presentation source; this change must not create independently maintained copies of the list. **Source:** Rails Best Practices Core — Rails conventions and small interfaces.

## UX and design requirements
- **UX-1:** The public list must use the approved compact, Hacker News–inspired reading hierarchy: a restrained header and a dense ordered list whose post title is the primary scan target and whose source domain and metadata are secondary. Conditional post bodies must remain visible when present, and an original URL must appear as its source-domain link adjacent to the post title when present. **Source:** Approved mockup, revision 3; product-owner decision — retain existing fields.
- **UX-2:** The page must apply the Braun standard: `#E7E5E1` foundation, `#F3F1EC` surface, `#0F1113` core text, `#6B6F74` secondary text, and `#D95600` only for the single primary action; use Inter for content and JetBrains Mono for utility metadata. Do not introduce gradients, alternate accents, or rounded styling beyond the standard. **Source:** `DESIGN.md`.
- **UX-3:** Keyboard focus must be visible. At narrow mobile widths, the header and post list must remain readable and usable without horizontal scrolling. **Source:** Frontend Design — quality floor.
- **UX-4:** The posts list must have an accessible programmatic label after removal of the visible page title from the approved mockup. **Source:** Product-owner annotation; Frontend Design — accessibility.

## Non-functional requirements
- **NFR-1:** The root list must use the existing pagination mechanism and must not introduce client-side loading, a new dependency, or in-memory sorting/filtering. **Source:** Existing public-posts-list behavior; Rails Best Practices Core — Rails conventions and SQL-backed collection operations.
- **NFR-2:** Existing root-path authentication and post-management journeys must continue to function after the root route changes. **Source:** Intent — affected systems; existing authentication behavior.

## Security, privacy, and compliance requirements
- **SPC-1:** The root page must not expose post data or management controls beyond what the current public posts index exposes to the same visitor. **Source:** Intent — existing public posts list; Rails Best Practices Core — authorization boundaries.
- **SPC-2:** No new personal data collection, consent flow, retention behavior, third-party integration, or dependency is in scope. **Source:** Intent scope; Rails Best Practices Core — dependencies.

## Constraints applied
- Repository design standard (Braun): Apply its specified palette, typography, flat visual language, and single-orange-action rule.
- Frontend Design: Use the approved subject-specific compact-list direction; preserve visible focus and mobile usability.
- Rails Best Practices Core: Reuse conventional Rails routing and the existing public-list behavior rather than introduce a parallel abstraction or dependency.
- Security, privacy, legal, and compliance policy skills: No applicable organization policy skill was available in this session. This change must not expand the existing public data exposure.

## Assumptions and open questions
None identified.

## Flagged concerns

`None identified.`

## Acceptance criteria
- **AC-1:** A public visitor requesting `/` receives the public posts list rather than the former welcome or signed-in homepage. **Covers:** FR-1.
- **AC-2:** A public visitor can request both `/` and `/posts` and receives the same newest-first posts, post links, and pagination behavior. **Covers:** FR-2, FR-3, NFR-1.
- **AC-3:** Signed-out visitors see the existing sign-in navigation, while authenticated visitors retain their existing post-management navigation and can complete those journeys from the root path. **Covers:** FR-4, NFR-2, SPC-1.
- **AC-4:** The implemented public list matches the approved compact hierarchy, including visible conditional post bodies and title-adjacent source-domain links for original URLs, and applies the Braun palette, typography, flat styling, and single-orange-action rule; keyboard focus is visible and the page has no horizontal overflow at a narrow mobile viewport. **Covers:** UX-1, UX-2, UX-3.
- **AC-5:** Assistive technology can identify the public-posts list without relying on the removed visible page title. **Covers:** UX-4.
- **AC-6:** The root page exposes no data or controls beyond the existing public posts index and adds no new dependency or external data handling. **Covers:** SPC-1, SPC-2, NFR-1.

## Planning readiness
Ready. The product owner selected retention of the existing conditional fields.
