# Intent: Authenticated post publishing
Author: Patricio Mac Adden. Timestamp: 2026-09-03T16:43:18Z. Status: accepted.

## Problem
Authenticated users need a way to publish and manage posts, while people who are not signed in need a way to discover and read published posts.

## Proposed outcome
Authenticated users can list, create, edit, and delete posts they authored. Posts have a title and may include a URL and/or body. Anyone can browse a public post list with standard page-based pagination and view an individual post. Authenticated users' post lists also use standard page-based pagination.

## Affected users and systems
Authenticated users who author posts; public visitors who browse and read posts; the existing application authentication and post functionality.

## Constraints
Use the existing authentication and application stack. Administrative or moderation capabilities, drafts, comments, media, and tags are out of scope.

## Open questions
None identified.
