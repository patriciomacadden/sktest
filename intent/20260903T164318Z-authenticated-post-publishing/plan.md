# Plan: Authenticated post publishing (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-03T19:50:18Z. Status: accepted.

## Files that change

`config/routes.rb`, `db/migrate/<timestamp>_create_posts.rb` (new), `db/schema.rb`, `app/models/post.rb` (new), `app/models/user.rb`, `app/controllers/posts_controller.rb` (new), `app/controllers/my/posts_controller.rb` (new), `app/views/posts/index.html.erb` (new), `app/views/posts/show.html.erb` (new), `app/views/my/posts/index.html.erb` (new), `app/views/my/posts/new.html.erb` (new), `app/views/my/posts/edit.html.erb` (new), `app/views/my/posts/_form.html.erb` (new), `app/views/shared/_post_navigation.html.erb` (new), `app/views/home/index.html.erb`, `test/fixtures/users.yml`, `test/fixtures/posts.yml` (new), `test/models/post_test.rb` (new), `test/controllers/posts_controller_test.rb` (new), `test/controllers/my/posts_controller_test.rb` (new), `test/system/posts_test.rb` (new).

## Order of work

1. Add a `posts` table owned by a user (`author`), with required title, optional URL/body, timestamps, foreign key, and indexes supporting newest-first public and author queries. Regenerate `db/schema.rb`.
2. Add `Post` and its `User` association. Normalize titles and original URLs; turn bare web addresses, including host/path values, into HTTPS URLs; validate required title and HTTP(S) original URLs.
3. Add public `PostsController` index/show routes and authenticated, namespaced `My::PostsController` REST CRUD routes. Scope all author actions through `current_user.posts`; use strong parameters.
4. Implement database-backed newest-first pagination without a new gem. Each query requests one extra record to determine whether a functional “Next” control exists, while rendering at most 20 posts.
5. Build unstyled semantic HTML views matching the accepted mockups: public list/show, author list with public-show title links plus edit/delete actions, and labelled create/edit forms with accessible errors and pagination navigation.
6. Add minimal post navigation from the existing home page and reuse a post-navigation partial across post pages without changing authentication behavior.
7. Add tests using a small fixture persona set: `registered_member` as the primary author, one other author for ownership boundaries, representative posts for each; create the 21-record pagination boundary inline only in pagination tests.
8. Run focused model, controller, and system tests while iterating; then run the complete Rails suite, RuboCop, security checks, and a browser/system-test walkthrough against the approved semantic mockups.

## Risks

- URL normalization/validation must accept bare web addresses such as `google.com`, `www.google.com`, and `example.com/some-path`, normalize them to HTTPS, and reject malformed or non-HTTP(S) values.
- Ownership must remain enforced for every management action despite public show pages.
- Pagination must not display an enabled next/previous action when no corresponding page exists.
- Public author emails are intentional and approved, but remain scrapeable by design.

## Execution topology

Sequential. The migration, model association, routes, controllers, views, fixtures, and tests share the post interface and must be integrated in that order.

## Proof

- Focused: `bin/rails test test/models/post_test.rb test/controllers/posts_controller_test.rb test/controllers/my/posts_controller_test.rb`
- UI: `bin/rails test:system TEST=test/system/posts_test.rb`, including public, signed-in author, validation, pagination, and ownership scenarios.
- Full: `bin/rails test`, `bin/rubocop`, `bin/bundler-audit`, `bin/importmap audit`, and `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` (or `bin/ci`, if its setup step is suitable in the local environment).
