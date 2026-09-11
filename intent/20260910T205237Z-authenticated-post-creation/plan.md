# Plan: authenticated post creation (from accepted spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-11T18:47:02Z. Status: accepted.

## Files that change

- `db/migrate/*_create_posts.rb` (new)
- `db/schema.rb`
- `app/models/user.rb`
- `app/models/post.rb` (new)
- `app/controllers/posts_controller.rb` (new)
- `app/controllers/home_controller.rb` (delete)
- `app/views/home/show.html.erb` (delete)
- `app/views/application/_account_controls.html.erb` (new)
- `app/views/posts/index.html.erb` (new)
- `app/views/posts/_form.html.erb` (new)
- `app/views/posts/new.html.erb` (new)
- `app/views/posts/edit.html.erb` (new)
- `config/routes.rb`
- `test/fixtures/users.yml`
- `test/fixtures/posts.yml` (new)
- `test/models/post_test.rb` (new)
- `test/controllers/posts_controller_test.rb` (new)
- `test/controllers/home_controller_test.rb` (replace with root-list coverage)
- `intent/20260910T205237Z-authenticated-post-creation/plan.md`

## Order of work

1. Run `bin/rails generate scaffold Post title:string url:string body:text author:references` to produce the conventional migration, model, controller, routes, views, and baseline tests. Review the generated diff before adapting it; do not retain scaffold behavior that conflicts with this plan.
2. Adapt the generated migration to make `author_id` reference `users` with a foreign key and a database null constraint; retain required `title`, optional `url`, optional text `body`, and timestamps. Regenerate `db/schema.rb` through the migration; do not edit the schema directly.
3. Adapt generated ownership code to `User#posts` and `Post#author` (`class_name: "User"`), then add a small `Post#editable_by?(user)` predicate. Validate title presence and validate an optional URL by parsing it as an absolute URI with a host and `http` or `https` scheme; retain user-entered invalid values so the form can display field errors.
4. Replace the home root with the generated `PostsController#index` and retain only the RESTful post routes needed for `new`, `create`, `edit`, `update`, and `destroy`. Keep the feed public with `allow_unauthenticated_access only: :index`; rely on the existing application authentication boundary for every mutation. Build posts through `Current.user.posts`; before edit, update, and destroy, authorize with the model predicate and return `403 Forbidden` for a non-owner, without changing the record.
5. Extract the existing homepage's authentication-dependent sign-in, registration, identity, and sign-out content into `app/views/application/_account_controls.html.erb` before deleting the home view, then render that shared partial from the post index. Build semantic, unstyled post views around it: the public index queries all posts in database reverse-creation order, displays title, optional validated URL link, author email and creation time, safely escaped plain-text body with preserved line breaks, and an empty-state invitation. For authenticated users, add a “Create post” entry point and show “Edit”/“Delete” only on posts they authored. Share labeled `title`, `url`, and `body` fields between new/edit forms; use the specified sentence-case actions and field-associated validation errors.
6. Extend the fixture world deliberately: retain `registered_reader` for existing authentication tests; add distinct author personas only as needed to demonstrate ownership; add a small, coherent `posts.yml` cast with posts from more than one author and deterministic timestamps for feed ordering. Keep validation edge cases inline in tests rather than adding single-purpose fixtures.
7. Add focused model and integration/controller coverage for persistence/association, title and URL validation, root visibility/order/metadata/empty state/safe text, authenticated creation and retained invalid input, owner edit/update/delete, absent visitor authentication redirects, and non-owner `403` mutation denial. Update the existing homepage test to assert the new public feed and shared account controls rather than the retired standalone welcome screen.
8. Run the focused post tests after each slice, then run the repository CI-equivalent tests, lint, and security checks. Start the local app and perform a browser check of visitor feed, authenticated create/edit/delete, form errors, and keyboard-visible native controls. Do not add dependencies, deploy, push, or modify production data.

## Risks

- `Post` must use `author_id` while the application session exposes `Current.user`; the scaffold's inferred `Author` association must be explicitly bound to `User`, and an incorrect association or unscoped lookup could permit cross-user modification. Authorization must be server-side for all three owner-only actions.
- Ruby URI parsing has edge cases. The model validation must require both an HTTP(S) scheme and host, not merely a parseable string, while leaving empty URLs valid.
- Replacing the root controller/view can accidentally remove existing sign-in, registration, or sign-out access; the index must preserve those account entry points.
- Timestamps must be deterministic in fixture coverage so newest-first behavior is proven rather than incidentally passing.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The scaffold-generated routes/controller/views/tests, root route, authentication concern/application controller, `Current.user` ownership boundary, user model, shared account-controls partial, fixtures, and root-page test all converge on the same post interface.
- **Integration order:** Generate scaffold → adapt persistence/model → routes/controller authorization → shared partial and views → fixtures/tests → full verification and browser check.

## Proof

- Focused: `bin/rails test test/models/post_test.rb test/controllers/posts_controller_test.rb test/controllers/home_controller_test.rb`
- Full suite: `bin/rails db:test:prepare test`
- CI checks: `bin/rubocop`, `bin/brakeman --no-pager`, `bin/bundler-audit`, and `bin/importmap audit`
- Browser evidence at a desktop viewport for the public root feed, empty state, create/error/edit/delete flow, and visitor controls; record screenshot paths and states.
