# Intent: Apply the Braun design system across the application
Author: Patricio Mac Adden. Timestamp: 2026-09-04T16:04:17Z. Status: accepted.

## Problem
The application's pages do not yet consistently reflect the visual system defined in `DESIGN.md`, leaving the public posts experience, authentication flows, password flows, and post-management screens without a unified industrial-design presentation.

## Proposed outcome
All existing browser-facing application pages use a coherent Braun design system: a disciplined concrete-grey grid, Inter and JetBrains Mono typography, and a single utility-orange interaction accent.

## Affected users and systems
Visitors viewing public posts; users registering, signing in, resetting passwords, and managing posts; Rails views, layouts, and application stylesheets.

## Constraints
Follow `DESIGN.md`: use the specified palette, typography, spacing, and low-radius components; do not introduce gradients or alternate accent colors; reserve the utility-orange accent for one action per screen. Email and PWA pages are out of scope.

## Open questions
How strictly existing functionality and copy must be preserved while applying the visual system.
