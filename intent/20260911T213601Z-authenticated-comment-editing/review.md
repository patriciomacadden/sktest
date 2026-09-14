# Review

## Review basis
- Compared: implementation commit `b4c8c7e` against its approved-plan predecessor `cfcb563`; the local fallback default branch is `main`.
- Reviewed revision: `b4c8c7e`.
- Policy and context read: `REVIEW.md`, `AGENTS.md`, `intent.md`, accepted `spec.md`, accepted `plan.md`, Rails Best Practices Core, and Rails Hotwire + Realtime.
- Limitations: the working tree has unrelated untracked `.agents/` content, which was not reviewed. This review did not rerun automated checks.

## Findings

### R1 — Bugs — Important — Deleted comments retain the edited marker
- Location: `app/models/comment.rb:19-21`, rendered by `app/views/comments/_comment.html.erb:3`.
- Why it matters: If an author edits a comment and later soft-deletes it, `delete!` preserves `edited_at`. The deleted placeholder therefore renders as `[deleted]` with `(edited)`, although FR-4 and AC-2 require deleted comments not to display the indicator.
- Evidence: `Comment#edited?` checks only `edited_at.present?`; neither `Comment#delete!` nor the partial excludes deleted comments. The existing tests cover either edited or deleted comments, but not edit-then-delete.
- Suggested direction: Make edited presentation exclude deleted comments (for example, fold the active-state condition into `edited?` or the view) and add a regression test for an edited comment that is subsequently soft-deleted.
- Outcome: Fixed — `1ce0876`; `bin/rails test test/models/comment_test.rb test/controllers/comments_controller_test.rb`, `bin/rubocop -f github`, and `bin/rails db:test:prepare test` passed.

## Review passes
- Bugs: Findings above.
- Security: No findings.
- Compliance: Findings above; R1 violates FR-4, UX-3, and AC-2 of the accepted specification.

## Learning

### Proposed AGENTS.md update
None.

### Proposed REVIEW.md update
None.
