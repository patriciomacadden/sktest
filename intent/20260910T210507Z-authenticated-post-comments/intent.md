# Intent: authenticated post comments
Author: Patricio Mac Adden. Timestamp: 2026-09-10T21:05:07Z. Status: accepted.

## Problem
Authenticated users cannot currently discuss posts or respond directly to other users' comments, limiting conversation around published content.

## Proposed outcome
Authenticated users can add comments to posts and reply to comments made by other users.

## Affected users and systems
Authenticated users, posts, and the application's comment and reply experience.

## Constraints
- Only authenticated users may create comments or replies.
- Replies may be nested without a depth limit.
- Users may delete only their own comments. Deletion must retain the original comment and its replies, display the deleted comment as `[deleted]`, and prevent any new replies to it.
- Display comments oldest first, with replies indented within their parent comment.

## Open questions
None identified.
