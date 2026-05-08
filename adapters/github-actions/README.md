# GitHub Actions Adapter

The GitHub Actions adapter is an optional host integration surface. It translates GitHub event context into portable Forsetti validation inputs.

## Purpose

GitHub Actions may run Forsetti checks for repositories hosted on GitHub. The adapter exists so GitHub-specific behavior can stay outside the portable core.

## Boundary

This adapter may handle:

- pull request and push event metadata
- changed-file discovery from GitHub refs
- workflow environment variables
- status reporting back to GitHub checks
- invocation of the portable validator once that validator exists

This adapter must not:

- define canonical compliance rules
- replace task contracts
- change role authority
- make GitHub Actions required for Forsetti compliance
- embed platform-specific behavior into `core/`

## Expected Flow

```text
GitHub event -> adapter context -> ValidationRequest -> core validator -> ValidationResult -> GitHub check output
```

## Phase 01 Status

This directory is a scaffold. Workflow conversion and adapter implementation are reserved for a later remediation phase.
