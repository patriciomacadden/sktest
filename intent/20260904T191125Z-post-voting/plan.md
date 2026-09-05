# Plan: Post voting (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-04T21:48:11Z. Status: accepted.

## Files that change

`db/migrate/<timestamp>_create_votes.rb` (new), `db/schema.rb`, `app/models/vote.rb` (new), `app/models/user.rb`, `app/models/post.rb`, `app/models/post/pagination.rb`, `app/controllers/posts_controller.rb`, `app/controllers/posts/votes_controller.rb` (new), `app/controllers/concerns/authentication.rb`, `app/controllers/sessions_controller.rb`, `config/routes.rb`, `app/views/posts/_post.html.erb`, `app/views/posts/_vote.html.erb` (new), `app/views/posts/show.html.erb`, `app/assets/stylesheets/application.css`, `test/models/vote_test.rb` (new), `test/models/post_test.rb`, `test/controllers/posts_controller_test.rb`, `test/controllers/posts/votes_controller_test.rb` (new), `test/controllers/sessions_controller_test.rb`, `test/system/posts_test.rb`.

## Order of work

1. Add a `votes` table and `Vote` domain model belonging to a user and post. Add foreign keys, a unique database index on `[user_id, post_id]`, and a `posts.votes_count` counter cache with a non-null zero default. Back the active-vote invariant with the database constraint.
2. Add `User`/`Post` vote associations and explicit post scopes for vote-count ranking with newest-first tie breaking. Keep existing newest-first pagination for managed posts; make the public controller pass the ranked relation into existing pagination. Ensure totals/ranking are database-backed and vote state for a page does not create an N+1 query.
3. Add nested singular vote routes and a RESTful `Posts::VotesController`. Create and delete only through `current_user.votes`, redirect back to the post context, and rely on normal authentication for authorization.
4. Preserve the intended post-sign-in return location for a signed-out vote attempt: the public vote affordance links to sign-in with a validated internal post return target; successful sign-in returns to that post without creating a vote.
5. Render a shared vote affordance on public list and show pages. It will show the count before author metadata, use the approved borderless `▲` with muted-gray/orange states, provide action-and-count accessible labels and pressed state, and retain visible keyboard focus. Match show-page title typography and vote-arrow alignment to the public list treatment.
6. Add focused model, controller, and system coverage. Reuse existing `registered_member`, `other_author`, and post fixtures as the shared personas; create vote relationships inline in tests for ranking, duplicate-vote, and edge states rather than introducing one-off fixture combinations.
7. Run focused tests while implementing, then the complete CI-equivalent test, system-test, lint, and security-check commands. Visually compare the authenticated and signed-out list/show states against `vote-mockup.html`.

## Risks

- Counter-cache correctness during create/delete and migration of existing posts.
- The unique index must be the authoritative duplicate-vote protection, including concurrent requests.
- Public ranking must not unintentionally change the authenticated “My posts” ordering.
- A sign-in return target must be internal/validated to avoid an open redirect and must return to the post rather than a vote POST endpoint.
- Pagination remains offset-based as specified; vote changes can move posts between pages.

## Execution topology

Sequential. Migration/schema, model/query behavior, routes/controller behavior, views/styles, and tests share the vote model and public-post interface.

## Proof

- Model tests prove associations, counter totals, descending vote ranking with newest-first ties, and database-enforced duplicate prevention.
- Controller tests prove list/show totals, ranking, authenticated create/delete, authorization ownership, and signed-out redirect/return behavior.
- System tests prove the approved arrow states, metadata order, list/show alignment, keyboard-accessible controls, and the signed-out sign-in journey.
- `bin/rails db:test:prepare test`
- `bin/rails db:test:prepare test:system`
- `bin/rubocop -f github`
- `bin/brakeman --no-pager`
- `bin/bundler-audit`
- `bin/importmap audit`
