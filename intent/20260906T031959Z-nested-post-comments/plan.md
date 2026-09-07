# Plan: Nested post comments (from spec.md)
Author: Patricio Mac Adden. Timestamp: 2026-09-06T03:46:58Z. Status: accepted.

Inputs: `intent.md` and `spec.md` in this directory. Complete plan explicitly approved by the product owner in the session before this artifact was written.

## Files that change

- `db/migrate/<timestamp>_create_comments.rb` (new), `db/schema.rb`
- `app/models/comment.rb` (new), `app/models/comment/deletion.rb` (new), `app/models/comment/thread.rb` (new)
- `app/models/post.rb`, `app/models/user.rb`
- `config/routes.rb`, `config/initializers/filter_parameter_logging.rb`
- `app/controllers/posts_controller.rb`, `app/controllers/posts/comments_controller.rb` (new)
- `app/views/posts/show.html.erb`, comment partials and form views under `app/views/posts/comments/` (new)
- `app/assets/stylesheets/application.css`
- `test/fixtures/comments.yml` (new)
- Comment model, controller, concurrency, and system tests (new)
- Existing post/user model and post controller tests
- `README.md` for verification instructions

## Order of work

1. **Establish baseline verification.** Check installed dependencies and run existing Rails/system tests before implementation. Preserve unrelated untracked `.agents/` files.
2. **Introduce comments and deletion records.**
   - Comments store post, nullable author, optional parent, plain-text body, and timestamps.
   - Represent deletion with a unique associated `Comment::Deletion` record, not a boolean. Keep deleted text internally.
   - Add foreign keys, required-field constraints, and ordering indexes.
   - Enforce same-post parents, immutable thread relationships, and non-empty text. Creation cannot reference itself or introduce cycles.
   - Delete all comments and deletion records when their post is deleted. Null author references on user deletion so surviving comments display “[deleted user]”.
3. **Make mutations concurrency-safe.**
   - Put authorization predicates and mutation behavior in models.
   - Serialize reply creation, editing, and deletion using a SQLite-compatible write transaction acquired before checking parent/deletion state. Do not assume SQLite provides row locks.
   - Recheck persisted state within the transaction. Translate expected conflicts into recoverable errors without discarding entered text.
   - Prove both reply-before-deletion and deletion-before-reply outcomes using separate database connections.
4. **Add authenticated comment endpoints.**
   - Nest comment resources under posts, not recursively under parent comments.
   - Scope lookups through the post and enforce author ownership server-side.
   - Accept body and creation-time parent selection only; reject identity/thread tampering.
   - Use normal Rails forms, redirects to comment anchors, and validation responses. Keep CSRF protection.
   - Filter comment text from request logs.
5. **Build the discussion UI.**
   - Add the Comments section beneath post content.
   - Provide top-level, reply, and edit forms, cancellation, and deletion confirmation.
   - Render escaped text with preserved line breaks; disclose public email attribution and internal deletion retention.
   - Show “[deleted]” without attribution or writing controls; keep live descendants replyable.
   - Use iterative thread traversal with preloaded authors/deletion state, avoiding recursive partials and per-comment queries.
   - Initially load the complete discussion. Use capped visual indentation with explicit parent links, without restricting logical depth.
   - Preserve Braun styling. Navigation already owns the orange action, so comment controls remain neutral.
6. **Add focused test data and coverage.**
   - Reuse `registered_member` and `other_author`.
   - Add a small connected fixture conversation: member root, other-author reply, and member follow-up.
   - Keep deletion, orphaned-author, invalid-input, and deep-chain states local to their tests rather than multiplying fixtures.
7. **Verify and document.** Run focused checks after each coherent change, then the full verification below. Inspect desktop/mobile rendering and keyboard journeys. Record results, screenshots, limitations, and any material plan deviations.

## Risks

- SQLite concurrency needs real multi-connection proof; ordinary transactional tests are insufficient.
- User deletion already deletes that user's posts. Those threads disappear; comments on surviving posts retain deleted-user attribution.
- Complete-thread loading has unbounded total memory/rendering cost. This follows the accepted initial scope; pagination or product limits require a new decision.
- Deleted text must not leak through forms, responses, or logs.
- Public emails and indefinite retention remain the explicitly accepted product risks.

Alternatives rejected: recursive rendering, arbitrary depth limits, new threading/authentication dependencies, and a deletion boolean contrary to the Rails guidance.

## Execution topology

Sequential. Schema, lifecycle behavior, controllers, rendering, and tests share interfaces. One writer avoids unnecessary integration risk.

## Proof

