# GitHub Actions Adapter

The GitHub Actions adapter is an optional host integration surface. It translates GitHub event context into repository-local Forsetti validation inputs and keeps hosted runner behavior outside the portable core.

## Boundary

This adapter may handle:

- pull request, push, and manual workflow event metadata
- changed-file discovery from GitHub refs
- workflow environment variables
- GitHub check output formatting
- invocation of `core/validator/forsetti_validate.ps1`
- hosted documentation, changelog, version, and wiki maintenance jobs

This adapter must not:

- define canonical compliance rules
- replace task contracts
- change role authority
- make GitHub Actions required for Forsetti compliance
- embed platform-specific behavior into `core/`

Canonical compliance behavior remains in repository policy documents, machine-readable policy manifests, and the local validator.

## Workflow Wrappers

Repository workflows under `.github/workflows/` are wrappers. They preserve workflow names, triggers, job identifiers, and check names, then delegate implementation to scripts under `adapters/github-actions/workflows/`.

| Workflow | Adapter script |
|---|---|
| Contributor Guard | `workflows/check-contributor-attribution.ps1` |
| Changelog Validation | `workflows/check-changelog-entry.ps1` |
| PR Policy Check | `workflows/check-pr-template.ps1` |
| Protected Path Check | `workflows/check-protected-paths.ps1` |
| Version Guard | `workflows/check-version-impact.ps1` |
| Release Preparation | `workflows/check-release-readiness.ps1` |
| Changelog Agent | `workflows/update-changelog-entry.ps1` |
| Docs Sync Agent | `workflows/sync-documentation.ps1` |
| Version Agent | `workflows/assign-version-release.ps1` |
| Wiki Designer Agent | `workflows/sync-wiki-pages.ps1` |

Shared adapter functions live in `workflows/github-context.ps1`. Local validator invocation is centralized in `workflows/invoke-local-validation.ps1`.

## Changed-File Handling

The adapter computes changed files with local `git diff` against pull request base and head SHAs or push before and after SHAs. It writes newline-delimited changed-file evidence to runner temp storage for adapter checks that need reproducible file lists.

Hosted checks do not depend on `tj-actions/changed-files`. Protected-path and approval checks read `core/policies/repo-boundaries.json` instead of maintaining hard-coded path arrays in workflow YAML.

## Hosted Dependencies

The adapter expects the standard GitHub Actions Ubuntu runner toolchain:

- `actions/checkout`
- Git
- PowerShell 7 through `pwsh`
- GitHub CLI for release publication workflows

These are hosted adapter dependencies only. The portable Forsetti core does not depend on GitHub Actions, hosted runners, containers, browser automation, MCP servers, or provider services.

## Validation Flow

```text
GitHub event -> adapter context -> changed-file evidence -> adapter script -> local policy manifest or local validator -> GitHub check output
```

The local validator remains the repository-local validation entry point. Hosted workflows may call it, but successful hosted execution is not a substitute for required contract evidence in a governed task.
