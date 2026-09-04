# Specification: Apply the Braun design system across the application
Author: Patricio Mac Adden. Timestamp: 2026-09-04T16:23:49Z. Status: accepted.

## Applied skills and versions
- frontend-design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md` (externally managed, untracked skill).

## Summary
The browser-facing Rails application must consistently use the Braun system defined in `DESIGN.md`. Public post browsing, account and password flows, and authenticated post management are in scope. Existing behavior remains unchanged; approved presentation changes remove the redundant Posts link and My posts heading, hide optional bodies on post-list screens, and move an original-source domain link beside the post-detail title. Email and PWA pages are explicitly out of scope.

## Users and primary journeys
- Visitors browse the posts index, open a post, and follow pagination or original-source links.
- Unauthenticated users sign up, sign in, request a password-reset email, and set a replacement password.
- Authenticated users browse their posts, create or edit a post, and delete a post.
- On each journey, people can identify page hierarchy, complete the existing action, receive the existing status or error feedback, and navigate without losing the existing interaction or copy.

## Functional requirements
- **FR-1:** Apply the Braun presentation to every browser-facing page rendered by the application layout: public post index and detail; registration; sign-in; password-reset request and update; and authenticated post index, create, and edit. **Source:** Intent: Proposed outcome; affected users and systems.
- **FR-2:** Preserve all existing routes, authentication and authorization behavior, form fields and submitted parameters, validation/error behavior, flash behavior, pagination, and post actions. Approved presentation exceptions are removal of the redundant Posts link and My posts heading; hiding optional bodies on public and managed-post lists; and replacing the post-detail “Original URL” label with its domain link beside the title. **Source:** Product-owner decisions recorded in annotation feedback.
- **FR-3:** Leave mailer templates and PWA templates/assets outside this change. **Source:** Intent: Constraints.

## UX and design requirements
- **UX-1:** Use `DESIGN.md` tokens consistently: Primary `#0F1113`, Secondary `#6B6F74`, Tertiary `#D95600`, Neutral `#E7E5E1`, and Surface `#F3F1EC`; Inter for display, headings, and body; and JetBrains Mono for labels, captions, metadata, and navigation utilities. **Source:** `DESIGN.md`; Intent: Constraints.
- **UX-2:** Use the specified type scale, spacing (8px, 16px, and 32px), and 0–4px corner radii. Lay pages out on a disciplined, responsive industrial grid with neutral negative space and flat surfaces; do not introduce gradients or any alternate accent color. **Source:** `DESIGN.md`; frontend-design.
- **UX-3:** Give each screen exactly one visually tertiary-orange primary action. All other links, buttons, destructive actions, and navigation controls remain visually neutral in default, focus, and hover states while retaining their existing behavior and approved presentation. **Source:** Intent: Constraints; `DESIGN.md`; review finding 1.
- **UX-4:** Present hierarchy through content-relevant structural devices—such as labels, rules, metadata, and spacing—rather than decorative numbering or new marketing copy. The public post list is the product's content-oriented focal point; account and post-management pages prioritize the existing task form or list. **Source:** frontend-design; product-owner decision: preserve copy.
- **UX-5:** Keep layouts usable at narrow mobile widths; provide visible keyboard focus for interactive controls; preserve semantic form labels, alert/status roles, and pagination/navigation labels; and avoid nonessential motion. Any introduced motion must honor reduced-motion preferences. **Source:** frontend-design.

## Non-functional requirements
- **NFR-1:** Use shared layout and stylesheet treatment so the in-scope pages have a consistent visual system without duplicating page-specific style definitions unnecessarily. **Source:** Intent: Affected users and systems.
- **NFR-2:** The visual treatment must not prevent existing server-rendered pages from rendering when custom web fonts are unavailable; configured fallback font stacks remain usable. **Source:** frontend-design; `DESIGN.md` typography.

## Security, privacy, and compliance requirements
- **SPC-1:** Do not alter authentication, password-reset, authorization, CSRF, or form-submission behavior while applying the visual treatment. **Source:** Product-owner decision: preserve behavior; Intent: affected users and systems.
- **SPC-2:** Do not add collection, display, logging, or transmission of personal data beyond the data already rendered by the existing pages. **Source:** Scope is visual-only; Intent: Constraints.

## Constraints applied
- frontend-design: Use a deliberate, subject-grounded visual identity; maintain responsive layouts, visible keyboard focus, and reduced-motion support. The intent and `DESIGN.md` constrain the identity to Braun's industrial grid and single utility-orange accent.
- `DESIGN.md`: Use the named palette, typography, spacing, low-radius components, and flat single-accent system; exclude email and PWA pages.

## Assumptions and open questions
- No mockup branch will be used; the specification is based on `DESIGN.md` and the existing rendered-page structure. **Decision:** Product owner.
- No separate organization accessibility, security, privacy, legal, or compliance policy skill was available in the project context. This specification applies the available frontend-design baseline and preserves current behavior; any stricter organizational requirements remain to be supplied before planning.
- The existing application layout is the scope boundary for browser-facing pages; any future browser-rendered page added after this design is not automatically included in this change.

## Flagged concerns

### Accessibility policy availability
**Concern:** This change affects all interactive browser pages, but no dedicated accessibility policy skill was available to establish organization-specific requirements beyond the available frontend-design guidance.

**Owner:** UX

**Decision needed:** Confirm whether an organization accessibility standard must be applied before planning.

**Status:** Open

## Acceptance criteria
- **AC-1:** The public posts index and detail, registration, sign-in, password-reset request/update, and authenticated post list/create/edit screens render with the Braun palette, typography, spacing, and low-radius treatment. **Covers:** FR-1, UX-1, UX-2.
- **AC-2:** Each in-scope screen has one tertiary-orange primary action and no gradients or alternate accent colors; other interactive controls retain accessible neutral styling. **Covers:** UX-2, UX-3, UX-5.
- **AC-3:** The existing post, authentication, password-reset, navigation, pagination, status/error, and form flows behave identically and retain their existing copy. **Covers:** FR-2, SPC-1.
- **AC-4:** In-scope pages remain usable at narrow widths, expose visible keyboard focus, and preserve their existing semantic labels and alert/status announcements. **Covers:** UX-5, NFR-2.
- **AC-5:** Mailer and PWA templates/assets are unchanged, and no additional personal-data collection, display, logging, or transmission is introduced. **Covers:** FR-3, SPC-2.

## Planning readiness
Conditionally ready: the requested scope and product-owner copy/behavior decision are specified, but UX must resolve the flagged accessibility-policy question before engineering planning.
