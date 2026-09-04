# Plan: Public posts as homepage (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-04T14:33:29Z. Status: accepted.

## Files that change

`config/routes.rb`, `app/controllers/home_controller.rb` (delete), `app/views/home/index.html.erb` (delete), `app/views/posts/index.html.erb`, `app/views/posts/_post.html.erb`, `app/views/shared/_post_navigation.html.erb`, `app/helpers/application_helper.rb`, `app/assets/stylesheets/application.css`, `test/controllers/home_controller_test.rb` (delete), `test/controllers/posts_controller_test.rb`, `test/system/posts_test.rb`, `test/system/authentication_test.rb`, `intent/20260904T030043Z-public-posts-homepage/plan.md` (new).

## Order of work

1. Point the root route at `PostsController#index`; retain `/posts`; remove the unused home controller, view, and controller test.
2. Rework the shared public-posts index markup into the approved compact ordered-list layout. Keep the existing newest-first collection, pagination, post links, metadata, conditional bodies, and management navigation behavior.
3. Update URL presentation so a validated original URL is linked by its source domain beside the post title, without weakening the existing URL-safety handling.
4. Add scoped Braun styling for the public list: required palette and type roles, flat layout, visible focus, mobile-safe header/list, and a single orange primary action.
5. Update integration and system coverage for `/` and `/posts`, conditional body/source-domain links, pagination, signed-in management navigation, and the changed post-sign-up/sign-out entry paths.
6. Run focused controller and system tests, then the complete test suite; fix any regression before reporting results.

## Risks

- Changing `root_path` changes post-authentication landing behavior and invalidates tests that expect the former welcome/sign-up homepage.
- Replacing the “Original URL” label with a source-domain link must preserve safe HTTP(S)-only URL behavior.
- Global CSS could unintentionally affect management and authentication screens; scope the new styles to the public-posts presentation.
- The root and `/posts` could drift if rendered through separate paths; both must use `PostsController#index` and one view.

## Execution topology

Sequential. Routing, shared rendering, styles, and tests overlap in the same files and interfaces.

## Proof

- `bin/rails test test/controllers/posts_controller_test.rb`
- `bin/rails test test/controllers`
- `bin/rails test:system test/system/posts_test.rb test/system/authentication_test.rb`
- `bin/rails test`
- Manually inspect `/` at desktop and a narrow mobile viewport for the approved compact hierarchy, visible keyboard focus, and no horizontal overflow.
