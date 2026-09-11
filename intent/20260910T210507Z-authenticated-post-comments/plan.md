# Plan: authenticated post comments (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-11T20:23:44Z. Status: accepted.

## Files that change

`db/migrate/*_create_comments.rb` (new), `db/migrate/*_add_comments_count_to_posts.rb` (new), `db/schema.rb`, `app/models/comment.rb` (new), `app/models/post.rb`, `app/models/user.rb`, `app/controllers/posts_controller.rb`, `app/controllers/comments_controller.rb` (new), `config/routes.rb`, `app/views/posts/index.html.erb`, `app/views/posts/show.html.erb` (new), `app/views/comments/_form.html.erb` (new), `app/views/comments/_comment.html.erb` (new), `test/fixtures/comments.yml` (new), `test/models/comment_test.rb` (new), `test/models/post_test.rb`, `test/controllers/comments_controller_test.rb` (new), `test/controllers/posts_controller_test.rb`, `test/system/.keep` (new), `intent/20260910T210507Z-authenticated-post-comments/spec.md`, and this file.

## Order of work

1. Run `bin/rails generate model Comment post:references author:references parent:references body:text deleted_at:datetime`, then tailor the generated migration to make post/author non-null, make the self-referential parent optional, point author to `users`, add foreign keys, and add indexes supporting parent/thread traversal. Run `bin/rails generate migration AddCommentsCountToPosts comments_count:integer`, tailor it to add a non-null, zero-default counter cache, and use it to maintain the database-backed count including soft-deleted comments. Regenerate `db/schema.rb` through the migrations. Configure deletion so post deletion removes its comments and nested comment cleanup does not violate parent foreign keys.
2. Run `bin/rails generate controller Comments create destroy` and tailor its generated controller/test artifacts. Add the `Comment` model behavior and the corresponding `Post`/`User` associations. Validate body presence and that a reply parent belongs to the same post. Define small model predicates for author deletion permission and whether a comment can accept replies; represent deletion by setting `deleted_at`, leaving the body and descendants intact.
3. Add public `PostsController#show`, load the post, author, comments, and comment authors without N+1 queries, and add conventional nested comment creation/deletion routes and `CommentsController` authorization. Creation will use `Current.user`, reject deleted or cross-post parents server-side, preserve invalid form input, and redirect to the post detail on success. Deletion will authorize ownership server-side, soft-delete the comment, and redirect back to the post detail.
4. Update the root feed so each title links to its detail page and each item shows a database-backed comment count including soft-deleted comments. Add the post-detail page plus recursive comment/form partials: show the post, render top-level comments and oldest-first descendants with indentation, preserve author/time metadata, substitute `[deleted]` for a soft-deleted body, show reply controls only for active comments, and show delete controls only to the creator. Present sign-in paths and empty-thread guidance where appropriate. Render bodies as escaped plain text with preserved line breaks.
5. Extend the existing fixture world rather than creating per-test combinations. Keep `published_author` as the primary participant and `other_author` as the second participant; add a small `comments.yml` thread for `latest_release` (an active root, an active reply, and a deleted root with a retained reply). Use local `update!` mutations for rare states such as a just-deleted reply target or a cross-post parent.
6. Add model and integration coverage for associations, body and same-post-parent validation, author/delete and replyability predicates, public detail rendering, feed link/count, creation at multiple depths, invalid input, ordering, soft-delete display/data retention, deletion with replies, post deletion cascading comments, unauthenticated redirects, and direct non-owner/deleted-parent/cross-post-parent denial.
7. Run focused comment and post tests after each increment. Then run the full Rails and system-test suites, RuboCop, Brakeman, Bundler Audit, Importmap audit, and a local Playwright browser pass on the public and signed-in post-detail states; record actual results and any screenshot paths. Keep an empty `test/system/` directory tracked so the repository's existing CI system-test job runs successfully when no system tests exist yet.

## Risks

- Recursive rendering and deletion must preserve parent-before-descendant order while remaining safe for arbitrarily deep threads; fixture coverage will exercise more than one reply level.
- A self-referential foreign key can block post/comment deletion if dependent cleanup is ordered incorrectly; automated post-deletion coverage will prove the required cascade.
- Reply authorization must be enforced by the server because a deleted or cross-post parent can be supplied directly even if no corresponding form is shown.
- Comment-count semantics include soft-deleted records; a default association scope must not accidentally exclude them.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The comment schema/model, post associations, nested routes, and recursive views form one coupled feature; tests and fixtures depend on that shared data model.
- **Integration order:** Schema and associations → authorization/controllers/routes → views → fixtures/tests → full verification.

## Proof

- `bin/rails test test/models/comment_test.rb test/models/post_test.rb test/controllers/comments_controller_test.rb test/controllers/posts_controller_test.rb`
- `bin/rails db:test:prepare test`
- `bin/rubocop`
- `bin/brakeman --no-pager`
- `bin/bundler-audit`
- `bin/importmap audit`
- With the local server and test-safe accounts, use Playwright to inspect the public post-detail page, signed-in creation/reply state, and deleted-comment state at a desktop viewport; preserve relevant screenshots under `tmp/`.
