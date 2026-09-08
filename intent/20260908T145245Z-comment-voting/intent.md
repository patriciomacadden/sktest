# Intent: comment voting
Author: Patricio Mac Adden. Timestamp: 2026-09-08T14:52:45Z. Status: accepted.

## Problem
Readers cannot express lightweight support for comments, so useful or popular comments have no visible signal.

## Proposed outcome
Signed-in users can add one upvote to a comment or remove their existing upvote. Everyone can see each comment's total vote count.

## Affected users and systems
Signed-in users who vote, all readers who view comment vote totals, and the application's comment data and user interface.

## Constraints
Voting is a single upvote toggle, not an up/down voting system. Only signed-in users may vote; vote totals are publicly visible.

## Open questions
None identified.

## Decisions
Users may vote on their own comments. Vote totals are displayed even when zero. Votes do not generate notifications or activity entries.
