# Sktest

Rails 8.1 application using SQLite, Turbo, Minitest fixtures, and Selenium/Chrome system tests.

## Local setup

With the repository's Ruby environment active and dependencies installed:

```sh
bundle check
bin/rails db:prepare
bin/dev
```

`bin/setup --skip-server` is the existing fuller setup target; it may install missing gems and prepares the development database. Do not point local or test commands at a production database.

## Verification

Run the application tests and browser tests separately (Chrome must be available):

```sh
bin/rails test
bin/rails test:system
```

Healthy output ends with `0 failures, 0 errors, 0 skips`. System tests are not included in the default `bin/ci` configuration.

Focused comment checks:

```sh
bin/rails test test/models/comment_test.rb test/models/comment_concurrency_test.rb test/models/comment_contention_test.rb test/controllers/posts/comments_controller_test.rb
bin/rails test test/system/comments_test.rb
```

The concurrency/contention tests use separate SQLite connections and deliberately disable transactional fixtures for those classes. Run only against the local test database. They prove commit ordering and recoverable writer timeouts. Thread tests also exercise a 1,000-level chain and bounded query counts; this is regression evidence, not an operational capacity guarantee.

The comment system tests save screenshots under `tmp/screenshots/` for desktop, a true emulated 320px viewport, validation errors, and deleted comments. They exercise browser interactions and keyboard posting/replying. The fixture conversation reuses `registered_member` and `other_author`: a member question, another author's reply, and the member's follow-up. Special states are constructed locally in tests.

Static and dependency checks:

```sh
bin/rubocop
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/bundler-audit
bin/importmap audit
```

Healthy output reports no offenses, warnings, or vulnerabilities. Dependency audits may require network access. `bin/ci` runs the repository's broader setup/style/security/test sequence, including test seed replanting.

## Comment behavior and limits

Comments follow post visibility. Authenticated readers may comment and reply; only comment authors may edit or delete. Email attribution is public. Deleted comments retain their text internally, show `[deleted]`, and cannot receive direct replies; their live descendants remain usable. Deleting a post removes all its comments and retained text. On surviving posts, deleted authors appear as `[deleted user]`.

Replies have no product depth limit. Threads are loaded in full and traversed iteratively with preloaded authors/deletion records. Responsive indentation is visually capped; explicit parent links preserve context. Large-discussion sizing, moderation, and dedicated anti-abuse features remain deferred product risks.
