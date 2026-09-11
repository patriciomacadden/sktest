# Specification: public user authentication
Author: Patricio Mac Adden. Timestamp: 2026-09-11T02:37:55Z. Status: accepted.

## Applied policies
- Rails Best Practices Core: Prefer Rails conventions and built-ins, model authorization as simple predicates, and ship tests with behavior changes; source: `.agents/skills/rails-best-practices-core/SKILL.md`.
- Frontend Design: Use clear, user-controlled language; provide responsive layouts, visible keyboard focus, and reduced-motion support; source: `/Users/patricio/.agents/skills/frontend-design/SKILL.md`.

## Summary
The application needs public user accounts so people can establish an identity and securely use protected features. This release provides email/password registration, sign-in, sign-out, and password reset, plus a homepage that clearly reflects whether the visitor is signed in. Email confirmation is not required; accounts are usable immediately after registration. Email delivery configuration is intentionally deferred.

## Users and primary journeys
- A visitor registers with an unused email address and password, then reaches the signed-in homepage.
- A registered person signs in and sees their identity plus a sign-out control on the homepage.
- A signed-in person signs out and returns to the visitor homepage with sign-in and sign-up controls.
- A person who has forgotten their password follows the Rails authentication generator's default password-reset flow.

## Functional requirements
- **FR-1:** Visitors can register a new account using an email address and password. A successfully registered account is immediately usable without email confirmation. **Source:** Intent constraints; product-owner decision.
- **FR-2:** Registration rejects an email address already associated with an account and presents a usable error. **Source:** Product-owner decision.
- **FR-3:** Registered users can sign in with their email address and password and sign out from an authenticated session. **Source:** Intent proposed outcome.
- **FR-4:** The application provides password reset behavior matching the Rails authentication generator's default flow. **Source:** Intent constraints; product-owner decision.
- **FR-5:** The homepage shows signed-in people “Signed in as...” and a sign-out control; it shows visitors sign-in and sign-up controls instead. **Source:** Intent proposed outcome.
- **FR-6:** Authentication-protected actions reject unauthenticated access. The first protected actions will be introduced by subsequent accepted work; this change establishes the shared authentication boundary. **Source:** Intent open question.

## UX and design requirements
- **UX-1:** Account-access controls and form labels use plain, consistent, sentence-case language that describes the action (for example, “Sign in”, “Create account”, and “Sign out”). **Source:** Frontend Design.
- **UX-2:** Registration, sign-in, and password-reset forms identify invalid or missing input and explain how to correct it. **Source:** Frontend Design.
- **UX-3:** Use semantic HTML form controls, labels, headings, links, and buttons so account-access flows are usable with keyboard navigation and assistive technology. Do not add custom CSS in this release. **Source:** Product-owner decision; Frontend Design.

## Non-functional requirements
- **NFR-1:** Use Rails conventions and the built-in authentication generator rather than adding a third-party authentication dependency. **Source:** Product-owner decision; Rails Best Practices Core.
- **NFR-2:** Automated tests cover registration, duplicate-email rejection, sign-in, sign-out, homepage states, and the password-reset flow. **Source:** Rails Best Practices Core.

## Security, privacy, and compliance requirements
- **SPC-1:** Passwords must not be stored in plaintext; authentication credentials and session handling must use the Rails authentication generator's default secure mechanisms. **Source:** Product-owner decision to use Rails built-in authentication.
- **SPC-2:** Password-reset behavior must use the Rails authentication generator's default token and expiration behavior; reset tokens must not be exposed in application responses or logs. **Source:** Product-owner decision.
- **SPC-3:** Only the minimum account identity data needed for email/password authentication is collected in this release: email address and password credential. **Source:** Intent constraints.

## Constraints applied
- Rails Best Practices Core: Use conventional Rails models, controllers, routes, and database constraints for account uniqueness; do not introduce a third-party authentication or authorization framework without a new decision.
- Frontend Design: Make interface language actionable and user-centered; meet baseline accessibility through semantic HTML and native browser behavior. The product owner has deferred custom CSS and visual styling.

## Assumptions and open questions
- Production email delivery settings are deliberately out of scope for this specification. Development and test environments still need a safe way to exercise the default reset flow.
- The future pages and actions that require authentication will be decided by subsequent design work.
- No organization-specific security, privacy, legal, or compliance policy skill is available in this repository; no compliance claim is made beyond the requirements above.

## Flagged concerns

None identified. Production email-delivery configuration is intentionally deferred and is not a prerequisite for this authentication scope.

## Acceptance criteria
- **AC-1:** A visitor can create an account with a new email address and password, is signed in immediately, and sees “Signed in as...” with a sign-out control on the homepage. **Covers:** FR-1, FR-5.
- **AC-2:** A registration attempt using an existing email address does not create a second account and displays an actionable error. **Covers:** FR-2, UX-2, SPC-3.
- **AC-3:** A registered person can sign in with valid credentials, sign out, and after signing out sees sign-in and sign-up controls rather than authenticated controls. **Covers:** FR-3, FR-5.
- **AC-4:** A person can initiate and complete password reset according to the Rails authentication generator's default flow, without reset tokens appearing in the rendered response or application logs. **Covers:** FR-4, SPC-2.
- **AC-5:** The registration, sign-in, and password-reset flows use semantic HTML and have automated regression coverage. **Covers:** UX-1, UX-2, UX-3, NFR-2.

## Planning readiness
Ready. Functional scope and authentication approach are decided. Production email-delivery configuration is intentionally deferred to later work.
