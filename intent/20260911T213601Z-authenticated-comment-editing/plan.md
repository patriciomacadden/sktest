# Plan: authenticated comment editing (from accepted `spec.md`)
Author: Patricio Mac Adden. Timestamp: 2026-09-12T02:45:37Z. Status: accepted.

## Files that change

`db/migrate/<timestamp>_add_edited_at_to_comments.rb` (new), `db/schema.rb`, `app/models/comment.rb`, `app/controllers/comments_controller.rb`, `config/routes.rb`, `app/views/comments/_comment.html.erb`, `app/views/comments/_form.html.erb`, `test/models/comment_test.rb`, `test/controllers/comments_controller_test.rb`.

## Order of work

1. Generate the required migration with `bin/rails generate migration AddEditedAtToComments edited_at:datetime`, then apply it with `bin/rails db:migrate`. A nullable `edited_at` explicitly records an edit without relying on unrelated lifecycle timestamp behavior. A model or controller generator is inapplicable because `Comment` and `CommentsController` already exist; their conventional CRUD extensions and partials will be modified in place.
2. Add comment-domain predicates/behavior for editability and edited presentation. A comment is edited when `edited_at` is present; successful body updates set it to the current time. Preserve existing ownership, active/deleted, parent, and creation-time semantics.
3. Add conventional nested `edit` and `update` routes and controller actions. Scope lookup through the post; require the existing authenticated session; enforce active-author authorization server-side; render validation errors from the inline editor without changing the comment.
4. Extend the existing comment partial and form partial for the approved inline flow using Turbo Frames: each comment has a stable frame target; the active author’s “Edit” link loads the labeled textarea into that frame; “Save changes” returns the updated rendered comment into the same frame; and “Cancel” restores the rendered comment without a body update. Validation failures re-render the inline form in that frame with retained input. `(edited)` appears immediately after the displayed creation date only when `edited_at` is present. Keep plain-text rendering; do not add Turbo Streams, ActionCable, Stimulus, or client-side state.
5. Extend the existing fixture cast rather than creating a new fixture persona: `active_root` remains the ordinary editable authored comment, `active_reply` remains a non-owner comment, and `deleted_root` remains the deleted edge case. Set `edited_at` inline in tests for rare pre-edited rendering; do not add a one-off YAML fixture.
6. Add model and integration coverage for editability, successful owner update and timestamping, inline edit UI/indicator placement, blank-body failure retention, unauthenticated and non-owner update denial, and deleted-comment edit denial. Run focused tests while changing each layer, then the repository CI test command.

## Risks

- `edited_at` adds one nullable column and is intentionally not shown to readers; the UI only shows `(edited)`. It prevents unrelated updates or soft deletion from being misclassified as edits.
- Turbo Frame responses must use the correct stable comment-frame target so inline validation failures and saves preserve submitted textarea input, nested replies, and all unaffected comments.
- Authorization must be evaluated on the server after finding the comment through its post; visibility of an Edit control is not sufficient.
- Turbo Frames must confine edit navigation and form responses to the active comment frame so an in-progress editor is not replaced by a page-level navigation. This plan intentionally avoids broadcasts, page morphs, and custom client-side state.

## Execution topology

- **Mode:** Sequential
- **Workstreams:** None
- **Shared boundaries:** The comment model, controller, routes, and shared comment/form partials form one request/rendering flow; the Turbo Frame identifier is a shared controller/view contract, and the migration and schema must land before tests relying on `edited_at`.
- **Integration order:** Generate and migrate the schema, implement domain behavior and routes/controller, render the Turbo Frame inline flow, then add and run model/controller coverage.

## Proof

- `bin/rails test test/models/comment_test.rb`
- `bin/rails test test/controllers/comments_controller_test.rb` (including Turbo Frame edit, validation, save, and cancel responses)
- `bin/rails db:test:prepare test` (repository CI test command)
- Browser/system-style verification of a signed-in author editing an active comment inline, confirming `(edited)` appears immediately after its date; verify a deleted comment and non-owner have no usable editing path. If local browser setup is unavailable, report that limitation and retain controller-render assertions as the strongest available substitute.
