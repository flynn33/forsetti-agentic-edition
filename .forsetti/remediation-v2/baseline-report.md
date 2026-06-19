# Phase 00 Baseline Report

Generated: 2026-05-08
Branch: `audit/remediation-v2-baseline`
Repository root: `A:\Workspace\Forsetti-Framwork-Agentic-Edition`
Remediation package: `A:\Workspace\forsetti-remediation-package-v2`

## Status

The current repository is not yet remediated. This phase is evidence-only and intentionally does not modify `core/**`, `adapters/**`, `overlays/**`, `policies/**`, or `COMPLIANCE_POLICY.md`.

## Repository Root Identification

The repository root was identified as `A:\Workspace\Forsetti-Framwork-Agentic-Edition`. The following required root indicators are present:

- `README.md`
- `AGENTS.md`
- `policies/`
- `schemas/`
- `contracts/`
- `.github/`

## Failed P0 Findings From Latest Audit

1. No portable architecture exists: `core/`, `adapters/`, and `overlays/` are missing.
2. README still uses orchestration/GitHub workflow enforcement language.
3. No portable local validator exists.
4. Compliance rule IDs conflict between JSON and Markdown surfaces; `FAE-C011` and `FAE-C012` are missing.
5. Task contracts remain templates/schemas only and are not enforced.

## Failed P1 Findings From Latest Audit

1. GitHub workflows remain core enforcement and hard-code policy.
2. Contributor guard rejects prohibited source-line language and requires human authorship only.
3. Path and documentation policies reference stale paths.
4. No Apple, Windows, or generic overlays are present.
5. Remediation is not reflected accurately in version/changelog evidence.

## Existing Validator Commands

### PowerShell Validator

Command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1
```

Result: failed with exit code `1`.

Observed output included:

```text
Forsetti Agentic Edition - Repo Validation
[1/6] Checking required files...
  ERROR: Missing required file: README.md
  ERROR: Missing required file: VISION.md
  ERROR: Missing required file: FORSETTI_CONSTITUTION.md
  ...
[2/6] Validating JSON files...
  ERROR: Invalid JSON: A:\Workspace\package-lock.json
...
[5/6] Checking labels.json sync...
  ERROR: One or both labels.json files missing.
Validation Complete
  Errors:   57
