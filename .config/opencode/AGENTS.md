# Global Agent Instructions

## Workflow Constraints

- **Do not commit without explicit approval.** After completing a unit of work, present the changes for code review. Only commit after the user has reviewed and given the go-ahead.
- **Create plans for complex tasks.** Before starting a multi-step piece of work, write a dated plan file in `docs/plans/active/` using the naming convention `YYYY-MM-DD-<descriptive-name>.md`. Plans should break the work into concrete substeps, document key architectural decisions, and specify the order of work. Move completed plans to `docs/plans/completed/`.
- **Record learnings immediately.** Whenever you discover a non-obvious technical gotcha, compatibility issue, or workaround during development, add it to `docs/LEARNINGS.md` under the appropriate section before moving on. Do not wait until the end of a task — capture the learning as soon as you encounter it.
- **Use Architecture Decision Records (ADRs).** When making significant decisions about code structure, technology choices, or architectural patterns, capture them as ADRs in `docs/adrs/` using the naming convention `NNN-<descriptive-name>.md` (e.g. `001-user-persistence-backend.md`). Each ADR must include a **Status** field with one of: `Draft`, `Proposed`, `Accepted`, or `Deprecated`.
- **Run tests before and after changes.** Before modifying code, run the project's test suite to establish a passing baseline. After making changes, run tests again to verify nothing broke. Do not present work for review with failing tests unless the failures are pre-existing.
- **Never commit secrets.** Do not commit API keys, credentials, tokens, `.env` files, or private keys. If you encounter secrets in the codebase, flag them to the user immediately.
