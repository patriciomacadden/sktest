# Intent: Community posts, comments, and voting
Author: Patricio Mac Adden. Timestamp: 2026-09-09T14:19:31Z. Status: accepted.

## Problem
Visitors currently have no shared place to discover posts published by registered users or participate in discussion around them.

## Proposed outcome
Provide an application where anyone can browse posts, post detail pages, and comment threads. Visitors can register and authenticate with email and password to publish posts, participate in every post’s discussion, vote on posts and comments, and add nested comments.

## Affected users and systems
Public visitors, registered/authenticated users, post content (title, optional URL, and optional body), comments, votes, and authentication.

## Constraints
Post titles are required; URLs and bodies are optional. Public visitors can view post lists, post detail pages, and comment threads. Authenticated users can comment on and vote on every post, and can edit or delete their own posts and comments. Votes are upvotes only, limited to one per user per post or comment, and their totals are displayed. Comments support unlimited nesting and are displayed inside their parent comment with indentation. Authentication uses email and password and includes password reset. No moderation or additional content validation is in scope yet.

## Open questions
None identified.
