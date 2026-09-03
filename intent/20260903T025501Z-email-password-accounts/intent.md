# Intent: Email-password accounts
Author: Patricio Mac Adden. Timestamp: 2026-09-03T02:55:01Z. Status: accepted.

## Problem
The application has no user accounts or authentication today, so people cannot sign in to an individual account or see personalized account state.

## Proposed outcome
People can create and sign in to accounts with an email address and password. The homepage distinguishes account state: signed-in people see a message identifying the signed-in account and a sign-out action; signed-out people see sign-up and sign-in actions.

## Affected users and systems
Application users and the Rails application homepage and account access flows.

## Constraints
Keep the first release minimal. Roles, administration, and external identity providers are out of scope.

## Open questions
None identified.
