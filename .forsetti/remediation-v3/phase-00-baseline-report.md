# Phase 00 Baseline Report

## Phase

- Phase ID: 00
- Phase name: Baseline Remediation Evidence Capture
- Branch: `audit/v3-baseline-evidence`
- Result: pass

## Summary

The repository is not remediated yet. Phase 00 is an evidence-only baseline for the v3 plan. No functional remediation was attempted.

Current baseline findings:

- `core/`, `adapters/`, and `overlays/` are missing.
- `README.md` still describes the project as a "governance and orchestration framework" and lists "GitHub workflow enforcement."
- No portable local validator entry point exists under `core/validator/`.
- `policies/compliance-rules.json` defines only `FAE-C001` through `FAE-C010`; `FAE-C011` and `FAE-C012` are absent.
- `COMPLIANCE_POLICY.md` and `wiki/Compliance.md` assign old titles/meanings to `FAE-C001` through `FAE-C010`, conflicting with `policies/compliance-rules.json`.
- `.github/workflows/contributor-attribution-guard.yml` rejects certain contributor metadata and says the repository requires human authorship only.
- `policies/repo-boundaries.json` and `policies/docs-sync-rules.json` reference stale paths such as `CONSTITUTION.md`, root `CHANGELOG.md`, `docs/**`, `docs/wiki/**`, `RELEASE_NOTES.md`, and `src/**`.
- `VERSION` remains `1.0.0`; `changelog/CHANGELOG.md` only contains the 1.0.0 foundation release and still references GitHub workflow enforcement.

Historical v2 evidence exists under `.forsetti/remediation-v2/` and is preserved unchanged. It does not satisfy v3 Phase 00 because it names the v2 branch and v2 package.

## Files changed

- `.forsetti/remediation-v3/phase-00-baseline-report.md`
- `.forsetti/remediation-v3/phase-00-baseline.json`

## Commands run

| Command | Result |
|---|---|
| `git switch -c audit/v3-baseline-evidence` | Succeeded; created and switched to v3 Phase 00 branch. |
| `git status --short --branch` | Succeeded; showed branch `audit/v3-baseline-evidence` and untracked `.forsetti/`. |
| `git remote -v; git log -1 --oneline; git branch --show-current` | Succeeded; remote is `origin`, latest commit is `cbaadf6`, branch is `audit/v3-baseline-evidence`. |
| PowerShell path inventory for repository indicators and required architecture paths | Succeeded; root indicators present, `core/`, `adapters/`, and `overlays/` missing. |
| `Get-Command git,rg,powershell,py,node,npm,code,dotnet` | Succeeded; local tools found. |
| `local-host mcp list` | Succeeded; configured MCP entries listed, but this active session did not expose new MCP namespaces after configuration. |
| `Get-ChildItem -Force .forsetti -Recurse -File` | Succeeded; v2 evidence exists, v3 evidence did not exist before this phase output. |
| `powershell -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1` | Failed with exit code 1; script resolves repo root incorrectly and reports 57 errors against `A:\Workspace`. |
| `bash .\scripts\validate-repo.sh` | Failed with exit code 1; WSL has no installed distributions. |
| `rg --files --hidden -g '!/.git/*'` | Succeeded; included hidden `.github` paths and v2 evidence. |
| Search for orchestration language, GitHub workflow enforcement, contributor metadata guardrails, and rule gaps | Succeeded; found evidence in README, wiki, and workflows. |
| Search for stale policy paths | Succeeded; found stale paths in repo-boundaries and docs-sync policies. |
| Read compliance rule IDs from `policies/compliance-rules.json` | Succeeded; found `FAE-C001` through `FAE-C010` only. |
| Search Markdown compliance rule headings | Succeeded; confirmed Markdown/JSON rule-title drift. |
| Search workflow hard-coded policy and automation logic | Succeeded; found GitHub workflow policy/changelog/version/docs logic. |
| Read `VERSION` and initial changelog entry | Succeeded; confirmed version remains `1.0.0` and changelog references GitHub workflow enforcement. |
| Search for local validator entry point | Succeeded; no real validator found outside v2 evidence references. |
| `py -m json.tool policies\compliance-rules.json` and selected policy JSON checks | Succeeded; selected policy JSON parses. |

## MCP/tooling used

