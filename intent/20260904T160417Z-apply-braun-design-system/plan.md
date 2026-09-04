# Plan: Apply the Braun design system across the application (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-04T17:27:37Z. Status: accepted.

## Files that change

`app/assets/stylesheets/application.css`, `app/views/layouts/application.html.erb`, `app/views/posts/index.html.erb`, `app/views/posts/show.html.erb`, `app/views/posts/_post.html.erb`, `app/views/shared/_post_navigation.html.erb`, `app/views/shared/_pagination.html.erb`, `app/views/my/posts/index.html.erb`, `app/views/my/posts/new.html.erb`, `app/views/my/posts/edit.html.erb`, `app/views/my/posts/_form.html.erb`, `app/views/registrations/new.html.erb`, `app/views/sessions/new.html.erb`, `app/views/passwords/new.html.erb`, `app/views/passwords/edit.html.erb`, `test/system/authentication_test.rb`, `test/system/posts_test.rb`.

## Order of work

1. Replace the public-post-only CSS with shared Braun tokens and responsive, accessible application-shell, navigation, content, list, form, status/error, pagination, and action styles. Retain usable font fallbacks and add focus/reduced-motion rules.
2. Add semantic presentation classes and page/shell wrappers to every in-scope browser view and shared partial, without changing text, routes, fields, form parameters, or behavior.
3. Assign one orange primary action per screen through context-specific classes: Sign in or Create post on public pages; Sign up, Sign in, Email reset instructions, and Save in the account flows; Create post on My posts; and Create Post or Update Post on the respective form screens. Retain neutral styling for navigation, secondary links, and destructive actions.
4. Extend existing system tests with stable structural/style hooks for the in-scope public, authentication, password, and post-management journeys, while preserving their existing behavioral coverage.
5. Run targeted system tests, the Rails test suite, RuboCop, and the configured CI target as environment permits.
6. Start the local application and use Playwright at desktop and mobile widths to inspect public browsing, an authentication form, and an authenticated post-management form; capture screenshots as evidence.

## Risks

- Broad shared CSS can unintentionally affect mailer/PWA output or browser pages outside the defined scope; scope selectors to the application HTML presentation only and verify excluded templates remain unchanged.
- A “single orange action” can conflict with global navigation and form submissions; use page-context classes so the current task’s submit action is primary on forms and creation is primary on listing screens.
- Visual changes can degrade keyboard focus, narrow layouts, or existing Rails form/error semantics; preserve semantic markup and validate rendered flows.
- System browser tooling may be unavailable locally; if so, report the exact blocker and retain the strongest available automated proof.

## Execution topology

Sequential. The work shares the application stylesheet, layout, common navigation, and reused post/form partials; implement and validate it in one session.

## Proof

- `bin/rails test:system test/system/authentication_test.rb test/system/posts_test.rb`
- `bin/rails test`
- `bin/rubocop`
- `bin/ci` when its setup and security checks can run locally
- Playwright screenshots and interaction checks at the system-test desktop viewport (1400×1400) and a narrow mobile viewport, covering public posts, sign-in, and authenticated create/edit-post states.
