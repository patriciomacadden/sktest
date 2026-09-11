# Review

## Review basis
- Compared: `24b76b3 Add authenticated post comments` against its accepted-plan parent `ca47efd Approve comment implementation plan`.
- Reviewed revision: `24b76b37240179b23c038e07b85f084bcfa5cc2c`.
- Policy and context read: `REVIEW.md`, `AGENTS.md`, `intent.md`, accepted `spec.md`, and accepted `plan.md`.
- Limitations: The local `main` branch predates unrelated feature work, so this review is limited to the comment implementation commit and its relevant callers/tests. The working tree contains untracked `.agents/`, which was not reviewed.

## Findings

### R1 — Compliance — redundant `only:` route restriction
- Location: `config/routes.rb:3`
- Why it matters: Listing every standard `posts` action in `only:` provides no restriction and obscures that the resource deliberately exposes the conventional Rails CRUD surface.
- Evidence: `index`, `show`, `new`, `create`, `edit`, `update`, and `destroy` are the complete standard action set for `resources :posts`.
- Suggested direction: Use unqualified `resources :posts` while retaining the nested comment routes.
- Outcome: Fixed — `4a18bb6 Use conventional post routes`; `bin/rails routes -g post` and `bin/rails test test/controllers/posts_controller_test.rb test/controllers/comments_controller_test.rb` — 17 runs, 122 assertions, passing.

## Review passes
- Bugs: No findings. The model/controller/view flow preserves soft-deleted comments and descendants, rejects deleted and cross-post reply parents server-side, and uses database ordering/counter caching. Targeted test evidence: `bin/rails test test/models/comment_test.rb test/controllers/comments_controller_test.rb test/controllers/posts_controller_test.rb` — 22 runs, 138 assertions, passing.
- Security: No findings. Authentication and ownership checks cover comment mutations; comment text is escaped before rendering. `bin/brakeman --no-pager` reported no warnings.
- Compliance: R1 fixed. The implementation follows the accepted spec and plan: resourceful nested routes, public reading, author-only soft deletion, retained deleted-comment metadata and replies, oldest-first hierarchy, database-backed counts, generated Rails artifacts, and no new dependency.

## Learning

### Proposed AGENTS.md update
None.

### Proposed REVIEW.md update
None.
