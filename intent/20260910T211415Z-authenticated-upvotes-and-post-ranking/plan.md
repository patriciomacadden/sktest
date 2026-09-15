# Plan: authenticated upvotes and post ranking (from accepted spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-15T15:20:00Z. Status: accepted.

## Files that change

- `db/migrate/*_create_upvotes.rb` (new), `db/migrate/*_add_upvotes_count_to_posts_and_comments.rb` (new), `db/schema.rb`
- `app/models/upvote.rb` (new), `app/models/user.rb`, `app/models/post.rb`, `app/models/comment.rb`
- `app/controllers/posts/upvotes_controller.rb` (new), `app/controllers/comments/upvotes_controller.rb` (new), `app/controllers/posts_controller.rb`, `config/routes.rb`
- `app/views/upvotes/_tally.html.erb` (new), `app/views/posts/index.html.erb`, `app/views/posts/_post.html.erb`, `app/views/posts/show.html.erb`, `app/views/comments/_comment.html.erb`, `app/assets/stylesheets/application.css`
- `test/fixtures/upvotes.yml` (new), `test/models/upvote_test.rb` (new), `test/models/post_test.rb`, `test/controllers/posts/upvotes_controller_test.rb` (new), `test/controllers/comments/upvotes_controller_test.rb` (new), `test/controllers/posts_controller_test.rb`, `test/controllers/comments_controller_test.rb`

## Order of work

1. Generate the supported artifacts rather than hand-creating them:
   - `bin/rails generate model Upvote user:references voteable:references{polymorphic}`
   - `bin/rails generate migration AddUpvotesCountToPostsAndComments`
   - `bin/rails generate controller Posts::Upvotes --skip-routes`
   - `bin/rails generate controller Comments::Upvotes --skip-routes`
   The generators establish the model, migration, controller, and test conventions. The generated migration must then be completed manually because the generator cannot express the required composite unique index or both target counter-cache columns. Routes are hand-edited because the generator cannot declare the nested singular resource topology.
2. Model upvotes as a polymorphic `Upvote` belonging to a user and a `voteable` post or comment. Add non-null foreign/referential constraints where supported, the unique database index on `[user_id, voteable_type, voteable_id]`, indexes appropriate to target lookup and the 24-hour ranking query, and `upvotes_count` counter caches on posts and comments. Add corresponding associations and destructive dependencies so deleting a post, comment, or user removes its votes. Add small domain predicates/finders only where used for current-user vote state and safe removal.
3. Implement `Post.hot` and `Post.newest`. `hot` will use a database left outer join constrained to post upvotes created at or after the query-time 24-hour cutoff, group by post, order by aggregate count descending and post creation time descending, and retain posts with zero recent votes. `newest` will order creation time descending. The root controller will select `hot` by default and `newest` only for the explicit `new` order parameter; it will preload authors and the current user's votes without per-record queries.
4. Add singular nested upvote resources for posts and comments, routed to `Posts::UpvotesController` and `Comments::UpvotesController`. Each controller will create the current user's vote or destroy only that current user's vote for its server-scoped target, require authentication through the existing boundary, and redirect back to the relevant listing/detail anchor. Use database uniqueness as the final concurrency guard and handle an already-present/absent current-user vote without duplicating or removing another user's data.
5. Render the approved tally-rail partial for every root-feed post, the post detail, and every comment. It will show the counter-cache total; for signed-in users it will use native “Upvote”/“Remove upvote” submit controls with `aria-pressed`; for visitors it will show the same total and an explicit sign-in link. Add `Hot`/`New` feed navigation with semantic current-order state. Extend the existing stylesheet only with the responsive tally rail and its selected/focus states, preserving the approved blue/yellow/plain-Rails mockup.
6. Add focused model and integration tests using the existing fixture personas: `registered_reader` is the voter, `published_author` owns `latest_release` and `active_root`, and `other_author` supplies a distinct vote owner. Create only the reusable happy-path `upvotes.yml` relationships; create timing boundaries, duplicates, and destruction edge cases inline in tests. Cover the uniqueness invariant, counter caches, user/target cleanup, post/comment add-remove behavior, unauthenticated and cross-user removal denial, rendered totals/current state/sign-in paths, `Hot` default, `New` selection, 24-hour cutoff, zero-vote inclusion, and ties.
7. Run focused model/controller tests after each coherent change, then the CI-equivalent test preparation and full suite, RuboCop, and browser checks against the approved mockup at a 1280px viewport and a narrow mobile viewport. Update this plan if the generated artifacts or validation approach materially differ.

## Risks

- A `new` Active Record scope would replace `Post.new`; use the accepted internal scope name `newest` while retaining `New` as the user-facing label.
- Filtering a left join in `WHERE` would exclude posts with zero recent votes; the 24-hour predicate must be part of the join condition.
- Counter caches can drift or be raced without transactional association callbacks and a database uniqueness constraint; verify both totals and duplicate submission behavior.
- The new controls appear in recursive comment rendering and must not cause N+1 current-user-vote queries or lose keyboard/mobile usability.
- `upvotes_count` is all-time, while `Hot` is a rolling recent count; do not use the counter cache to rank `Hot`.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The new `Upvote` model/migration, target associations, routes, root feed query, tally partial, and fixtures are shared by all behavior and must agree on the polymorphic target interface.
- **Integration order:** Generate and constrain data model; add associations/ranking; add routes/controllers; render UI; add and run regression coverage; perform full and visual verification.

## Proof

- Focused: `bin/rails test test/models/upvote_test.rb test/models/post_test.rb test/controllers/posts/upvotes_controller_test.rb test/controllers/comments/upvotes_controller_test.rb test/controllers/posts_controller_test.rb test/controllers/comments_controller_test.rb`.
- Full CI-equivalent: `bin/rails db:test:prepare test`, `bin/rubocop -f github`, and `bin/rails db:test:prepare test:system`.
- UI: use Playwright at 1280px and a mobile-width viewport to confirm `Hot` default/`New` navigation, post/comment tally rails, selected state, visible focus, and visitor sign-in paths against `upvote-ui-mockup.html` and `.png`.
