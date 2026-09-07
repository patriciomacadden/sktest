# Specification: Nested post comments
Author: Patricio Mac Adden. Timestamp: 2026-09-06T03:28:30Z. Status: accepted.

## Applied skills and versions
- design: Git commit `de27abe4a39555ccf0e792a44d4a58cb2ad52915`; source: `/Users/patricio/Code/ai-native-sdlc-playbook/skills/design/SKILL.md` (loaded through `.agents/skills/design/SKILL.md`).
- rails-best-practices-core: Git commit `c58e7d51e322442cd33674e17d074d093ed24f83`; source: `/Users/patricio/Code/37signals-skills/skills/rails-best-practices-core/SKILL.md` (loaded through `.agents/skills/rails-best-practices-core/SKILL.md`).
- frontend-design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: externally managed `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.
- Repository brand guidance: `DESIGN.md`, Braun version alpha, supplying commit `a35c48fcb815fdf9df8bdf8f7e5cfc7b4b214b2d`.

## Summary
Add discussion to post detail pages: authenticated users can post comments, reply at unlimited depth, and edit or delete their own comments. Readers inherit the post's visibility. Deleted comments become non-replyable “[deleted]” placeholders while their existing replies remain intact.

Product-owner decisions in the design interview: specification only, public email attribution matching posts, non-empty plain text with no product-defined length limit, oldest-first ordering, and responsive visual indentation limits without limiting reply depth. Deleted text is retained indefinitely for potential future recovery while its post exists; deleting the post removes all its comments, including retained text. On surviving posts, comments by a deleted user show “[deleted user]” as attribution. New post/account deletion workflows are deferred; no recovery interface is in scope.

## Users and primary journeys
- A reader opens a post and reads its discussion in threaded order. A signed-out reader sees a sign-in link instead of writing controls.
- An authenticated reader writes a top-level comment or selects Reply on a live comment, enters text, and sees the result under its parent.
- A commenter edits their own live comment or confirms deletion. Deletion replaces its public content with “[deleted]” without removing descendants.

## Functional requirements
- **FR-1:** Anyone able to view a post can read its comments. Authenticated users can create comments on posts they can view. **Source:** intent, Proposed outcome and Constraints.
- **FR-2:** Replies belong to a live parent comment on the same post. Reply depth has no fixed limit; parent relationships cannot be changed through editing or form tampering, and cycles are invalid. **Source:** intent, Proposed outcome; rails-best-practices-core data invariants.
- **FR-3:** Only the author can edit or delete a comment. Editing changes text, not author, post, parent, or original creation order. Deleted comments cannot be edited or receive new direct replies; live descendants remain replyable. **Source:** intent, Constraints; design interpretation of preserved replies.
- **FR-4:** Deletion renders exactly “[deleted]” in place of the content, hides public attribution and writing controls for that comment, and preserves existing descendants. Retain the original text internally indefinitely for potential future recovery while the post exists; post deletion removes it under FR-7. No restore interface is included. **Source:** intent, Constraints; product-owner deletion and retention decisions.
- **FR-5:** Comments are plain text with preserved line breaks. Reject empty or whitespace-only submissions; impose no product-defined content or length restriction. HTML and Markdown syntax display literally. **Source:** product-owner content decision.
- **FR-6:** Order roots and each parent's replies oldest first, using a stable tie-breaker for equal creation times. Show each live comment's author email (or “[deleted user]” when the author has been deleted) and creation timestamp. **Source:** product-owner ordering, attribution, and lifecycle decisions.
- **FR-7:** Deleting a post removes all its comments and retained deleted-comment text, not just their public visibility. Deleting a user preserves their comments on surviving posts, replacing author attribution with “[deleted user]”; live comment content and replies remain intact. Comment deletion still displays “[deleted]” without attribution. Existing user deletion also deletes that user's posts, to which the post-deletion rule applies. No new post/account deletion interface or workflow is required in this release. **Source:** product-owner lifecycle feedback; existing User model behavior.

## UX and design requirements
- **UX-1:** Place the discussion below the existing post content without a visible Comments heading. Include a labeled top-level composer for authenticated readers. Empty state: “No comments yet.” Signed-out readers see “Sign in to comment.” Reply exposes a labeled composer identifying its parent; edit exposes the current text. Provide Post comment, Post reply, and Save changes. Show Cancel only for reply/edit composers, where it dismisses that contextual composer without making a change. **Source:** intent journeys; product-owner annotation decision; frontend-design clear interface copy.
- **UX-2:** Use indented threads and restrained neutral parent/child rules, not decorative cards at every depth. Cap visual indentation on narrow screens to keep text readable; do not cap logical depth. At the cap, identify the reply target with a parent link and accessible relationship text. At 320 CSS pixels, controls and text must remain usable without page-level horizontal scrolling. **Source:** intent indentation constraint; product-owner responsive-layout decision; frontend-design.
- **UX-3:** Preserve the Braun palette, Inter body/headings, JetBrains Mono metadata, spacing, and flat styling. Use utility orange for at most one action per screen, coordinating with existing post navigation/voting actions; repeated Reply/Edit/Delete controls remain neutral. No new accent colors or gradients. **Source:** DESIGN.md; frontend-design deference to established direction.
- **UX-4:** Use semantic thread structure, labeled inputs, keyboard-operable controls, visible focus, and programmatically associated error messages. Failed writes retain entered text and explain the failure; successful writes expose the resulting comment or placeholder and a clear status message in the existing global flash area. Cancellation makes no change. Confirm deletion and explain that replies remain and text is retained internally. **Source:** frontend-design; FR-4 retention decision; product-owner annotation decision.
- **UX-5:** Explain beside writing controls that the author's email address will be public to post readers. Do not present deletion as permanent erasure. **Source:** product-owner attribution and retention decisions.

## Non-functional requirements
- **NFR-1:** Thread loading must not issue a query per displayed comment or author, and traversal must not depend on an application call-stack depth proportional to thread depth. A reproducible deep-chain check must demonstrate operation beyond any visual indentation cap. Numeric load targets are deferred by the product owner for now; delivery strategy remains a planning decision without introducing new product restrictions. **Source:** unlimited-depth intent; rails-best-practices-core performance guidance.
- **NFR-2:** Writes preserve thread integrity under concurrent requests. If deletion completes before reply creation is committed, that reply must not be added to the deleted parent. A reply committed before deletion remains intact. Failed edits/deletes must not partially alter a thread. **Source:** intent deletion semantics; rails-best-practices-core data safety.
- **NFR-3:** Existing post reading, publishing, and voting continue to work. Automated verification must cover permissions, thread integrity, deletion races, content handling, and user-visible states alongside implementation. **Source:** rails-best-practices-core; existing repository behavior.

## Security, privacy, and compliance requirements
- **SPC-1:** Enforce authentication, post visibility, and author ownership server-side for every write, including crafted requests. Reject cross-post parents and attempts to set author identity. Post ownership alone grants no moderation power over other users' comments. **Source:** intent; rails-best-practices-core ownership boundaries.
- **SPC-2:** Render user content as escaped text; do not execute HTML or scripts. Preserve Rails CSRF protection and avoid form-page caching that yields stale CSRF tokens. No product content restrictions does not mean bypassing input/output safety. **Source:** rails-best-practices-core.
- **SPC-3:** Deleted content and author attribution must not appear in public HTML, hidden fields, accessibility text, or serialized responses. Retained text has no new public or administrator retrieval endpoint in this release. Do not add logging of comment bodies. **Source:** product-owner deletion decision; data-minimization design safeguard proposed for review.
- **SPC-4:** Email attribution and indefinite deleted-text retention are explicit product decisions, not a claim of privacy/legal compliance. Preserve the recorded product-owner risk acceptance below; it does not establish legal compliance or approval by a separate Privacy/Legal owner. **Source:** product-owner interview; design skill policy-review requirement.

## Constraints applied
- design: preserve the accepted intent, trace requirements to their sources, and require human acceptance before committing the specification or advancing to planning.
- rails-best-practices-core: Rails-native behavior, server-enforced ownership, hard data invariants, escaped output, bounded query growth, and regression verification; no implementation architecture is prescribed here.
- frontend-design: prioritize readable discussion, meaningful thread structure, plain action labels, responsive layout, and keyboard usability rather than redesigning the page.
- DESIGN.md (Braun alpha): reuse the existing visual system and single-action orange constraint.
- Intent scope: no moderation, reporting, dedicated anti-abuse features, or reply-depth limit. No notification, comment voting, rich-text editor, or recovery UI is requested.
- No dedicated organization security, privacy/legal, or accessibility policy skill was available. The baseline safeguards here do not establish compliance with an unavailable policy.

## Assumptions and open questions
- Confirmed through product-owner acceptance: a deleted placeholder hides its author and timestamp, remains even without replies, and cannot be restored through ordinary editing.
- Lifecycle decision confirmed: post deletion removes all associated comments, including retained text; user deletion replaces comment attribution with “[deleted user]” on surviving posts. Existing deletion paths must respect FR-7; broader post/account deletion workflows are deferred.
- Product owner accepts discussion-growth risk for now; numeric volume/depth/response-time targets are deferred. Planning may choose a loading strategy that preserves access to all depths and clear parent context, without silently adding product restrictions.

## Flagged concerns

### Public identity and indefinite retained text
**Concern:** Public email attribution exposes personal identifiers; indefinite storage keeps text users have deleted from public view. No organization privacy/legal policy was available to establish appropriate disclosure, retention, or erasure obligations.

**Owner:** Product owner and Privacy/Legal owner (role holder to be identified).

**Decision recorded:** Product owner reviewed this concern and confirmed “it’s fine”: proceed with public emails and indefinite retention for potential future recovery, retaining the specified disclosures. No separate Privacy/Legal review or legal-compliance determination is claimed. Subsequent product-owner feedback resolves lifecycle behavior in FR-7: post deletion removes all comments and retained text; deleted-user attribution becomes “[deleted user]” on surviving posts. Broader deletion workflows are deferred.

**Status:** Risk accepted by product owner; lifecycle decision recorded; separate policy review not evidenced.

### Unbounded input and discussion growth
**Concern:** Unlimited depth, no product-defined length limit, and no dedicated anti-abuse features can increase storage/rendering cost and abuse exposure. Responsive indentation solves width, not total discussion size.

**Owner:** Product owner and technical lead/security owner.

**Decision recorded:** Product owner reviewed this concern and confirmed “it’s fine for now”: accept the current operational risk and defer numeric load targets and additional anti-abuse features. Keep NFR-1/NFR-2 safeguards. Any proposed product limits must return to the product owner; no separate technical lead/security approval is claimed.

**Status:** Risk accepted by product owner for now; operational sizing deferred.

## Acceptance criteria
- **AC-1:** Signed-out readers can read comments on accessible posts, see a sign-in prompt, and cannot write via direct requests. Authenticated readers can add a root comment. **Covers:** FR-1, UX-1, SPC-1.
- **AC-2:** A reply appears beneath its same-post parent; crafted cross-post, cyclic, or reparenting requests fail without changing data. Live descendants of a deleted parent remain replyable. **Covers:** FR-2, FR-3, SPC-1.
- **AC-3:** Authors can edit/delete their live comments; other users, including the post author, cannot. Edits preserve attribution and ordering. **Covers:** FR-3, FR-6, SPC-1.
- **AC-4:** Confirmed deletion displays “[deleted]”, keeps descendants, removes public text/attribution and writing controls, and retains original text internally. Direct reply/edit requests against the placeholder fail. Cancelling deletion changes nothing. **Covers:** FR-4, UX-4, SPC-3.
- **AC-5:** Empty/whitespace-only text is rejected with the input retained and an associated error. Multiline text preserves breaks; script/HTML/Markdown inputs render as literal text without execution. No application-level maximum length validation is imposed. **Covers:** FR-5, UX-4, SPC-2.
- **AC-6:** Roots and siblings have stable oldest-first order. Live comments show email/timestamp (using “[deleted user]” instead of email after author deletion) and composers disclose email visibility. Deletion disclosure accurately describes internal retention. **Covers:** FR-6, UX-5, SPC-4.
- **AC-7:** A deep chain remains accessible beyond the visual cap; parent links identify the correct parent. At 320 CSS pixels, text and controls remain usable; posting, replying, editing, deletion, errors, and cancellation work with keyboard-only navigation. Braun tokens and the orange-action constraint are preserved. **Covers:** UX-1, UX-2, UX-3, UX-4, NFR-1.
- **AC-8:** Concurrent deletion/reply checks prove the commit-order behavior; query checks show no per-comment/author lookup growth, and deep traversal does not overflow the application stack. Existing post/vote checks still pass. **Covers:** NFR-1, NFR-2, NFR-3.
- **AC-9:** Crafted ownership/identity changes and missing/invalid CSRF tokens cannot mutate comments; public responses never leak deleted text through alternate fields or hidden markup. **Covers:** SPC-1, SPC-2, SPC-3.

- **AC-10:** Through existing deletion paths, deleting a post removes all its comments, descendants, and retained deleted text. Deleting a user preserves their comments on surviving posts with “[deleted user]” attribution and no former email in comment responses; live content remains replyable, while already-deleted comments remain “[deleted]”. Posts removed by existing user-deletion behavior leave no comments behind. **Covers:** FR-6, FR-7, SPC-3.

## Planning readiness
Ready — accepted by the product owner, including the proposed placeholder presentation. Post/account lifecycle behavior is decided in FR-7; broader deletion workflows are deferred. Product-owner acceptance of privacy and operational risks is recorded above; no independent policy-owner approval is claimed. Acceptance of this specification will not authorize implementation.
