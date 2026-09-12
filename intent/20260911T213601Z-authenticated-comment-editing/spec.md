# Specification: authenticated comment editing
Author: Patricio Mac Adden. Timestamp: 2026-09-12T02:45:37Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Use conventional Rails CRUD, model authorization as simple predicates, scope records through their ownership boundary, use built-in Rails facilities, and ship tests with behavior changes; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use clear user-controlled language, semantic native controls, visible keyboard focus, and direct actionable error states; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.
- Rails Hotwire + Realtime: Prefer server-rendered Rails interactions and do not add custom ActionCable or realtime broadcasts for this CRUD change; preserve an in-progress editor if a Turbo-driven update can affect it; source: `/Users/patricio/Code/37signals-skills/skills/rails-hotwire-realtime/SKILL.md`.

## Summary
Comment authors need to correct or improve an active comment after posting it. This change lets an authenticated author update only their own active comment body in the existing public post-detail thread. The changed body replaces the prior body; no revision history is retained. Readers can tell that an active comment has been edited.

## Users and primary journeys
- A visitor reads a public post-detail thread and can distinguish an edited active comment from an unedited one, but cannot edit comments.
- An authenticated comment author opens an inline editor for their active comment, updates its plain-text body, saves it, and sees the replacement body and edited indicator in the existing thread.
- An authenticated user who is not the author cannot access or submit an update for someone else’s comment.
- An author cannot edit a deleted comment; it remains rendered as `[deleted]` without editing controls.

## Functional requirements
- **FR-1:** An active comment’s author can update that comment’s required plain-text body. A successful update replaces the stored body; the feature does not retain or expose prior body revisions. **Source:** Intent proposed outcome; intent constraints.
- **FR-2:** A comment may be edited only while active. A soft-deleted comment cannot expose an edit control or accept an edit request. **Source:** Intent constraints.
- **FR-3:** A comment’s creator, post, parent relationship, creation time, deletion state, and position in the thread remain unchanged by an edit. **Source:** Intent constraint; existing comment-thread behavior.
- **FR-4:** The post-detail thread appends `(edited)` immediately after the comment’s displayed creation date for an edited active comment. It does not display the indicator for an unedited or deleted comment, and does not display an edit timestamp. **Source:** Intent proposed outcome; product-owner feedback.
- **FR-5:** A blank edited body does not update the comment and presents field-level guidance while retaining the submitted body. **Source:** Existing comment validation; Frontend Design.
- **FR-6:** Visitors retain public read access to threads but are directed to sign in before protected editing actions. **Source:** Existing public comment behavior.

## UX and design requirements
- **UX-1:** Preserve the established plain Rails presentation; custom visual styling and a design mockup are out of scope. **Source:** Existing accepted comment specification; product scope.
- **UX-2:** Only an active comment’s author sees an “Edit” control. Activating it replaces that comment’s rendered body with an inline labeled comment-body textarea, an explicit save action, and a way to leave editing without changing the comment. **Source:** Intent constraints; product-owner feedback; Frontend Design.
- **UX-3:** An edited active comment appends the visible text `(edited)` immediately after its displayed creation date. The indicator is understandable without relying on color and does not obscure the author or original creation-time context. **Source:** Intent proposed outcome; product-owner feedback; Frontend Design.
- **UX-4:** Invalid input retains the submitted body and identifies the body field with actionable, field-associated error text. Controls remain keyboard operable with visible focus. A Turbo-driven navigation or update must not discard an in-progress editor. **Source:** Frontend Design; Rails Hotwire + Realtime; existing comment validation behavior.
- **UX-5:** Edited bodies remain rendered as plain text with line breaks preserved and are never interpreted as HTML. **Source:** Existing comment specification.

## Non-functional requirements
- **NFR-1:** Use conventional Rails resourceful routing and built-in facilities; do not introduce a third-party authorization, revision-history, rich-text, or form dependency for this scope. **Source:** Rails Best Practices Core.
- **NFR-2:** Automated regression tests cover owner editing, validation failure, edited-indicator rendering, unauthenticated protection, non-owner denial, and deleted-comment edit prevention. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** Every editing endpoint requires the existing authenticated session boundary. **Source:** Intent constraints; existing authentication architecture.
- **SPC-2:** Ownership and active-state authorization are enforced server-side for every edit request; hiding the control alone is insufficient. A user cannot alter another user’s comment or a deleted comment by manipulating a request. **Source:** Intent constraints; Rails Best Practices Core.
- **SPC-3:** Edited comment content is safely rendered as text and never interpreted as HTML. **Source:** Existing comment specification.

## Constraints applied
- Rails Best Practices Core: Use a conventional update resource, scoped comment lookup through its post, model-level predicate(s) for ownership and active-state authorization, server-side checks, and regression tests.
- Frontend Design: Use direct sentence-case controls, semantic labeled native inputs, visible focus, an explicit escape from editing, and field-associated validation guidance. The established plain Rails visual language is retained.
- Rails Hotwire + Realtime: This CRUD scope does not require realtime broadcasts, custom ActionCable channels, or client-side state. Use the existing server-rendered Rails/Turbo interaction path, and preserve editor input if a Turbo update could replace it.

## Assumptions and open questions
- No comment-body length limit is specified.
- No organization-specific security, privacy, legal, or compliance policy skill is available in this repository; no compliance claim is made beyond these requirements.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** An authenticated comment author can replace the required plain-text body of their active comment; the comment stays in the same thread location with the same creator, parent, creation time, and deletion state, and no prior revision is available. **Covers:** FR-1, FR-3, UX-5.
- **AC-2:** A successfully edited active comment appends `(edited)` immediately after its displayed creation date, without an edit timestamp; unedited and deleted comments do not display the indicator. **Covers:** FR-4, UX-3.
- **AC-3:** A blank edited body makes no change, retains submitted input, and identifies the body field with actionable guidance. **Covers:** FR-5, UX-4.
- **AC-4:** Only the active comment’s author sees and can use editing. Unauthenticated, non-owner, and deleted-comment update attempts do not change comment data; visitors may still read the thread. **Covers:** FR-2, FR-6, SPC-1, SPC-2.
- **AC-5:** The affected behavior has automated regression coverage, preserves in-progress editor input across any applicable Turbo update, and introduces no authorization, revision-history, rich-text, form, realtime-broadcast, or custom ActionCable dependency. **Covers:** NFR-1, NFR-2, UX-4, SPC-3.

## Planning readiness
Ready. The scope, inline editing interaction, ownership boundary, active-state rule, replacement semantics, and `(edited)` indicator placement are defined. Product-owner review and explicit acceptance are required before planning.