- Focused model/controller tests covering specification AC-1–AC-10.
- Deterministic multi-connection tests for deletion/reply ordering.
- Query-count comparison across small and larger discussions.
- An iteratively generated 1,000-level thread proving traversal beyond the visual cap—not a promised capacity limit.
- CSRF-enabled request tests, ownership tampering, cross-post parents, escaped content, retained-text disclosure prevention, and post/user deletion.
- `bin/rails test`
- `bin/rails test:system`
- `bin/rubocop`
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
- `bin/bundler-audit`
- `bin/importmap audit`
- Desktop and 320px browser checks with screenshots, including deep threads, long text, errors, deleted states, and keyboard-only interaction.

No production migrations, deployment, push, or merge. Implementation begins only after this accepted plan is committed and the operator chooses same-session or new-session execution.

## Implementation record

The operator authorized same-session implementation after accepted-plan commit `d3ad444`.

- Migration: `db/migrate/20260906035000_create_comments.rb`. SQLite foreign keys enforce same-post parent references; post cleanup uses bulk deletion, avoiding recursive deletion through the thread.
- Rails 8.1 uses IMMEDIATE transactions for ordinary joinable SQLite transactions. Publishing bypasses the request query cache before checking parent state; edit/deletion reload inside the transaction. Writer timeouts return recoverable errors and preserve submitted text.
- Reply/edit forms and deletion confirmation use ordinary server-rendered pages. Successful mutations include a `comment_id` query parameter and autofocus the matching comment, in addition to the planned fragment; browser verification showed Turbo drops the fragment from form redirects.
- Added `test/models/comment_contention_test.rb` alongside the planned concurrency tests to prove timeout handling. No dependencies, production changes, or product-scope changes were introduced.
- The first existing system-suite baseline had an intermittent Create post navigation failure; its isolated rerun passed before feature implementation. The new browser tests wait for navigation rather than weakening behavior assertions.
- Screenshot checks use actual 320px device emulation because resizing a desktop Chrome window alone was clamped to 500px. An additional Playwright check confirmed a 320px viewport without horizontal overflow.
- Two reproducible implementation defects were fixed without changing their established system/model regression proofs: missing post-submit focus (`test/system/comments_test.rb`, SHA-256 `84c634c294339dbab85020d6e0fe40fb0454875cae62f873e678feca8ef619c0`) and unhandled writer timeout (`test/models/comment_contention_test.rb`, SHA-256 `43a579ca3804036fa7110d750a84aa13682ad37beddb15032297c0aecfb98b4e`). Pre-fix failures and post-fix passes are recorded in the session; proofs were not independently committed.

These are implementation refinements within the accepted approach, not changes to approved requirements or deferred risks.

## Amendment: Turbo Stream mutations

Author: Patricio Mac Adden. Timestamp: 2026-09-07T01:53:30Z. Status: accepted.

The product owner approved replacing the server-rendered page/redirect approach for comment mutations with Turbo Streams. This is a material implementation change but does not alter the accepted product requirements.

- Create, reply, edit, update, and delete respond with Turbo Streams for Turbo requests; HTML requests retain redirect/page fallbacks.
- Successful stream mutations replace the full comments section from its preloaded iterative thread, placing the new/changed/deleted comment in its correct threaded order without a full-page visit. The target comment receives autofocus to preserve orientation.
- Invalid and contention results replace only the relevant form, retaining entered text and its accessible errors.
- Add stable form and discussion-section DOM IDs, Turbo Stream templates, controller/request tests for stream MIME and targets, and browser tests proving each mutation happens without full-page navigation.
- Full-page rendering remains iterative with preloaded authors/deletion records. No new JavaScript dependency or scope extension is allowed.

Final verification:
- `bin/rails test`: 64 runs, 361 assertions, 0 failures/errors/skips.
- `bin/rails test:system`: 11 runs, 83 assertions, 0 failures/errors/skips.
- `bin/rubocop`: 67 files, no offenses.
- `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`: no warnings or errors.
- `bin/bundler-audit` and `bin/importmap audit`: no vulnerabilities found.
- `git diff --check`: clean.
- Local log: `tmp/comments-verification.log`. Screenshots: `tmp/screenshots/comments-desktop.png`, `comments-mobile.png`, `comments-deleted.png`, `comments-errors.png`, and `comments-playwright-mobile.png` in that directory. Rendered desktop/mobile/deletion/error screenshots were visually inspected; Playwright reported width 320, no horizontal overflow, and no console warnings/errors.
- The new development migration was applied, rolled back, and reapplied after confirming no development comments existed. No production migration was run.

## Amendment: Discussion presentation

Author: Patricio Mac Adden. Timestamp: 2026-09-07T02:16:59Z. Status: accepted.

