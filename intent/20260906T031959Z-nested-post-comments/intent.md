# Intent: Nested post comments
Author: Patricio Mac Adden. Timestamp: 2026-09-06T03:19:59Z. Status: accepted.

## Problem
Users cannot currently discuss posts through comments or respond directly to other comments, limiting conversation around a post.

## Proposed outcome
Authenticated users can comment on posts they can view and reply to other comments with unlimited reply depth. Users can edit and delete their own comments. Anyone who can view a post can read its comments.

## Affected users and systems
Post readers, authenticated commenters, and the application's post views, authentication, and comment data.

## Constraints
Writing comments and replies requires authentication. Users may edit and delete only their own comments. Comment visibility follows post visibility. Reply depth must not have a fixed limit.

Deleted comments display as “[deleted]” and cannot receive new replies; existing replies remain intact. Nested comments, including deeply nested comments, are presented indented.

No product-level restrictions on comment content, formatting, or length are requested for now. Moderation, reporting, and anti-abuse features are out of scope for now.

## Open questions
None identified.
