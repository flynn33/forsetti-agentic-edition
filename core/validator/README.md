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

## Parameters

| Parameter | Purpose |
|---|---|
| `-RepoRoot` | Repository root to validate. Defaults to the current directory. |
| `-Mode` | Validation group: `all`, `files`, `structure`, `json`, `policies`, `policy`, `docs`, `schemas`, `schema`, or `scripts`. |
| `-Strict` | Treat warnings as `request_changes`. Errors always produce `block`. |
| `-OutputJson` | Optional path for the validator result JSON. |

## Checks

Phase 03 implements repository-local checks only:

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

Task contract enforcement, changed-file scope validation, protected-path approval checks, workflow adapter conversion, and platform overlay validation are reserved for later phases.

## Result Model

The validator emits a `ValidationResult` object matching `core/schemas/validator-result.schema.json`.

The result status is deterministic:

- `pass` when no warning or error findings exist
- `request_changes` when `-Strict` is set and warning findings exist
- `block` when error findings exist

Exit codes map to those statuses:

- `0` for `pass`
- `1` for `request_changes`
- `2` for `block`

Root scripts in `scripts/` are wrappers around this validator and must not redefine canonical policy logic.
