# Forsetti Local Validator

The local validator is the canonical enforcement entry point for FFAE repository checks and target Forsetti app/module checks.

It may inspect repositories, contracts, project context files, edition profiles, manifests, changed-file evidence, and completion evidence. It must not implement runtime behavior, module activation, service resolution, UI composition, platform storage, networking, hosted orchestration, or local-tool provider behavior.

## Modes

```text
repo
contract
project-context
edition-profile
manifest
dependencies
capabilities
module-isolation
evidence
all
```

Legacy repository-check aliases remain accepted: `files`, `structure`, `json`, `policies`, `policy`, `docs`, `schemas`, `schema`, `scripts`, and `contracts`.

## Parameters

| Parameter | Purpose |
|---|---|
| `-RepoRoot` | Repository root to validate. Defaults to the current directory. |
| `-Mode` | Validation mode. |
| `-ContractPath` | Governing task contract path. |
| `-ProjectContextPath` | Forsetti project context JSON path. |
| `-EditionProfilePath` | Selected edition profile JSON path. |
| `-ChangedFilesPath` | Newline-delimited changed-file evidence path. |
| `-ChangedFiles` / `-ChangedFile` | Inline changed-file evidence. |
| `-ManifestPath` | Forsetti module manifest JSON path. |
| `-OutputJson` | Optional validator result JSON output path. |
| `-Strict` | Treat remediable findings as non-passing. |

## Result Shape

The validator emits `pass`, `request_changes`, or `block`. Findings include:

```text
rule_id
severity
decision
message
evidence
remediation
```

The result shape follows `core/schemas/validator-result.schema.json`.

## Examples

Validate the FFAE repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode repo `
  -Strict
```

Validate a target Forsetti module manifest against the Apple profile:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode manifest `
  -EditionProfilePath .\editions\apple\forsetti-apple-0.1.3.profile.json `
  -ManifestPath .\path\to\ModuleManifest.json `
  -Strict
```

Validate a governed task contract and changed files:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode contract `
  -ContractPath .\contracts\TASK-CONTRACT.md `
  -ChangedFilesPath .\changed-files.txt `
  -Strict
```

## Local-First Boundary

GitHub Actions wrappers may call this validator, but they are optional adapters. Local validation, task contracts, profile selection, manifest evidence, changed-file evidence, and accountable review remain the canonical governance record.
