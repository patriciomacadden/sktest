# Plan: basic app styling (from `spec.md`)
Author: Patricio Mac Adden. Timestamp: 2026-09-14T15:43:01Z. Status: accepted.

## Rails generators

No `bin/rails generate ...` command applies. This is a presentation-only change to existing Rails views, partials, and the existing stylesheet; it creates no generator-supported model, controller, migration, scaffold, or other artifact.

## Files that change

- `app/assets/stylesheets/application.css`
- `app/views/layouts/application.html.erb`
- `app/views/application/_account_controls.html.erb`
- `app/views/posts/index.html.erb`
- `app/views/posts/show.html.erb`
- `app/views/posts/new.html.erb`
- `app/views/posts/edit.html.erb`
- `app/views/posts/_form.html.erb`
- `app/views/comments/_comment.html.erb`
- `app/views/comments/_form.html.erb`
- `app/views/sessions/new.html.erb`
- `app/views/registrations/new.html.erb`
- `app/views/passwords/new.html.erb`
- `app/views/passwords/edit.html.erb`
- `test/controllers/posts_controller_test.rb`
- `test/controllers/sessions_controller_test.rb`
- `test/controllers/registrations_controller_test.rb`
- `test/controllers/passwords_controller_test.rb`
- `intent/20260911T220450Z-basic-app-styling/plan.md`

## Order of work

1. Replace the stylesheet manifest comments with a small, dependency-free CSS token and component system matching approved revision 02: paper/surface/ink/slate/blue/yellow colors, system font stacks, layout widths, header navigation, compact post list, comment-depth rails, native forms, notices/errors, focus states, and narrow-viewport rules.
2. Update the application layout and account-controls partial to form the shared semantic header and navigation. Keep the existing links, sign-out form, authenticated-state branching, CSRF behavior, and content yield intact; place Create post in authenticated navigation.
3. Restructure the posts index and detail markup only as needed for the approved scan order: a heading-free compact index list with `title (url)`, metadata, count, and owner actions; and a detail with `title (url)`, metadata, then body. Preserve URLs, text-safe body rendering, time elements, and existing routes/actions.
4. Apply shared wrapper/classes and action grouping to post and comment forms and comment-thread markup. Retain existing labels, input names, error IDs/ARIA associations, Turbo frame identity, nested ordered lists, and CRUD/reply/edit/delete behavior.
5. Apply shared wrappers/classes to the sign-in, registration, password-request, and password-update screens without changing input autocomplete, required, maxlength, values, notices, alerts, action labels, or form endpoints.
6. Update focused controller/view assertions to prove the global navigation and new post-list/detail structure while retaining existing tests for authorization, form validation, and content behavior.
7. Run targeted Rails controller tests, the full Rails test suite, and a local browser visual comparison against revision-02 mockups at desktop and narrow viewports. Address any functional or visual discrepancy before completion.

## Risks

- Styling-driven markup edits could accidentally change an existing form association, Turbo frame, authorization-gated control, or safe text rendering. Preserve all existing Rails helpers, IDs, and form objects, and prove this with controller tests.
- Compacting the index could lose a URL, comment-count link, metadata, or owner actions. Add focused assertions and compare it with `mockups/revision-02/posts-index.html`.
- Global CSS could reduce navigation contrast, hide focus, or make nested comments unusable on small screens. Verify keyboard-focus styling and both desktop and narrow viewports in the browser.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The stylesheet, application layout, account controls, and all affected views share global CSS selectors and visual behavior.
- **Integration order:** Establish the shared CSS/header first, then posts/comments, then authentication forms, then assertions and visual/full-suite verification.

## Proof

- `bin/rails test test/controllers/posts_controller_test.rb test/controllers/comments_controller_test.rb test/controllers/sessions_controller_test.rb test/controllers/registrations_controller_test.rb test/controllers/passwords_controller_test.rb`
- `bin/rails test`
- Run the app locally and use Playwright at desktop and narrow viewports to capture the posts index, post detail (including nested comments), post form, sign-in, registration, and both password screens. Compare them to `mockups/revision-02/`; verify visible focus and that authenticated/unauthenticated navigation states show the existing applicable actions.
