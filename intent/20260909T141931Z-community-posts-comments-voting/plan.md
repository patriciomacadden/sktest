# Plan: Community posts, comments, and voting (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-09T15:34:21Z. Status: accepted.

## Files that change

Gemfile, Gemfile.lock, config/routes.rb, app/controllers/application_controller.rb, app/controllers/{registrations,sessions,passwords,posts,comments}_controller.rb (new), app/controllers/posts/votes_controller.rb (new), app/controllers/comments/votes_controller.rb (new), app/models/{user,post,comment,vote}.rb (new), app/views/layouts/application.html.erb, app/views/{registrations,sessions,passwords,posts,comments}/… (new), app/views/posts/votes/… (new, if Turbo responses are used), app/assets/stylesheets/application.css, db/migrate/*_create_users.rb (new), db/migrate/*_create_posts.rb (new), db/migrate/*_create_comments.rb (new), db/migrate/*_create_votes.rb (new), test/fixtures/{users,posts,comments,votes}.yml (new), test/models/{user,post,comment,vote}_test.rb (new), test/controllers/{registrations,sessions,passwords,posts,comments}_controller_test.rb (new), test/controllers/posts/votes_controller_test.rb (new), test/controllers/comments/votes_controller_test.rb (new), test/integration/public_posts_test.rb (new), test/integration/authentication_test.rb (new), test/integration/discussion_test.rb (new), intent/20260909T141931Z-community-posts-comments-voting/plan.md (new).

## Order of work

1. Add `bcrypt`, then implement Rails-native email/password authentication: `User` with normalized, uniquely indexed email and `has_secure_password`; session-based sign-in/sign-out; registration; and reset-token email/reset flows using Rails-supported password-reset tokens.
2. Add posts, comments, and polymorphic votes with foreign keys, indexes, and database uniqueness constraints. Use `votes_count` and `comments_count` counter caches so public list metadata and ordering avoid per-row counting.
3. Model ownership and deletion rules: posts own comments and votes; post deletion destroys all related comments and votes; comment deletion marks it deleted and replaces visible content with `[deleted]`, preserving descendants and existing votes while disallowing further replies. Model predicates define author-only edit/delete access.
4. Add conventional REST routes/controllers for posts, nested comment creation, shallow comment edit/update/delete, sessions/registration/passwords, and singular nested post/comment vote resources. Require authentication for writes and reject unauthorized ownership actions.
5. Build the public post list and post-detail thread from the approved mockups: vote-descending list, same-tab optional URL, title/body/metadata, immediate publication, nested indented replies, auth prompts, and responsive, keyboard-visible controls. Render user-supplied URLs as links only for valid HTTP(S) URLs, leaving other supplied values as escaped text to prevent executable URL schemes. Build simple auth and create/edit forms with clear validation errors.
6. Add focused Minitest coverage. Fixture personas will be: `maya` (post author with a popular post), `alex` (ordinary participant and voter), `rui` (another participant), and `newcomer` (empty account). Rare states—such as a deleted parent comment and duplicate-vote attempt—will be created or mutated inline rather than becoming fixture combinations.
7. Run migrations and the full test suite; run RuboCop and Brakeman. Exercise the key public/authenticated journeys with system/integration tests and correct failures.

## Risks

- Publicly displaying email addresses is intentional but permanently exposes account identifiers alongside public content.
- Polymorphic vote counter caches and concurrent vote creation need both unique indexes and controller/model handling of uniqueness failures.
- Unlimited-depth comment rendering must be recursive without creating unbounded query volume; preload the thread data and avoid N+1 queries.
- The password-reset flow needs a correctly configured host in each environment.
- SQLite’s concurrent-write behavior can expose vote/comment contention; tests will prove duplicate-vote protection, but production traffic may later require rate limiting or a database review.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** Authentication establishes `Current.user`/session behavior used by every write controller; models, migrations, routes, layout, and styles are shared by all features.
- **Integration order:** Authentication → persistence/invariants → routes and controllers → views/styles → tests and checks.

## Proof

- `bin/rails db:migrate`
- `bin/rails test`
- Targeted model/controller/integration tests for AC-1 through AC-7, including one-vote uniqueness, ownership denial, post cascade deletion, and deleted comment reply prevention.
- `bin/rubocop`
- `bin/brakeman`
- Manual/system verification of public browsing, same-tab source links, registration/sign-in/reset, post creation, nested replies, upvote toggling, and responsive keyboard navigation.
