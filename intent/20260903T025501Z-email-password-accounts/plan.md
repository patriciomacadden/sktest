# Plan: Email-password accounts (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-03T14:14:47Z. Status: accepted.

## Files that change

Gemfile, Gemfile.lock, config/routes.rb, app/controllers/application_controller.rb, app/controllers/concerns/authentication.rb (new), app/controllers/home_controller.rb (new), app/controllers/registrations_controller.rb (new), app/controllers/sessions_controller.rb (new), app/controllers/passwords_controller.rb (new), app/models/current.rb (new), app/models/session.rb (new), app/models/user.rb (new), app/mailers/passwords_mailer.rb (new), app/views/home/index.html.erb (new), app/views/registrations/new.html.erb (new), app/views/sessions/new.html.erb (new), app/views/passwords/new.html.erb (new), app/views/passwords/edit.html.erb (new), app/views/passwords_mailer/reset.html.erb (new), app/views/passwords_mailer/reset.text.erb (new), app/channels/application_cable/connection.rb, db/migrate/*_create_users.rb (new), db/migrate/*_create_sessions.rb (new), test/fixtures/users.yml (new), test/models/user_test.rb (new), test/controllers/registrations_controller_test.rb (new), test/controllers/sessions_controller_test.rb (new), test/controllers/passwords_controller_test.rb (new), test/controllers/home_controller_test.rb (new), test/mailers/previews/passwords_mailer_preview.rb (new), test/test_helpers/session_test_helper.rb (new), test/test_helper.rb, test/application_system_test_case.rb (new), test/system/authentication_test.rb (new).

## Order of work

1. Run Rails 8.1.3.1’s `authentication` generator and retain its defaults for `User`, `Session`, `Current`, cookie-backed sessions, rate limits, password reset, mailer, routes, migrations, and `bcrypt`.
2. Add the small registration flow absent from the generator: a public `RegistrationsController`, singular registration route, and sign-up form with email address, password, and matching password confirmation. Use Rails strong parameters and preserve the email-normalization and unique-database-index guarantees from the generated user model.
3. Add a public `HomeController#index` and root route. Render sign-up/sign-in actions when unauthenticated; render `Signed in as <email address>` and a sign-out action when authenticated.
4. Update generated auth templates and new registration/home templates to meet the HTML-only WCAG 2.2 AA scope: associated labels, semantic forms and buttons, autocomplete attributes, visible browser focus, accessible validation/status messages, and consistent action labels. Avoid inline color-only error signaling and custom visual styling.
5. Keep unauthenticated sign-in and reset responses generic. For sign-up failures, identify correctable validation issues without revealing whether an existing email address owns an account.
6. Add focused Minitest coverage. Use one named `registered_member` fixture persona for the stable registered-user path; keep password mismatch, invalid credentials, duplicate registration, and expired/invalid reset-token cases local to their tests.
7. Add system coverage for registration, sign-in/home state, sign-out, and password reset. Use the test mail delivery already configured; do not add production email-provider configuration.
8. Run the full CI-equivalent proof and inspect the rendered flows, including keyboard navigation and visible focus.

## Risks

- Rails’ generator does not provide registration; the custom flow must integrate with its authentication concern without weakening defaults.
- A duplicate-email response can enable account enumeration; it needs generic unauthenticated messaging while still giving useful password-confirmation feedback.
- Password-reset production delivery is intentionally deferred, so production deployment will need later email configuration.
- The generated templates need accessibility corrections before they meet the WCAG 2.2 AA requirement.

## Execution topology

Sequential. The generator output, routes, authentication concern, homepage, templates, and tests share the same session and user interfaces. Implement and integrate in one working tree.

## Proof

- Targeted model/controller/integration tests while implementing.
- `bin/rails db:test:prepare test`
- `bin/rails db:test:prepare test:system`
- `bin/rubocop`
- `bin/brakeman --no-pager`
- `bin/bundler-audit`
- `bin/importmap audit`
- Manual/system-browser check of the signed-out homepage, registration, sign-in, sign-out, reset request, reset completion, keyboard navigation, labels, errors, and focus visibility.
