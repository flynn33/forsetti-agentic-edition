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
consumer
```

Legacy repository-check aliases remain accepted: `files`, `structure`, `json`, `policies`, `policy`, `docs`, `schemas`, `schema`, `scripts`, and `contracts`.

## Parameters

| Parameter | Purpose |
|---|---|
| `-RepoRoot` | Repository root to validate. Defaults to the current directory. |
| `-SDKRoot` | Optional external toolkit root; packaged execution verifies its complete SDK inventory. |
| `-BundleRoot` | Optional immutable source bundle root; installed SDKs require their own verified `bundle/`. |
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
pwsh -NoProfile -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode repo `
  -Strict
```

Validate a target Forsetti module manifest against the Apple profile:

```powershell
pwsh -NoProfile -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode manifest `
  -EditionProfilePath .\editions\apple\forsetti-apple-0.1.5.profile.json `
  -ManifestPath .\path\to\ModuleManifest.json `
  -Strict
```

Validate a governed task contract and changed files:

```powershell
pwsh -NoProfile -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode contract `
  -ContractPath .\contracts\TASK-CONTRACT.md `
  -ChangedFilesPath .\changed-files.txt `
  -Strict
```

## Local-First Boundary

GitHub Actions wrappers may call this validator, but they are optional adapters. Local validation, task contracts, profile selection, manifest evidence, changed-file evidence, and accountable review remain the canonical governance record.

## External consumer validation

The SDK requires PowerShell 7.4 or newer; release tests ran with PowerShell 7.6.6 on macOS. Use its `Tools/Validate-Consumer.ps1` entry point with a separate target `-RepoRoot`. The default `consumer` mode combines contract/scope, project context/profile, manifest, dependency, capability, module isolation, and changed-file evidence checks. It does not run maintainer `repo` or `all` checks. The wrapper verifies the exact SDK/bundle inventories and target selection/locks before invoking target checks.

The SDK root owns executable helpers and canonical schemas under `core/`; the bundle root owns trusted edition profiles and machine-readable policy data. Target context, manifests, contracts, changed files, and optional JSON reports belong to the target repository. Relative `edition_profile` paths resolve against trusted edition resources, never a consumer-provided policy copy. Relative target inputs resolve against `RepoRoot`.

For a module-bearing task, provide the target manifest, authorized contract, `.forsetti/project-context.json`, and real target-relative changed-file evidence. JSON reports must remain in the target, cannot replace metadata or application inputs, and may replace only an existing validator report. Failed integrity or lock checks return non-success without repinning records. Static pattern inspection and input checks do not establish application runtime correctness or independent approval; hand the evidence to a separate Validator and perform the native verification required by the selected profile.

Source-maintainer modes and arguments remain available. Source-only parsing retains the pre-SDK behavior on older PowerShell; external SDK execution requires the stated prerequisite. Compatibility on Windows PowerShell 5.1 must be verified on that host before claiming it as tested.

The maintainer core-boundary check inspects PowerShell command ASTs and statically bound process-launch targets. Policy data and prohibition text remain product data. Dynamic executable selection and variable data flow require independent review; this static check does not prove arbitrary script behavior.
