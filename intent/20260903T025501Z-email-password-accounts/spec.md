# Specification: Email-password accounts
Author: Patricio Mac Adden. Timestamp: 2026-09-03T03:08:06Z. Status: accepted.

## Applied skills and versions
- design: SHA-256 `a6a2b23c00bf63d8569a48986cfcfcc4313a3b222eb1dbe1246c0224e4267441`; source: `.agents/skills/design/SKILL.md` (untracked, locally managed).
- frontend-design: SHA-256 `1608ea77fbb6fc30d13a97d12cfa8ebf31358d40f0dd97beed24829d6b3f45dd`; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md` (externally managed).

## Summary
The application currently has no accounts or authentication. This first release will let people create an account with an email address, password, and password confirmation; sign in with an email address and password; recover a forgotten password; and sign out. The homepage will expose the account state: signed-in people see their email address and a sign-out action; signed-out people see sign-up and sign-in actions. Roles, administration, external identity providers, email verification, and visual branding are outside this release.

## Users and primary journeys
- A new application user creates an account with an email address, password, and matching password confirmation, then can access the signed-in homepage.
- A returning user signs in with their email address and password, sees `Signed in as <email address>` on the homepage, and can sign out.
- A user who has forgotten their password requests reset instructions for their email address, completes the reset journey, then signs in using the replacement password.
- A signed-out visitor uses the homepage sign-up or sign-in action to enter the corresponding account flow.

## Functional requirements
- **FR-1:** A visitor can create an individual account using an email address, password, and matching password confirmation. **Source:** Intent, Proposed outcome; product-owner feedback.
- **FR-2:** A registered user can sign in with their email address and password. **Source:** Intent, Proposed outcome.
- **FR-3:** A signed-in user can sign out. **Source:** Intent, Proposed outcome.
- **FR-4:** A user can request password-reset instructions for their account email address and set a replacement password through the reset journey. **Source:** Product-owner decision, Account flows.
- **FR-5:** The homepage shows sign-up and sign-in actions to a signed-out visitor. **Source:** Intent, Proposed outcome.
- **FR-6:** The homepage shows `Signed in as <email address>` and a sign-out action to a signed-in user, using that user’s account email address. **Source:** Intent, Proposed outcome; product-owner decision, Signed-in message.
- **FR-7:** Email verification, roles, administration, and external identity providers are not included in this release. **Source:** Intent, Constraints; product-owner decision, Account flows.

## UX and design requirements
- **UX-1:** The account flows and homepage state conform to WCAG 2.2 Level AA, including semantic HTML controls with visible labels, keyboard operation, and a visible focus indication. **Source:** frontend-design skill, Restraint and self-critique; product-owner decision, Accessibility target.
- **UX-2:** Each account action uses clear, consistent, active-voice labels, including “Sign up,” “Sign in,” “Sign out,” and “Reset password.” **Source:** frontend-design skill, More on writing in design.
- **UX-3:** Validation and failure states explain the problem and the corrective action without revealing whether an email address belongs to an account where that disclosure would create account-enumeration risk. **Source:** frontend-design skill, More on writing in design; security design decision.
- **UX-4:** This release uses HTML-only presentation and introduces no visual direction, custom branding, or mockup. A future visual direction may revise the presentation without changing the account flows. **Source:** Product-owner decision, Visual direction and Mockup.

## Non-functional requirements
- **NFR-1:** Account state must persist across requests until sign-out or session expiration, so the homepage reliably reflects the current user’s state. **Source:** Intent, Proposed outcome; design inference required to support FR-6.
- **NFR-2:** Authentication and password-reset failures must be handled as user-facing states rather than unhandled application errors. **Source:** frontend-design skill, More on writing in design.
- **NFR-3:** The implementation must have automated coverage for the three primary journeys and both homepage account states. **Source:** Design-stage testability requirement.

## Security, privacy, and compliance requirements
- **SPC-1:** Password handling must use the defaults produced by the Rails 8.1.3.1 `authentication` generator, including digest-based password storage; passwords must not be stored or displayed in plaintext. **Source:** Product-owner feedback; Rails authentication generator defaults.
- **SPC-2:** Password-reset handling, including reset-token expiration and invalidation behavior, must use the defaults produced by the Rails 8.1.3.1 `authentication` generator. **Source:** Product-owner feedback; Rails authentication generator defaults.
- **SPC-3:** Sign-in, sign-up, and password-reset responses must not disclose whether a given email address has an account except after successful authentication. **Source:** Security baseline.
- **SPC-4:** Account email addresses are personal data and must only be used for authentication, homepage identification, and password-reset communication in this release. **Source:** Intent scope; privacy-minimization design decision; no organization privacy policy skill was available.
- **SPC-5:** A signed-out user must not be able to access content designated for a signed-in user. **Source:** Intent, Problem and Proposed outcome.

## Constraints applied
- design: The specification remains outcome-focused, testable, and draft pending product-owner review; no implementation plan or code is authorized.
- frontend-design: The product owner’s HTML-only direction takes precedence over a distinctive visual treatment. The retained requirements are WCAG 2.2 Level AA semantic, keyboard-accessible controls, visible focus, and plain, actionable content.
- Security and privacy policy skills: No organization-specific skill was available. Rails 8.1.3.1 `authentication` generator defaults are the approved baseline for password, reset-token, session, and request-rate-limit behavior; the deferred production email configuration remains flagged.

## Assumptions and open questions
- Production email delivery will be configured later. Its provider and configuration are outside the scope of this change.
- Password requirements, reset-token behavior, session behavior, and protections against repeated sign-in or reset attempts use the Rails 8.1.3.1 `authentication` generator defaults.
- Account deletion, email-address changes, and account/profile management are outside the stated scope and should be considered separately.

## Flagged concerns

None identified.

## Acceptance criteria
- **AC-1:** A new visitor can submit a valid email address, password, and matching password confirmation to create an account, then reaches a signed-in homepage. **Covers:** FR-1, FR-6.
- **AC-2:** A registered user can sign in with the correct email address and password and reaches a homepage showing exactly `Signed in as <their email address>` and a sign-out action. **Covers:** FR-2, FR-6.
- **AC-3:** A signed-out homepage exposes sign-up and sign-in actions and does not expose the signed-in message or sign-out action. **Covers:** FR-5, FR-6.
- **AC-4:** Signing out ends the current authenticated session and returns the user to the signed-out homepage state. **Covers:** FR-3, NFR-1, SPC-5.
- **AC-5:** A user can request and complete a password reset, then sign in with the replacement password; password and reset-token behavior matches the Rails 8.1.3.1 `authentication` generator defaults, and passwords are neither displayed nor stored as plaintext. **Covers:** FR-4, SPC-1, SPC-2.
- **AC-6:** Account forms conform to WCAG 2.2 Level AA, have visible labels, keyboard-operable controls, visible focus, and clear, actionable error states; unauthenticated failure messaging does not confirm account existence. **Covers:** UX-1, UX-2, UX-3, NFR-2, SPC-3.
- **AC-7:** Automated tests cover new-account registration, returning-user sign-in, password reset, sign-out, and each homepage account state. **Covers:** NFR-3.
- **AC-8:** The implementation includes no roles, administration interface, external identity provider, or email-verification flow. **Covers:** FR-7, UX-4.

## Planning readiness
Ready. The core scope and testable journeys are defined, including a WCAG 2.2 Level AA target. Production email delivery will be configured later and is outside the scope of this change.
