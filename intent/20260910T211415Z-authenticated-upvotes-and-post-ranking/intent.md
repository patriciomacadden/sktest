# Intent: authenticated upvotes and post ranking
Author: Patricio Mac Adden. Timestamp: 2026-09-10T21:14:15Z. Status: accepted.

## Problem
Authenticated users cannot express approval of posts or comments. Posts are not ordered to surface the content receiving the most current community support.

## Proposed outcome
Authenticated users can add and remove a single upvote on posts and comments, and can see their current upvote state and vote totals. Post listings provide a `hot` scope that orders posts by the descending count of upvotes received in the previous 24 hours, and a `new` scope that orders posts by creation time.

## Affected users and systems
Authenticated users, posts, comments, upvote data, and post-list ordering are affected.

## Constraints
Only authenticated users may add or remove upvotes. Upvotes apply to both posts and comments, with at most one upvote per user per post and per comment. The `hot` scope counts upvotes received during the previous 24 hours.

## Open questions
None identified.
