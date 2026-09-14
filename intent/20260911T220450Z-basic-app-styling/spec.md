# Specification: basic app styling
Author: Patricio Mac Adden. Timestamp: 2026-09-14T15:43:01Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Prefer Rails and browser built-ins over added dependencies; keep the change explicit, maintainable, and covered by regression tests; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use an intentional, content-led visual system, direct user-controlled language, semantic native controls, visible keyboard focus, responsive layouts, and reduced visual clutter; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
The existing posts, comments, and authentication pages are browser-default presentations. Apply a cohesive, dependency-free visual treatment that makes the public post list easier to scan and gives every existing application screen consistent navigation, forms, typography, and interaction states, without changing product behavior or semantic HTML.

## Users and primary journeys
- A visitor scans the public post list, opens a post, reads its body and nested comment thread, and uses the existing sign-in or account-creation paths.
- A signed-in user creates, edits, or deletes a post from the existing controls; creates, replies to, edits, or deletes comments; and signs out from the global navigation.
- A person signs in, creates an account, requests a password reset, or sets a replacement password using the existing authentication flows.

## Functional requirements
- **FR-1:** Preserve all current routes, product behavior, authorization boundaries, form fields, validation messages, and existing post/comment/authentication actions. Styling must not introduce or remove product functionality. **Source:** Intent constraints.
- **FR-2:** Render a consistent global header on every existing application page. It identifies the application and presents the existing account actions appropriate to authentication state; authenticated navigation presents the existing Create post path and sign-out action. **Source:** Approved mockup revision 02.
- **FR-3:** Render the posts index as a compact, ordered list. Each entry shows its linked title followed by its URL in parentheses when a URL exists, then its existing comment count, author, date, and applicable owner actions; it does not show a post-body excerpt. **Source:** Approved mockup revision 02; product-owner annotation.
- **FR-4:** Render a post detail in this order: title followed by its URL in parentheses when present, author/date metadata, then the existing post body. Retain the existing comments, nested replies, comment actions, and forms. **Source:** Approved mockup revision 02; product-owner annotation.
- **FR-5:** Apply the shared visual system to post creation/editing, comment/reply/editing, sign-in, account creation, password-reset request, and password-update screens, including their existing empty, notice, and validation-error states. **Source:** Intent affected systems and open question; approved mockup revision 02.

## UX and design requirements
- **UX-1:** Implement the approved “civic noticeboard” direction: cool gray paper background, white form surfaces, dark-ink header, enamel-blue links and primary actions, and a single yellow header registration stripe. Use the approved mockup’s tokens: Paper `#eef2f5`, Surface `#ffffff`, Ink `#18212b`, Slate `#596775`, Enamel `#2452c5`, and Yellow `#f4c84b`. **Source:** Approved mockup revision 02.
- **UX-2:** Use system font stacks only. Use a compact sans-serif hierarchy for interface content and a restrained serif treatment for post bodies; do not add font or styling dependencies. **Source:** Intent constraints; approved mockup revision 02.
- **UX-3:** Keep the post index deliberately sparse: no hero, lead copy, card treatment, or page heading before the list. **Source:** Product-owner annotations; approved mockup revision 02.
- **UX-4:** Use horizontal rules and compact metadata to distinguish list entries. On a post detail, use left-hand rails to make nested comment depth legible without relying only on indentation. **Source:** Approved mockup revision 02.
- **UX-5:** Style native forms with visible labels, clear field boundaries, explicit primary actions, and field-associated existing error text. Keep validation guidance and notices readable without color alone. **Source:** Intent constraints; Frontend Design.
- **UX-6:** Preserve visible keyboard focus. Header navigation retains sufficient contrast in normal, hover, and focus states; its white links remain white on hover and use the yellow underline as feedback. **Source:** Product-owner annotation; Frontend Design.
- **UX-7:** Maintain usable layouts on narrow viewports: the content column, navigation, forms, post list, and nested comment thread adapt without horizontal scrolling. **Source:** Frontend Design.

## Non-functional requirements
- **NFR-1:** Use the existing Rails stylesheet asset pipeline and standard CSS; add no styling, font, component, or JavaScript dependency. **Source:** Intent constraints; Rails Best Practices Core.
- **NFR-2:** Keep selectors and stylesheet organization understandable for the existing server-rendered views; do not require a client-side rendering layer. **Source:** Rails Best Practices Core.
- **NFR-3:** Automated tests or targeted view/system regressions demonstrate that the existing controls, field labels, validation/error associations, and authentication/post/comment behavior remain available after the presentation change. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** This styling-only scope must not alter authentication, authorization, form submission, CSRF, content rendering, or data handling. **Source:** Intent constraints.
- **SPC-2:** No organization-specific security, privacy, legal, compliance, or accessibility policy skill is available in the repository; no claim of conformance with an unavailable policy is made. **Source:** Policy-skill inventory.

## Constraints applied
- Rails Best Practices Core: Retain conventional Rails server-rendered views and the existing asset pipeline; introduce no dependency or client-side abstraction for basic styling; preserve regression coverage.
- Frontend Design: Apply a purposeful content-led direction with system typography, direct controls, readable error states, responsive behavior, and keyboard focus.

## Assumptions and open questions
- The approved mockup is design input, not implementation authorization.
- Mockup approval: Patricio Mac Adden, 2026-09-14. Source: `intent/20260911T220450Z-basic-app-styling/mockups/revision-02/README.md`; individual screen files are in the same directory; index export: `posts-index.png`.
- The app’s existing header is the single global navigation location; no additional navigation destinations are requested.
- The existing application has no defined standalone accessibility policy skill. Accessibility requirements here are limited to semantic HTML preservation, native labels, non-color-only guidance, focus visibility, contrast, and responsive layout.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** Existing post, comment, authentication, password-reset, authorization, validation, and content-rendering behavior is unchanged, while all affected screens receive the shared visual treatment. **Covers:** FR-1, FR-5, SPC-1.
- **AC-2:** Every application page displays the global header with the correct existing account actions; an authenticated user can reach Create post and sign out from it. **Covers:** FR-2, UX-6.
- **AC-3:** The posts index is a heading-free compact list with no body excerpts, and each post shows `title (url)` when applicable plus existing comment, author, date, and owner-action information. **Covers:** FR-3, UX-3, UX-4.
- **AC-4:** A post detail shows `title (url)`, author/date, then body; the existing comment thread, nested replies, and comment forms remain available and nested depth is visually legible. **Covers:** FR-4, UX-4.
- **AC-5:** Forms across post, comment, and authentication flows retain visible labels, controls, notices, and field-associated errors; focus remains visible, narrow screens do not horizontally scroll, and meaning is not conveyed by color alone. **Covers:** FR-5, UX-5, UX-6, UX-7.
- **AC-6:** The implementation uses standard CSS in the existing asset pipeline, adds no dependencies, and has regression evidence for the retained behavior and controls. **Covers:** NFR-1, NFR-2, NFR-3.

## Planning readiness
Ready. The product owner approved this specification on 2026-09-14. It is the handoff to planning, not authorization to implement.
