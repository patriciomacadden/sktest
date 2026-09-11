# Intent: authenticated comment editing
Author: Patricio Mac Adden. Timestamp: 2026-09-11T21:36:01Z. Status: accepted.

## Problem
Comment authors cannot correct or improve an active comment after posting it, making ordinary conversation mistakes permanent.

## Proposed outcome
An authenticated comment author can edit their own active comment and readers can see that the comment was edited.

## Affected users and systems
Authenticated comment authors, comment readers, and the post-detail comment thread.

## Constraints
- Only the comment author may edit a comment.
- Only active comments may be edited; deleted comments remain non-editable.
- Editing replaces the comment body without retaining a revision history.
- Edited comments display an edited indicator.

## Open questions
None identified.
