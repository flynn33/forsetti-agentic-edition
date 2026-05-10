# Forsetti Local Validator

The local validator is the portable repository validation entry point for Forsetti Agentic Edition.

## Command

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict
```

To write machine-readable evidence:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict -OutputJson .\.forsetti\remediation-v3\phase-03-validator-result.json
```

To enforce a task contract against an explicit changed-file set:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode contract `
  -ContractPath .\contracts\FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md `
  -ChangedFilesPath .\.forsetti\remediation-v3\changed-files.txt `
  -Strict `
  -OutputJson .\.forsetti\remediation-v3\phase-04-contract-result.json
```

## Parameters

| Parameter | Purpose |
|---|---|
| `-RepoRoot` | Repository root to validate. Defaults to the current directory. |
| `-Mode` | Validation group: `all`, `files`, `structure`, `json`, `policies`, `policy`, `docs`, `schemas`, `schema`, `scripts`, `contract`, or `contracts`. |
| `-Strict` | Treat warnings as `request_changes`. Errors always produce `block`. |
| `-OutputJson` | Optional path for the validator result JSON. |
| `-ContractPath` | Governing task contract for contract enforcement mode. |
| `-ChangedFile` | Repeatable explicit changed-file path. Alias: `-ChangedFiles`. |
| `-ChangedFilesPath` | Newline-delimited changed-file input. This is the preferred reproducible input for pull request validation. |

## Checks

The validator implements repository-local checks only:

- required file and directory presence
- non-trivial content checks for required files
- workflow file presence and non-empty checks
- JSON parsing
- core/root policy mirror parity
- canonical compliance ID completeness
- stale policy path scan
- documentation sync path existence
- schema presence and basic schema structure
- root validation wrapper delegation
- contract enforcement infrastructure presence
- task contract required field checks
- changed-file scope enforcement against the governing task contract
- protected-path approval enforcement using `core/policies/repo-boundaries.json`
- role-limited path enforcement using `core/policies/repo-boundaries.json`
- required output and evidence artifact checks
- documentation sync checks for changed canonical sources using `core/policies/docs-sync-rules.json`
- changelog obligation checks for required fields, migration guidance, affected consumers, Unreleased placement, and version consistency

`-Mode all` checks contract infrastructure but does not require a task contract unless `-ContractPath` is supplied. `-Mode contract` and `-Mode contracts` require `-ContractPath`.

Workflow adapter conversion and platform overlay validation are reserved for later phases.

## Result Model

The validator emits a `ValidationResult` object matching `core/schemas/validator-result.schema.json`. Findings include `rule_id` for canonical compliance rules and may include `policy_rule_id`, `condition_id`, and `gate_id` when a machine-readable policy manifest supplies the local enforcement metadata.

The result status is deterministic:

- `pass` when no warning or error findings exist
- `request_changes` when `-Strict` is set and warning findings exist
- `block` when error findings exist

Exit codes map to those statuses:

- `0` for `pass`
- `1` for `request_changes`
- `2` for `block`

Root scripts in `scripts/` are wrappers around this validator and must not redefine canonical policy logic.
