# Phase 04 Report: Task Contract, Scope, Approval, and Evidence Enforcement

## Phase Result

Pass.

## Task Contract

- Contract: `contracts/FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md`
- Branch: `fix/v3-contract-enforcement`
- Change class: `breaking-change`
- Approval class: `governance-class`
- Release impact: `major`

## Files Changed

- `.forsetti/remediation-v3/phase-04-report.md`
- `.forsetti/remediation-v3/phase-04-validator-result.json`
- `.forsetti/remediation-v3/phase-04-contract-result.json`
- `README.md`
- `changelog/CHANGELOG.md`
- `contracts/FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md`
- `contracts/task-contract-template.md`
- `core/README.md`
- `core/contracts/task-contract-template.json`
- `core/schemas/task-contract.schema.json`
- `core/schemas/validator-result.schema.json`
- `core/validator/README.md`
- `core/validator/contract_rules.ps1`
- `core/validator/forsetti_validate.ps1`
- `schemas/task-contract.schema.json`
- `scripts/validate-repo.ps1`
- `wiki/Changelog.md`
- `wiki/Home.md`
- `wiki/Overview.md`
- `wiki/Workflow.md`

## Commands Run

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode contract -ContractPath .\contracts\FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md -Strict`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict`
- `py --version`
- `py -m json.tool core\schemas\task-contract.schema.json`
- `py -m json.tool schemas\task-contract.schema.json`
- `py -m json.tool core\contracts\task-contract-template.json`
- `py -c "import jsonschema, sys; print(jsonschema.__version__)"`
- `Get-Content -Raw core\schemas\task-contract.schema.json | ConvertFrom-Json | Out-Null; Get-Content -Raw core\contracts\task-contract-template.json | ConvertFrom-Json | Out-Null; Get-Content -Raw core\schemas\validator-result.schema.json | ConvertFrom-Json | Out-Null; Write-Output 'ConvertFrom-Json passed'`
- `py -c "import json, jsonschema; schema=json.load(open('core/schemas/task-contract.schema.json', encoding='utf-8')); data=json.load(open('core/contracts/task-contract-template.json', encoding='utf-8')); jsonschema.Draft202012Validator(schema).validate(data); print('task contract template validates')"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode all -Strict -OutputJson .\.forsetti\remediation-v3\phase-04-validator-result.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode contract -ContractPath .\contracts\FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md -ChangedFilesPath "$env:TEMP\forsetti-phase04-changed-files.txt" -Strict -OutputJson .\.forsetti\remediation-v3\phase-04-contract-result.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode contract -ContractPath .\contracts\FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md -ChangedFile CONTRIBUTING.md -Strict -OutputJson "$env:TEMP\forsetti-phase04-negative-scope-result.json"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 -RepoRoot . -Mode contract -ContractPath "$env:TEMP\forsetti-phase04-standard-contract.json" -ChangedFile AGENTS.md -Strict -OutputJson "$env:TEMP\forsetti-phase04-negative-approval-result.json"`
- `py -m json.tool .forsetti\remediation-v3\phase-04-validator-result.json`
- `py -m json.tool .forsetti\remediation-v3\phase-04-contract-result.json`
- `py -c "import json, jsonschema; schema=json.load(open('core/schemas/validator-result.schema.json', encoding='utf-8')); jsonschema.Draft202012Validator(schema).validate(json.load(open('.forsetti/remediation-v3/phase-04-validator-result.json', encoding='utf-8'))); jsonschema.Draft202012Validator(schema).validate(json.load(open('.forsetti/remediation-v3/phase-04-contract-result.json', encoding='utf-8'))); print('validator result evidence validates')"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1 -Mode contract -ContractPath .\contracts\FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md -ChangedFilesPath "$env:TEMP\forsetti-phase04-changed-files.txt" -Strict`
- PowerShell parser pass for `core/validator/contract_rules.ps1`, `core/validator/forsetti_validate.ps1`, and `scripts/validate-repo.ps1`
- `git diff --check`

## MCP And Tooling Used

