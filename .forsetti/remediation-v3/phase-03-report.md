# Phase 03 Report: Local Validator CLI

## Phase Result

**Status:** pass

Phase 03 added a repository-local validator CLI and validation result schema. The core validator runs locally on this Windows host and the root wrappers delegate to it without requiring Docker, WSL, hosted services, GitHub Actions, GitHub CLI, or network runtime access.

## Task and Scope

**Task contract:** `contracts/FAE-TASK-2026-05-08-006-local-validator-cli.md`

**Change class:** feature

**Approval class:** governance-class

**Release impact:** minor

**Branch:** `fix/v3-local-validator-cli`

## Files Changed

- `.forsetti/remediation-v3/phase-03-report.md`
- `.forsetti/remediation-v3/phase-03-validator-result.json`
- `README.md`
- `changelog/CHANGELOG.md`
- `contracts/FAE-TASK-2026-05-08-006-local-validator-cli.md`
- `core/README.md`
- `core/schemas/validator-result.schema.json`
- `core/validator/README.md`
- `core/validator/forsetti_validate.ps1`
- `scripts/validate-repo.ps1`
- `scripts/validate-repo.sh`
- `wiki/Changelog.md`
- `wiki/Home.md`
- `wiki/Overview.md`

All changed files are listed in the task contract scope.

## Required Outputs

- `core/validator/forsetti_validate.ps1`: delivered.
- `core/validator/README.md`: delivered.
- `core/schemas/validator-result.schema.json`: delivered.
- `scripts/validate-repo.ps1`: delivered as a wrapper delegated to the core validator.
- `scripts/validate-repo.sh`: delivered as a wrapper delegated to the core validator when a local PowerShell host is available.
- `.forsetti/remediation-v3/phase-03-report.md`: delivered.
- `.forsetti/remediation-v3/phase-03-validator-result.json`: delivered.

## Validator Behavior

The core validator supports these modes: `all`, `files`, `structure`, `json`, `policies`, `policy`, `docs`, `schemas`, `schema`, and `scripts`.

The core validator emits `pass`, `request_changes`, or `block` statuses and maps them to exit codes `0`, `1`, and `2`.

Root wrappers preserve the prior no-argument compatibility posture by running non-strict validation unless `-Strict` is supplied explicitly. Direct Phase 03 evidence uses the core validator with `-Strict`.

## Validation Results

| Check | Command | Result |
|---|---|---|
| Core validator, Windows PowerShell strict | `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict` | pass, 15 findings passed, 0 warnings, 0 errors |
| Core validator, PowerShell 7 strict | `pwsh -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict` | pass, 15 findings passed, 0 warnings, 0 errors |
| Core validator JSON output | `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict -OutputJson .\.forsetti\remediation-v3\phase-03-validator-result.json` | pass, JSON evidence written |
| Changed JSON parse with Python | `py -m json.tool .\core\schemas\validator-result.schema.json $null`; `py -m json.tool .\.forsetti\remediation-v3\phase-03-validator-result.json $null` | pass |
| Changed JSON parse with PowerShell | `ConvertFrom-Json` over both changed JSON files | pass |
| JSON Schema validation | Python `jsonschema` Draft 2020-12 validation of `phase-03-validator-result.json` against `core/schemas/validator-result.schema.json` | pass |
| PowerShell wrapper no-arg | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1` | pass, Strict false |
| PowerShell wrapper strict | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1 -Strict` | pass, Strict true |
| PowerShell 7 wrapper no-arg | `pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1` | pass, Strict false |
| Visual Studio Developer Command wrapper | `VsDevCmd.bat -no_logo` followed by `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1` | pass, Strict false |
| Git Bash wrapper no-arg | `C:\Program Files\Git\bin\bash.exe .\scripts\validate-repo.sh` | pass, Strict false |
| Git Bash wrapper mode argument | `C:\Program Files\Git\bin\bash.exe .\scripts\validate-repo.sh -Mode all` | pass, Strict false |
| Git Bash wrapper strict argument | `C:\Program Files\Git\bin\bash.exe .\scripts\validate-repo.sh -Mode all -Strict` | pass, Strict true |
| Runtime dependency scan | `rg -n "Invoke-WebRequest|Invoke-RestMethod|\bgh\b|\bwsl\b|\bdocker\b|provider|MCP|https?://" core\validator scripts\validate-repo.ps1 scripts\validate-repo.sh` | pass, no matches |
| Attribution-style source scan | local scan over changed files for prohibited attribution phrases | pass, no matches |
| Whitespace check | `git diff --check` | pass, exit code 0 |
| Scope check | changed files compared to task contract scope | pass |

The current validator evidence file reports `summary.status = pass`, `summary.passed = 15`, `summary.warnings = 0`, and `summary.errors = 0`.

## Tooling Used

- Filesystem editing through local patch application.
- Local shell execution through Windows PowerShell.
- PowerShell 7 (`pwsh`) for cross-host validation.
- Visual Studio Developer Command environment for IDE-backed command validation.
- Visual Studio Python launcher (`py`) for JSON parsing and schema validation.
- Local Python `jsonschema` package installed in the user Python environment to enable Draft 2020-12 schema validation.
- Git Bash for shell wrapper validation.
- Local Git for diff, scope, and status checks.
- `rg` for source scans.

## Local-First and Fallback Decisions

- Primary implementation path was Windows PowerShell native validation.
- PowerShell 7 was used as a second local host.
- Visual Studio Python was used for JSON validation instead of relying on unavailable `python3`.
- Git Bash was used for shell wrapper validation instead of WSL.
- Docker was not used or required.
- No hosted runtime fallback, GitHub Actions fallback, or nonlocal provider fallback was used.
- No runtime dependency on MCP servers, subagents, GitHub CLI, GitHub Actions, Docker, WSL, network access, or hosted providers was introduced.

## Advisory Reviews

| Reviewer | Initial Outcome | Finding | Resolution | Final Outcome |
|---|---|---|---|---|
| api-designer | request_changes | Bash wrapper strictness was inconsistent; Phase report was missing. | Wrapper compatibility was corrected; this report was added. | pass for wrapper strictness; report created for final evidence |
| backend-developer | request_changes | Bash wrapper strictness and missing versioning/changelog policy mirror checks. | Wrapper compatibility corrected; versioning and changelog mirror parity checks added. | pass |
| test-writer | block | Phase report was missing, so required output evidence was incomplete. | This report was added and re-reviewed. | pass |
| build-error-resolver | pass | Previous repo-root, wrapper, stale workflow, and shell blockers were resolved. | No action required. | pass |
| performance-engineer | request_changes | JSON traversal filtered excluded directories after recursion; result array copied with `+=`. | JSON traversal now prunes `.git` and `node_modules`; result generation uses direct array conversion. | pass |
| code-reviewer | request_changes | Phase report missing; root wrapper no-arg strictness changed prior behavior; report initially claimed Git actions not yet performed. | This report was added; root wrappers now preserve non-strict no-arg behavior and expose explicit strict mode; report claim corrected. | pass |

## Documentation Status

Documentation was updated in `README.md`, `core/README.md`, `core/validator/README.md`, `wiki/Overview.md`, `wiki/Home.md`, `changelog/CHANGELOG.md`, and `wiki/Changelog.md`.

No glossary update was required because no new governed term was introduced.

## Known Issues

None for Phase 03.

## Acceptance Gate Status

Required outputs are present, local validation passes, JSON output parses and validates against the schema, wrappers delegate to the core validator, advisory findings have been reconciled, and all changed files are within the task contract scope.