FAILED - 57 error(s) must be resolved.
```

Interpretation: the PowerShell script computes `$RepoRoot` as `A:\Workspace`, not the repository root, so it reports present repository files as missing and scans `A:\Workspace\package-lock.json`.

### Bash Validator

Command:

```bash
bash .\scripts\validate-repo.sh
```

Result: failed with exit code `1`.

Observed output:

```text
Windows Subsystem for Linux has no installed distributions.
Use 'wsl.exe --list --online' to list available distributions
and 'wsl.exe --install <Distro>' to install.
```

Interpretation: the Bash validator was not runnable in this Windows environment because WSL has no installed distro.

## Missing Required Architecture Paths

- `core/` is missing.
- `adapters/` is missing.
- `overlays/` is missing.
- `overlays/generic/` is missing.
- `overlays/forsetti-apple/` is missing.
- `overlays/forsetti-windows/` is missing.

## Direct Orchestration and Core GitHub Dependency Language

Direct occurrences observed:

- `README.md:9`: "governance and orchestration framework"
- `README.md:45`: "GitHub workflow enforcement"
- `wiki/Changelog.md:19`: initial release summary includes "GitHub workflow enforcement"
- `wiki/Releases.md:34`: references workflow enforcement as part of breaking-change impact
- `wiki/Releases.md:74`: references modifying workflow enforcement

Prohibited source-line rejection occurrences observed:

- `.github/workflows/contributor-attribution-guard.yml:1`: contributor guard workflow title.
- `.github/workflows/contributor-attribution-guard.yml:11`: source-line rejection job title.
- `.github/workflows/contributor-attribution-guard.yml:213`: source-line rejection error message requiring human authorship.

## Compliance Rule Mismatches

`policies/compliance-rules.json` currently defines only `FAE-C001` through `FAE-C010`; `FAE-C011` and `FAE-C012` are missing.

Observed Markdown headings in `COMPLIANCE_POLICY.md`:

- `FAE-C001: No Task Contract or Governing Scope`
- `FAE-C002: Unauthorized Scope Expansion`
- `FAE-C003: Protected Governance Asset Modification Without Authority`
- `FAE-C004: False Completion Claim`
- `FAE-C005: Silent Breaking Change`
- `FAE-C006: Missing Required Changelog Entry`
- `FAE-C007: Missing Required Documentation Update`
- `FAE-C008: Hidden Known Failure`
- `FAE-C009: Assumptions Presented as Confirmed Facts`
- `FAE-C010: Contradiction Between Delivered Summary and Evidence`

Observed JSON titles in `policies/compliance-rules.json`:

- `FAE-C001: Task Contract Required Before Execution`
- `FAE-C002: Scope Boundary Enforcement`
- `FAE-C003: Role Separation Enforcement`
- `FAE-C004: Protected Asset Governance Gate`
- `FAE-C005: Changelog Entry Required for Substantive Changes`
- `FAE-C006: Breaking Change Disclosure Mandate`
- `FAE-C007: Completion Summary Truthfulness`
- `FAE-C008: Documentation Sync Compliance`
- `FAE-C009: Version Classification Accuracy`
- `FAE-C010: Governance Change Isolation`

Additional mismatch evidence:

- `AGENTS.md:107` says completion statement misrepresentation is a blocking violation `FAE-C004`, but JSON defines `FAE-C004` as `Protected Asset Governance Gate`.
- `wiki/Compliance.md` repeats the same old `FAE-C001` through `FAE-C010` headings as `COMPLIANCE_POLICY.md`.
- Workflow files contain hard-coded governance checks, especially `.github/workflows/protected-path-check.yml`, `.github/workflows/policy-check.yml`, `.github/workflows/changelog-validation.yml`, `.github/workflows/version-guard.yml`, and generated documentation/changelog/version workflows.

## Stale Path Policy Evidence

Observed stale or missing path references:

- `policies/repo-boundaries.json`: `CONSTITUTION.md`
- `policies/repo-boundaries.json`: `CHANGELOG.md`
- `policies/repo-boundaries.json`: `docs/wiki/**`
- `policies/repo-boundaries.json`: `RELEASE_NOTES.md`
- `policies/repo-boundaries.json`: `src/**`
- `policies/repo-boundaries.json`: `docs/**`
- `policies/docs-sync-rules.json`: `CONSTITUTION.md`
- `policies/docs-sync-rules.json`: `docs/architecture.md`
- `policies/docs-sync-rules.json`: `docs/glossary.md`
- `policies/docs-sync-rules.json`: `docs/agent-roles.md`
- `policies/docs-sync-rules.json`: `docs/compliance-guide.md`
- `policies/docs-sync-rules.json`: `docs/versioning.md`
- `policies/docs-sync-rules.json`: `docs/changelog-guide.md`
- `policies/docs-sync-rules.json`: `CHANGELOG.md`

## Local Validator Search

Search command:

```powershell
Get-ChildItem -Path . -Recurse -File | Where-Object { $_.FullName -notmatch '\\.git\\' } | Select-String -Pattern 'forsetti_validate|forsetti-validate|validate.py' -CaseSensitive:$false
```

Observed output: no matches.

Interpretation: no portable local validator entry point was found.

## Version and Changelog Evidence

- `VERSION` remains `1.0.0`.
- `changelog/CHANGELOG.md` contains only the `1.0.0` foundation release entry.
- That entry still says the release included "GitHub workflow enforcement."

## Commands Run

- `git switch -c audit/remediation-v2-baseline`
- `powershell -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1`
- `bash .\scripts\validate-repo.sh`
- PowerShell path inventory for root indicators and missing architecture paths
- `git status --short`
- PowerShell `Select-String` searches for orchestration, GitHub workflow dependency, prohibited source-line rejection, compliance IDs, stale paths, and local validator names
- `Get-Content VERSION`
- `Get-Content changelog\CHANGELOG.md`
- `Test-Path .forsetti\remediation-v2\baseline-report.md`
- `python3 -m json.tool .forsetti\remediation-v2\baseline-report.json`
- `python3 -m json.tool .forsetti\remediation-v2\phase-00-completion.json`
- `py --version`
- `py -m json.tool .forsetti\remediation-v2\baseline-report.json`
- `py -m json.tool .forsetti\remediation-v2\phase-00-completion.json`
- `Get-Content .forsetti\remediation-v2\baseline-report.json -Raw | ConvertFrom-Json`
- `Get-Content .forsetti\remediation-v2\phase-00-completion.json -Raw | ConvertFrom-Json`

## Commands Not Run

- `python3 core/validator/forsetti_validate.py --repo-root . --mode all --strict` was not run because `core/validator/forsetti_validate.py` does not exist in the current repository.
- The package's final acceptance validator was not run because Phase 00 is a baseline-only phase and later phase artifacts do not exist yet.

## Phase Verification

- `Test-Path .forsetti\remediation-v2\baseline-report.md`: passed.
- `python3 -m json.tool .forsetti\remediation-v2\baseline-report.json`: failed because `python3` resolves to the Microsoft Store app execution alias on this host.
- `py --version`: passed; reported `Python 3.9.13`.
- `py -m json.tool .forsetti\remediation-v2\baseline-report.json`: passed.
- `py -m json.tool .forsetti\remediation-v2\phase-00-completion.json`: passed.
- `Get-Content .forsetti\remediation-v2\baseline-report.json -Raw | ConvertFrom-Json`: passed.
- `Get-Content .forsetti\remediation-v2\phase-00-completion.json -Raw | ConvertFrom-Json`: passed.

## Acceptance Criteria Status

- Baseline report states the current repository is not remediated: pass.
- Baseline report lists all P0/P1 failed findings from the latest audit: pass.
- No policy or source remediation attempted in this phase: pass.
- Report includes commands run, outputs observed, and commands not run with reasons: pass.

## Residual Risks

- Existing validator evidence is partly distorted by the PowerShell root-path bug and by missing WSL for Bash execution.
- The repository cannot satisfy P0 acceptance gates until later phases create portable core architecture, canonical compliance registry, local validator, and contract enforcement.
- GitHub workflow logic remains core enforcement until Phase 06.
