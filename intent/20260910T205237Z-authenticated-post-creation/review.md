# Review

## Review basis
- Compared: `4285d3f` against `main` (the repository default branch); post-creation implementation assessed from `71a8b74..4285d3f` after the accepted specification.
- Reviewed revision: `4285d3f` (`Render account controls globally`).
- Policy and context read: `REVIEW.md`, `AGENTS.md`, the accepted intent, specification, and plan; Rails Best Practices Core and Frontend Design skills named by the specification.
- Limitations: `AGENTS.md` is modified and `.agents/` and `.playwright-cli/` are untracked; none are part of the reviewed commits. The prior authentication review record was read; its R1 was fixed before this review.

## Findings

### R1 — Compliance — Invalid form nesting in post controls (Nit)
- Location: `app/views/posts/index.html.erb:25-28`
- Why it matters: `button_to` renders a `<form>`, but a `<form>` is not permitted inside a `<p>`. Browsers repair the markup differently, leaving the author controls outside the intended paragraph and failing the specification's semantic-HTML requirement.
- Evidence: The owner-controls paragraph contains `<%= button_to "Delete", ... %>`, which Rails renders as a form. UX-2 requires semantic controls.
- Suggested direction: Use a neutral grouping element such as `<div>` for the Edit link and delete form, or place the controls as sibling elements.
- Outcome: Fixed — `f9692bf`; `bin/rails test test/controllers/posts_controller_test.rb test/controllers/home_controller_test.rb` (10 runs, 79 assertions) and `bin/rubocop` passed.

## Review passes
- Bugs: No findings.
- Security: No findings.
- Compliance: Findings above.

## Learning

### Proposed AGENTS.md update
None.

### Proposed REVIEW.md update
None.
