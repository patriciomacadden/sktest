# Plan: comment voting (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-08T15:20:24Z. Status: accepted.

## Files that change

`db/migrate/<timestamp>_create_comment_votes.rb` (new), `db/schema.rb`, `app/models/comment_vote.rb` (new), `app/models/comment.rb`, `app/models/user.rb`, `app/models/comment/thread.rb`, `app/controllers/posts_controller.rb`, `app/controllers/posts/comments/votes_controller.rb` (new), `config/routes.rb`, `app/views/posts/comments/_comment.html.erb`, `app/views/posts/comments/_vote.html.erb` (new), `app/assets/stylesheets/application.css`, `test/models/comment_vote_test.rb` (new), `test/controllers/posts/comments/votes_controller_test.rb` (new), `test/system/comments_test.rb`.

## Order of work

1. Add a reversible migration creating comment-vote records linked to a user and comment, with foreign keys, indexes for comment lookup, and a unique database index on `[user_id, comment_id]`. Add a non-null, zero-default `comments.votes_count` counter cache. Use foreign-key cascade behavior so removing a post and its comments cannot leave orphaned comment votes.
2. Add `CommentVote` and the corresponding `Comment` and `User` associations. Use the counter cache so comment totals are persisted and do not require per-comment vote aggregation.
3. Extend comment-thread loading to preload the current thread’s vote associations as needed, and have the post show action determine the signed-in user’s voted comment IDs without N+1 queries.
4. Add a nested singular comment-vote resource and a `Posts::Comments::VotesController`. Resolve the comment through its post; create only through `current_user`; remove only through `current_user`’s vote association. Reject deleted comments without mutation and use the existing redirect/flash conventions.
5. Add a comment vote partial and render it in each non-deleted comment’s action area. Mirror the established post-vote arrow, selected state, accessible labels, pressed state, and sign-in affordance; display zero counts. Render only the retained total for deleted comments. Add narrowly scoped CSS so the control fits comment actions and remains usable at the 320px layout.
6. Add focused tests using the existing `registered_member`, `other_author`, and conversation-comment fixture personas. Create votes inline for duplicate, ownership, deleted-comment, and display states; do not add fixture combinations for one-off cases.
7. Run focused model/controller/system tests during implementation, inspect the rendered signed-in, signed-out, voted, zero-vote, and deleted-comment states, then run repository-required test, style, and security checks.

## Risks

- The unique index and counter cache must remain correct for duplicate and concurrent create attempts.
- Comment deletion intentionally retains votes, while post deletion must not orphan comment-vote records.
- Thread rendering must not introduce per-comment vote queries.
- Nested routing and post-scoped comment lookup must prevent a vote request from targeting a comment belonging to another post.
- A direct request against a deleted comment must not change votes even though its retained count remains public.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The migration/schema establishes the model interface consumed by controllers, thread loading, views, and tests.
- **Integration order:** Schema/model → query loading → routes/controller → views/styles → tests → full validation.

## Proof

- Model tests prove counter increments/decrements and database-enforced one-vote-per-user-per-comment behavior.
- Controller tests prove authenticated add/remove, self-voting, ownership protection, mismatched post/comment rejection, signed-out behavior, and deleted-comment immutability.
- System tests prove zero-count display, signed-in/signed-out affordances, accessible active/inactive controls, count changes, deleted-comment presentation, and mobile layout.
- `bin/rails test test/models/comment_vote_test.rb test/controllers/posts/comments/votes_controller_test.rb test/models/comment_test.rb test/controllers/posts/comments_controller_test.rb`
- `bin/rails test:system test/system/comments_test.rb`
- `bin/ci`
- `bin/rails test:system`
- `bin/rubocop`
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
- `bin/bundler-audit`
- `bin/importmap audit`