The product owner approved removing the visible Comments heading and moving Turbo Stream success/error messages to the existing global flash area. The no-op Cancel link is removed from the top-level composer; reply/edit composers retain a Cancel control that dismisses their contextual form.

- Add a stable global flash target to the layout and stream-replace it with the correct `role=status` or `role=alert` message alongside the discussion/form update.
- Remove the discussion heading while retaining semantic structure and accessible composer labels.
- Render Cancel only for persisted or reply composers; it returns the discussion to the default composer state through Turbo Streams.
- Update request and browser tests to prove flash placement, no heading, and contextual cancellation.

Turbo Stream amendment verification:
- `bin/rails test test/controllers/posts/comments_controller_test.rb test/system/comments_test.rb`: 13 runs, 156 assertions, 0 failures/errors/skips.
- `bin/rails test`: 65 runs, 382 assertions, 0 failures/errors/skips.
- `bin/rubocop`: 67 files, no offenses.
- Controller tests assert stream MIME, discussion/form replacement targets, no redirect on create/update/delete, and inline validation retention. System tests assert reply/edit/delete stream interactions retain the post path rather than visiting form/confirmation pages.

## Amendment: Inline reply composer

Author: Patricio Mac Adden. Timestamp: 2026-09-07T02:24:00Z. Status: accepted.

The product owner approved removing composer disclosure text and replacing the top-of-discussion reply form with an inline child-level composer beneath the selected parent.

- Remove the composer disclosure and update tests/spec references accordingly.
- In the preloaded iterative thread render, insert the selected reply form immediately after its live parent with child-level visual indentation and explicit parent context.
- Keep Turbo Stream create/reply/error flows; reply validation replaces the inline form in place, and Cancel restores the parent’s action area/default discussion view.
- Verify desktop and 320px reply composition, semantic/keyboard behavior, and that the form does not appear at the top while replying.

Discussion-presentation amendment verification:
- `bin/rails test test/controllers/posts/comments_controller_test.rb test/system/comments_test.rb`: 13 runs, 164 assertions, 0 failures/errors/skips.
- `bin/rails test`: 65 runs, 388 assertions, 0 failures/errors/skips.
- `bin/rails test test/system/posts_test.rb:18`: vote regression passed (1 run, 4 assertions); this specifically verifies the post show action did not respond with a comments-only Turbo Stream after a vote redirect.
- `bin/rails test:system` had one pre-existing, intermittent post-form assertion failure (`PostsTest#test_author_sees_validation_errors`, title value not retained in the full-suite run). Its isolated rerun passed (1 run, 7 assertions). Comments system tests passed in the focused run.
- `bin/rubocop` and Brakeman passed with no offenses/warnings; `git diff --check` passed.

## Amendment: Reply composer context copy

Author: Patricio Mac Adden. Timestamp: 2026-09-07T03:06:04Z. Status: accepted.

The product owner approved removing the redundant parent-link/copy from the inline reply composer. Child-level placement is the sole relationship cue in that composer.

- Remove the reply-composer parent link/copy and its hidden-field-adjacent presentation markup; retain the parent ID field and server-side parent validation.
- Update focused controller/system assertions and rerun the relevant checks.

Inline reply-composer amendment verification:
- `bin/rails test test/controllers/posts/comments_controller_test.rb test/system/comments_test.rb`: 13 runs, 165 assertions, 0 failures/errors/skips.
- `bin/rubocop`: 67 files, no offenses. The system test proves Reply leaves the post path intact, removes the top-level composer, and renders the reply form immediately after its parent in a child-indented thread item.

## Amendment: Native deletion confirmation

Author: Patricio Mac Adden. Timestamp: 2026-09-07T03:14:26Z. Status: accepted.

The product owner approved replacing the custom HTML deletion confirmation with Turbo’s native confirmation prompt. Confirming issues the existing Turbo Stream deletion; canceling sends no request and leaves the discussion unchanged.

- Remove the custom confirmation page/stream rendering and its route/action support.
- Give the Delete link `data-turbo-method=delete`, `data-turbo-stream=true`, and a concise native confirmation message stating that replies remain and text is retained internally.
- Update controller/system checks to accept/dismiss the browser confirmation and verify no custom confirmation markup/page is rendered.

Reply-context-copy amendment verification:
- `bin/rails test test/controllers/posts/comments_controller_test.rb`: 10 runs, 123 assertions, 0 failures/errors/skips.
- The focused deep-thread system check (`bin/rails test test/system/comments_test.rb:81`) passed in isolation (1 run, 6 assertions) after an intermittent full-focused-suite anchor assertion; `bin/rubocop` passed with 67 files and no offenses.