| Tool/server | Provider type | Local-first decision | Purpose | Result |
|---|---|---|---|---|
| Filesystem via PowerShell | existing local tooling | Local filesystem access was available and used directly. | Read package/repo files and create v3 evidence files. | Used. |
| Local Git via `git.exe` | existing local tooling | Local Git was available and used directly. | Branch/status/remote/history evidence. | Used. |
| File search via local `rg.exe` and PowerShell `Select-String` | existing local tooling | Local search tools were available and used directly. | Repository inventory and drift searches. | Used. |
| Terminal/shell via PowerShell | existing local tooling | Local shell was available and used directly. | Run validation, discovery, and evidence commands. | Used. |
| Persistent context via `.forsetti/remediation-v3/` evidence files | locally created evidence wrapper | Active memory MCP namespace was not available in this already-running session; filesystem-backed phase evidence is reasonable for Phase 00. | Persist phase decision/evidence. | Used. |
| Configured MCP list from `local-host mcp list` | existing configured local/stdio entries | Entries are configured, but not callable as active namespaces in this running chat. | Record configured MCP state for v3 evidence. | Recorded only. |

No non-local third-party provider was used.

## Sub-agents used

| Sub-agent | Task | Findings | Reconciled? |
|---|---|---|---|
| `multi-agent-coordinator` | Phase 00 pass/fail and evidence reconciliation. | Blocked reuse of v2 evidence as v3; required fresh v3 outputs and task-scope clarity. | Yes; fresh v3 outputs created, v2 preserved as historical evidence. |
| `git-workflow-manager` | Read-only Git state review. | Current branch has no upstream; v2 evidence is untracked and not v3; avoid `git add .`. | Yes; only v3 evidence paths are listed as Phase 00 changes. |
| `documenter` | Report requirements review. | Required v3 outputs were missing; report must include commands, tooling, sub-agents, validation, unresolved issues, and gates. | Yes; report and JSON follow v3 phase requirements. |
| `sentinel` | Forbidden-shortcut review. | Phase 00 should not pass until fresh v3 evidence exists; v2 evidence cannot be reused; no functional remediation should occur. | Yes; fresh v3 evidence created, no functional remediation attempted. |

## Validation

- Required Markdown output created: `.forsetti/remediation-v3/phase-00-baseline-report.md`.
- Required JSON output created and parsed: `.forsetti/remediation-v3/phase-00-baseline.json`.
- Selected policy JSON parsed with `py -m json.tool`.
- Existing PowerShell validator failed due to the known root-resolution defect.
- Existing Bash validator could not run on this Windows host because WSL has no installed distribution.

## Acceptance gates

| Gate | Status | Evidence |
|---|---|---|
| All required outputs exist | pass | This report and paired JSON were created under `.forsetti/remediation-v3/`. |
| JSON outputs parse | pass | `py -m json.tool .forsetti\remediation-v3\phase-00-baseline.json` succeeded; required schema keys were also checked with local Python. |
| Work is in scope for Phase 00 | pass | Only evidence files under `.forsetti/remediation-v3/` were created. |
| No non-local third-party provider used without approval | pass | Commands used local tooling and configured local/stdio MCP inventory only. |
| No product dependency on MCP, provider-specific tooling, GitHub Actions, or sub-agents introduced | pass | No product files were modified. |
| Reviewer findings reconciled | pass | Sub-agent findings are included and reconciled above. |

## Remaining issues

- Phase 00A and Phase 00B are not complete; Phase 01 must not start until both gates pass.
- Existing v2 evidence is untracked and historical; it should not be staged as v3 evidence unless explicitly requested.
- No instantiated repository task contract file was found. For Phase 00, the v3 phase Markdown/JSON were used as the governing scope definition; this should be tightened in later phases.
- The PowerShell validator root calculation is defective.
- WSL is unavailable, but v3 explicitly does not require WSL.
- Core remediation remains untouched and incomplete by design.

## Completion statement

Files changed: `.forsetti/remediation-v3/phase-00-baseline-report.md` and `.forsetti/remediation-v3/phase-00-baseline.json`. Validation evidence: baseline commands were run, required evidence was captured, selected policy JSON parses, the Phase 00 JSON parses, and required JSON schema keys are present. Known issues: Phase 00A/00B remain required gates, v2 evidence is historical/untracked, existing validators are not reliable on this host, and functional remediation has not begun. Documentation status: no canonical documentation changed. Release impact: none. Scope compliance: Phase 00 evidence-only scope was maintained.
