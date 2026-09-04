# Intent: Post voting
Author: Patricio Mac Adden. Timestamp: 2026-09-04T19:11:25Z. Status: accepted.

## Problem
Posts cannot currently receive user votes, limiting the application's ability to surface popular posts.

## Proposed outcome
Authenticated users can cast one vote per post and remove it, including voting again after removal. The public post list surfaces posts with the most votes first, and vote counts are displayed on post list and show pages.

## Affected users and systems
Authenticated users, public post list and show pages, and web posts in this application.

## Constraints
Scope is limited to web posts. A user may have at most one active vote per post. The public post list must be ordered by vote count, highest first, and vote counts must be shown on list and show pages.

## Open questions
Any moderation rules for voting.
