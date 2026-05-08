# Validator Root Repair Report

## Task

- Task ID: FAE-BUG-2026-05-08-001
- Change class: bugfix
- Approval class: standard
- Branch: `fix/v3-windows-validator-root`

## Summary

The Windows PowerShell validator root defect has been repaired. `scripts/validate-repo.ps1` now resolves the repository root from the script directory and verifies the Forsetti root marker before running validation. The script's stale workflow filename checks were also aligned with the repository's current workflow files.

Docker and WSL are not required to validate this repository on this host. The active Windows validation path uses PowerShell, Visual Studio tooling, VS Code tooling, Visual Studio Python through `py`, and the bundled local Python runtime.

## Files changed

- `contracts/FAE-BUG-2026-05-08-001-validator-root.md`
- `scripts/validate-repo.ps1`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/validator-root-repair-report.md`
- `.forsetti/remediation-v3/validator-root-repair.json`

## Verification plan

- Run `scripts\validate-repo.ps1` with Windows PowerShell.
- Run `scripts\validate-repo.ps1` with PowerShell 7.
- Run `scripts\validate-repo.ps1` from a Visual Studio Developer Command environment.
- Verify JSON parsing with Visual Studio Python through `py`.
- Verify JSON parsing with the bundled local Python runtime.
- Confirm VS Code and Visual Studio are available on the host.

## Verification evidence

| Check | Result |
|---|---|
| Windows PowerShell validator run | Passed with 0 errors and 0 warnings. |
| PowerShell 7 validator run | Passed with 0 errors and 0 warnings. |
| Visual Studio Developer Command environment validator run | Passed with 0 errors and 0 warnings. |
| Absolute script path from parent workspace | Passed with 0 errors and 0 warnings. |
| VS Code workspace/tooling check | VS Code 1.115.0 opened the workspace and script; Python extensions are installed. |
| Visual Studio tooling check | Visual Studio 18 Community MSBuild 18.4.0.7901 was available. |
| Visual Studio Python through `py` | JSON evidence parsed successfully. |
| Bundled local Python runtime | JSON evidence parsed successfully. |
| Independent repair review | No issue found with the root fix; prior untracked remediation evidence must stay excluded from this repair scope. |

## Status

Implementation and verification are complete. The Windows validator root and workflow-inventory bugs are no longer active issues. Docker and WSL are not required for this validation path. Prior untracked remediation evidence remains in the working tree and is excluded from this repair change set unless separately scoped.