- Filesystem operations through local PowerShell and repository files.
- Local Git for branch and changed-file inspection.
- Local code execution through Windows PowerShell and `py` Python 3.9.13.
- Local test runner through `core/validator/forsetti_validate.ps1`.
- Memory MCP retained standing project instructions before this phase.
- Required advisory reviewers were run as local subagent reviews.
- Docker and Playwright were not used; they are not required for this phase.

## Local-First And Provider Fallback Decisions

- All implementation and validation were performed locally.
- No non-local provider was used for product behavior.
- No fallback to remote validation, hosted workflow execution, or external service was required.

## Advisory Reviewer Findings And Disposition

- backend-developer: recommended a dedicated `contract` mode, explicit changed-file inputs, repo-relative path normalization, glob handling, and most-restrictive protected-path approval. Implemented.
- api-designer: recommended extending the existing validator instead of creating a competing CLI, supporting `-ContractPath`, `-ChangedFile`, and `-ChangedFilesPath`, preserving the result envelope, and updating schema enums. Implemented.
- test-writer: required JSON parsing, schema validation, strict validator evidence, changed-file scope negative cases, protected-path approval negative cases, and validator result schema conformance. Implemented or scheduled for final validation.
- security-auditor: flagged bypass risks around untracked files, path traversal, emergency approval, governance authorization evidence, and canonical protected-path handling. Implemented with normalized paths, explicit approval comparison, governance authorization checks, and local boundary policy use.
- sentinel: flagged missing downstream impact assessment, evidence output mismatch, and under-evidenced governance authorization. Contract amended before implementation continued.
- code-reviewer: flagged result schema drift, wrapper mode drift, global required-path risk, and schema ID mismatch. Implemented with result schema updates, wrapper updates, task-local evidence only, and date-stamped task ID support.

## Validation Results

- JSON parsing: `py -m json.tool` passed for `core/schemas/task-contract.schema.json`, `schemas/task-contract.schema.json`, `core/contracts/task-contract-template.json`, `.forsetti/remediation-v3/phase-04-validator-result.json`, and `.forsetti/remediation-v3/phase-04-contract-result.json`.
- PowerShell JSON parsing: `ConvertFrom-Json` passed for the new task contract schema, JSON template, and validator result schema.
- JSON Schema validation: `core/contracts/task-contract-template.json` validates against `core/schemas/task-contract.schema.json` using `jsonschema` 4.25.1.
- Validator strict all mode: pass, 16 findings passed, 0 warnings, 0 errors. Evidence: `.forsetti/remediation-v3/phase-04-validator-result.json`.
- Contract strict mode: pass, 6 findings passed, 0 warnings, 0 errors. Evidence: `.forsetti/remediation-v3/phase-04-contract-result.json`.
- Wrapper contract mode: pass through `scripts/validate-repo.ps1`.
- PowerShell parser pass: 3 changed PowerShell files parsed with no syntax errors.
- Whitespace check: `git diff --check` passed with no whitespace errors.
- Negative scope case: `CONTRIBUTING.md` blocked under `FFAE-SCOPE-002` / `FAE-C002`.
- Negative approval case: `AGENTS.md` with `standard` approval blocked under `FFAE-APPROVAL-004` / `FAE-C004`.
- Schema mirror check: `core/schemas/task-contract.schema.json` and `schemas/task-contract.schema.json` are byte-identical.

## Unresolved Issues

- GitHub workflow adapter conversion remains out of Phase 04 scope and is reserved for a later phase.
- Platform overlay validation remains out of Phase 04 scope and is reserved for a later phase.
- `core/policies/repo-boundaries.json` does not currently encode every protected asset listed in `CHANGE_CONTROL_POLICY.md`; Phase 04 honors the higher-authority policy through local fallback rules without modifying policy registries.

## Acceptance Gate Status

Pass.

- Required outputs exist.
- JSON outputs parse.
- Changed files are inside the Phase 04 task contract scope.
- Protected-path approval checks run locally.
- No non-local provider was used.
- Product behavior does not depend on MCP servers, remote providers, GitHub Actions, Docker, Playwright, or advisory subagents.
- Advisory reviewer findings were reconciled.
