# Review

## Review basis
- Compared: `05d3534 Add authenticated upvotes and hot ranking` against its accepted-plan parent `5ce2bb1 Plan authenticated upvotes implementation`.
- Reviewed revision: `05d3534`.
- Policy and context read: `REVIEW.md`, `AGENTS.md`, `intent.md`, accepted `spec.md`, and accepted `plan.md`.
- Limitations: No base branch was supplied. Local `main` predates unrelated application work, so the review is limited to the implementation commit and its relevant callers/tests. The working tree contains untracked `.agents/`, which was not reviewed.

## Findings

### R1 — Bugs, Compliance — visitor sign-in links discard the intended destination
- Location: `app/views/upvotes/_tally.html.erb:7`
- Why it matters: A visitor who clicks “Sign in to upvote” from a post detail page is sent to `new_session_path` without a saved return URL. After authenticating they land at the root feed, rather than the post/comment they intended to vote on. This breaks the required protected-action journey and forces the user to find the target again.
- Evidence: The link at the cited line directly targets `new_session_path`. The authentication concern records `session[:return_to_after_authenticating]` only when a protected request reaches `request_authentication` (`app/controllers/concerns/authentication.rb:32-38`), and `after_authentication_url` otherwise defaults to `root_url`. UX-4 requires preserving the intended destination through the existing authentication flow. The controller tests cover direct unauthenticated mutation requests, but not this visitor-link/sign-in flow.
- Suggested direction: Route the visitor link through an authentication request that records the current URL, or add an explicitly validated return-location parameter supported by the existing session flow. Add an integration test starting from a post-detail vote link and asserting successful sign-in returns to that detail URL (including the comment anchor where applicable).
- Outcome: Fixed — `d9b89f3 Preserve upvote destination through sign in`; `bin/rails db:test:prepare test` — 75 runs, 394 assertions, passing; `bin/rubocop -f github` — passing.

## Review passes
- Bugs: R1 fixed. Visitor vote links now provide a safe local return location, and session creation returns there after authentication.
- Security: No findings. Upvote creation is behind the existing session boundary and destruction scopes the lookup to `Current.user`; nested comment lookup scopes the target through its post. The return location accepts only local absolute paths and rejects external URLs.
- Compliance: R1 fixed. The implementation follows the accepted data model, database uniqueness constraint, nested resource topology, `Hot`/`newest` ordering, tally-rail requirements, and UX-4 return-location requirement.

## Learning

### Proposed AGENTS.md update
None.

### Proposed REVIEW.md update
None.
