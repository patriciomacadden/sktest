# Plan: public user authentication (from accepted spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-11T03:12:08Z. Status: accepted.

## Files that change

- `Gemfile`
- `Gemfile.lock`
- `db/migrate/*_create_users.rb` (new)
- `db/migrate/*_create_sessions.rb` (new)
- `app/models/user.rb` (new)
- `app/models/session.rb` (new)
- `app/models/current.rb` (new)
- `app/controllers/concerns/authentication.rb` (new)
- `app/controllers/sessions_controller.rb` (new)
- `app/controllers/passwords_controller.rb` (new)
- `app/controllers/registrations_controller.rb` (new)
- `app/controllers/home_controller.rb` (new)
- `app/controllers/application_controller.rb`
- `app/mailers/passwords_mailer.rb` (new)
- `app/views/sessions/new.html.erb` (new)
- `app/views/passwords/new.html.erb` (new)
- `app/views/passwords/edit.html.erb` (new)
- `app/views/passwords_mailer/reset.html.erb` (new)
- `app/views/passwords_mailer/reset.text.erb` (new)
- `app/views/registrations/new.html.erb` (new)
- `app/views/home/show.html.erb` (new)
- `config/routes.rb`
- `test/fixtures/users.yml` (new)
- `test/models/user_test.rb` (new)
- `test/controllers/sessions_controller_test.rb` (new)
- `test/controllers/passwords_controller_test.rb` (new)
- `test/controllers/registrations_controller_test.rb` (new)
- `test/controllers/home_controller_test.rb` (new)
- `test/test_helper.rb`
- `test/test_helpers/session_test_helper.rb` (new)
- `intent/20260910T202108Z-public-user-authentication/plan.md` (new)

## Order of work

1. Run Rails’ built-in authentication generator, enabling `bcrypt` and creating conventional user/session persistence, session handling, password-reset routes, mailer, and tests.
2. Add a `RegistrationsController` and `new/create` routes for public self-registration. Create a user with a unique email address and password; on success, start its session and redirect home; on invalid input or duplicate email, re-render the semantic HTML form with errors.
3. Add a public `HomeController#show` as the root route. Render sign-in/sign-up links to visitors and “Signed in as …” plus a semantic sign-out form to authenticated users.
4. Keep generated password-reset behavior intact. Do not configure a production email provider or add custom CSS.
5. Replace generated generic test data with the named fixture persona `registered_reader`, representing a normal registered account. Add focused tests for model validation, registration (including duplicate email), session creation/destruction, homepage states, and password reset.
6. Run migrations and the focused tests after each relevant slice; then run the full Rails test suite, RuboCop, Brakeman, Bundler Audit, and Importmap audit. Use a local browser check to verify the semantic homepage, registration, sign-in, sign-out, and password-reset entry points.
7. Commit implementation and its tests with the accepted plan kept aligned. No deployment, push, or production email configuration.

## Risks

- The Rails generator modifies shared application, route, dependency, and test-helper files; custom registration and root-route additions must preserve its authentication boundary.
- Password reset can be verified with Rails’ test mail delivery, but production delivery configuration is intentionally out of scope.
- The application has no existing test conventions beyond default Minitest; generated test behavior will be checked and supplemented rather than assumed correct.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** Routes, `ApplicationController`, test helper, database migrations, and generated authentication files.
- **Integration order:** Generate baseline authentication → add registration/homepage → add/adjust tests → full verification.

## Proof

- Focused Minitest coverage for `User`, registration, sessions, passwords, and homepage behavior.
- `bin/rails db:test:prepare test`
- `bin/rubocop`
- `bin/brakeman --no-pager`
- `bin/bundler-audit`
- `bin/importmap audit`
- Local browser verification of all account-access screens using semantic HTML and no custom CSS.
