# Intent: Authenticated post creation
Author: Patricio Mac Adden. Timestamp: 2026-09-10T20:52:37Z. Status: accepted.

## Problem
Authenticated users cannot currently publish and manage posts, leaving the application without a shared post feed.

## Proposed outcome
Authenticated users can create posts with a required title and optional URL and body. The homepage presents a list of posts from all authenticated users, and each author can edit or delete only their own posts.

## Affected users and systems
Authenticated application users, the homepage, and post persistence and authorization.

## Constraints
Posts must have a required string title, optional string URL, and optional text body. The post list includes posts created by every authenticated user. Editing and deletion are limited to the post's creator.

## Open questions
None identified.
