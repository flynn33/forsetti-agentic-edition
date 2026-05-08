# Phase 00A Tool Discovery Report

## Phase

- Phase ID: 00A
- Phase name: Windows Native Host Tool Discovery
- Branch: `audit/v3-windows-tool-discovery`
- Result: pass

## Summary

Windows-native discovery completed for the local host. This phase did not attempt functional remediation and did not introduce product dependencies.

The machine has substantial local tooling available: Visual Studio Community 2026, Visual Studio Community 2022, Visual Studio Build Tools 2022, MSBuild, .NET SDKs, VS Code, Git, GitHub CLI, Node/npm/npx, `py` with Visual Studio Python, bundled Codex Python/Node runtimes, Chrome, Edge, ripgrep, winget, and local Playwright availability.

Known host or repository limitations were also confirmed:

- `python` and `python3` resolve to Microsoft Store aliases and fail, while `py` works.
- Docker CLI/Desktop are not installed.
- WSL is installed but has no Linux distributions.
- Direct desktop screenshot capture was blocked by host security; display enumeration works.
- The existing PowerShell repository validator fails with 57 errors due to a repository-root calculation defect.
- The Bash validator cannot run because WSL has no installed distribution.
- No application build/test manifests were found beyond `scripts/validate-repo.ps1` and `scripts/validate-repo.sh`.

The build-error-resolver helper advised recording Phase 00A as blocked unless a repository validator succeeds. That finding is documented as a blocker for remediation validation, not as a blocker for this discovery phase, because Phase 00A acceptance criteria require evidence outputs, parsing, scope control, provider disclosure, and reconciliation. The validator failure has a remediation plan: fix or replace the repo-root logic before any later phase relies on the validator as acceptance evidence.

## Files changed

- `.forsetti/remediation-v3/tool-discovery-report.md`
- `.forsetti/remediation-v3/tool-discovery.json`

## Host inventory

| Area | Status | Evidence |
|---|---|---|
| Current shell | available | PowerShell 7.5.5, `PSEdition` Core. |
| Windows PowerShell | available | `powershell -NoProfile -Command $PSVersionTable.PSVersion.ToString()` returned 5.1.26100.8115. |
| OS | available | Microsoft Windows 10.0.26200, x64. |
| Repository branch | available | `audit/v3-windows-tool-discovery`. |
| Remote | available | `origin` points to `https://github.com/flynn33/forsetti-agentic-edition`. |

## Tool inventory

| Tool category | Discovery result | Notes |
|---|---|---|
| VS Code | available | `code --version` returned 1.115.0. CLI path: `C:\Users\james\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd`. |
| Visual Studio | available | `vswhere` found Visual Studio Community 2026 at `C:\Program Files\Microsoft Visual Studio\18\Community`, Visual Studio Community 2022, and Visual Studio Build Tools 2022. |
| MSBuild | available by direct path and `dotnet msbuild` | PATH lookup did not find `msbuild`, but direct MSBuild versions 18.4.0.7901 and 17.14.40.60911 were found. `dotnet msbuild -version` returned 18.3.0.15422. |
| .NET | available | `dotnet --info` returned SDK 10.0.201 with SDKs 9.0.311, 10.0.200-preview, and 10.0.201 installed. |
| Git | available | `git --version` returned 2.53.0.windows.1. |
| GitHub CLI | available | `gh --version` returned 2.88.0 and `gh auth status` showed authenticated HTTPS Git operations. |
| Node/npm/npx | available | Node 24.13.1, npm 11.8.0, npx 11.8.0. Bundled Node 24.14.0 also exists. |
| Python | available through `py` and bundled runtime | `py --version` returned Python 3.9.13; `py -0p` found Visual Studio Python 3.9.13. Bundled Python 3.12.13 exists. |
| Python PATH aliases | unavailable for execution | `python --version` and `python3 --version` failed with Microsoft Store-alias messages. |
| pip | available | `py -m pip --version` returned pip 22.0.4; bundled Python pip returned 26.0.1. |
| Docker | unavailable | `Get-Command docker` failed and direct Docker Desktop/CLI paths were not found. |
| Browser executables | available by direct path | Chrome file version 147.0.7727.138 at `C:\Program Files\Google\Chrome\Application\chrome.exe`; Edge file version 148.0.3967.54 at `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`. |
| Playwright | available locally | `npx --no-install playwright --version` returned 1.59.1. |
| ripgrep | available | `rg --version` returned 15.1.0. |
| Package managers | partial | winget 1.28.240 exists; choco and scoop were not found. |
| SQLite CLI | unavailable | `sqlite3` not found on PATH. |
| WSL/Bash | limited | `wsl --status` returned default version 2; `wsl --list --verbose` and `bash .\scripts\validate-repo.sh` reported no installed distributions. |
| Screen capture / vision | limited | Display enumeration found `\\.\DISPLAY1` at 3413x960; direct screenshot capture attempt was blocked by host security. |
| Repository build/test manifests | limited | Only `scripts\validate-repo.ps1` and `scripts\validate-repo.sh` were found. No `package.json`, solution/project files, Python project files, Dockerfile, Makefile, or Justfile were found. |

## Commands run

| Command or check | Result |
|---|---|
| `git switch -c audit/v3-windows-tool-discovery` | Succeeded; created and switched to Phase 00A branch. |
| `git status --short --branch` | Succeeded; branch is `audit/v3-windows-tool-discovery`; `.forsetti/` remains untracked. |
| `Get-Date`, `$PSVersionTable`, OS runtime checks | Succeeded; host and shell information captured. |
| `Get-Command` for shell, editor, build, runtime, browser, search, and package tools | Succeeded; PATH inventory captured. |
| Direct path checks under Program Files, Program Files (x86), LocalAppData, and bundled Codex runtime paths | Succeeded; Visual Studio, MSBuild, browsers, bundled Python, and bundled Node found. |
| `vswhere -all -products * -requires Microsoft.Component.MSBuild -format json` | Succeeded; Visual Studio and Build Tools instances captured. |
| `vswhere -all -products * -find **\MSBuild.exe` and `**\devenv.exe` | Succeeded; direct MSBuild and IDE paths captured. |
| `code --version` | Succeeded; VS Code 1.115.0. |
| `dotnet --info` and `dotnet msbuild -version` | Succeeded; .NET and MSBuild information captured. |
| Direct MSBuild `-version -nologo` checks | Succeeded; MSBuild 18.4 and 17.14 paths validated. |
| `git --version`, `git remote -v`, `git log -1 --oneline`, `git branch --show-current` | Succeeded; Git state captured. |
| `node --version`, `npm --version`, `npx --version` | Succeeded; Node toolchain captured. |
| `py --version`, `py -0p`, `py -m pip --version` | Succeeded; Visual Studio Python and pip captured. |
| `python --version`, `python3 --version` | Failed with exit code 9009; Store aliases are not usable Python interpreters. |
| Bundled Python and Node version checks | Succeeded; bundled Python 3.12.13 and Node 24.14.0 captured. |
| `docker --version`, `docker info`, direct Docker Desktop path checks | Docker CLI/Desktop not found. |
| Chrome and Edge direct path checks | Succeeded by file version; CLI `--version` was not reliable for Chrome because an existing browser session handled the request. |
| `npx --no-install playwright --version` | Succeeded; local Playwright version 1.59.1 captured. |
| `winget --version`, choco/scoop lookup | Succeeded; winget exists, choco/scoop not found. |
| `wsl --status`, `wsl --list --verbose` | WSL exists; no distributions installed. |
| `powershell -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1` | Failed with 57 errors due repository-root bug. |
| `bash .\scripts\validate-repo.sh` | Failed because WSL has no installed distribution. |
| Repository manifest search | Succeeded; only validator scripts found. |
| Display enumeration with `System.Windows.Forms.Screen` | Succeeded; one primary display found. |
| Direct screenshot capture check | Failed; host security blocked the script. |
| `codex mcp list` | Succeeded; configured MCP entries recorded, but not used as active callable namespaces in this session. |
| `load_workspace_dependencies` | Succeeded; bundled Python and Node runtime paths captured. |

## MCP/tooling used

| Tooling category | Provider type | Local-first decision | Purpose | Result |
|---|---|---|---|---|
| `terminal-shell` via PowerShell | existing local tooling | local allowed | Execute discovery commands. | Used. |
| `local-build-tool` via Visual Studio, MSBuild, .NET, Node, Python, Playwright | existing local tooling | local allowed | Discover build/test/runtime capability. | Used. |
| `filesystem` via PowerShell | existing local tooling | local allowed | Test paths and create evidence outputs. | Used. |
| `screen-capture-vision` via Windows display APIs | existing local tooling | local allowed | Check display and screenshot capability. | Limited: display enumeration passed, screenshot capture blocked by host security. |
| `persistent-context` via `.forsetti/remediation-v3/` evidence files | local evidence path | local allowed | Persist Phase 00A results. | Used. |
| Workspace dependency locator | bundled local tooling | local allowed | Identify bundled Python and Node runtimes. | Used. |
| Configured MCP inventory from `codex mcp list` | configured local/stdio entries | record only | Record available configured entries. | Recorded only; not claimed as active namespaces. |

No non-local third-party provider was used.

## Advisory helper findings

| Helper role | Findings | Reconciled? |
|---|---|---|
| `devops-engineer` | Capture PATH and direct path checks for VS Code, Visual Studio, Python, .NET, Git, Node, Docker, browser tooling, local build/test manifests, and required outputs. Do not mark a tool unavailable after only one path. | Yes; PATH and direct checks were performed. |
| `build-error-resolver` | Existing PowerShell validator fails; WSL Bash validator unavailable; no broader build/test manifests; record multiple MSBuild/.NET versions; Docker and screenshot limitations are real. | Yes; recorded as remaining issues and remediation blockers for later validation, while Phase 00A discovery outputs pass. |
| `git-workflow-manager` | Branch is correct; `.forsetti/` is untracked; do not stage broadly; Phase 00A required outputs should be staged explicitly if staging occurs. | Yes; files changed list is limited to Phase 00A outputs. |
| `documenter` | Report and JSON must include phase fields, commands, tool inventory, provider decisions, helper findings, validation, acceptance gates, and remaining issues. | Yes; outputs follow the Phase 00A and shared schema requirements. |

## Validation

- Required Markdown output created: `.forsetti/remediation-v3/tool-discovery-report.md`.
- Required JSON output created: `.forsetti/remediation-v3/tool-discovery.json`.
- Required tool categories were checked with Windows-native commands.
- Provider decisions were recorded.
- Helper findings were reconciled.
- Existing PowerShell validator failed due repository-root defect; remediation plan is to repair or replace repo-root discovery before using it as later acceptance evidence.
- Existing Bash validator failed because WSL has no installed distribution; v3 does not require WSL.

## Acceptance gates

| Gate | Status | Evidence |
|---|---|---|
| All required outputs exist | pass | This report and paired JSON were created under `.forsetti/remediation-v3/`. |
| JSON outputs parse | pass | `py -m json.tool .forsetti\remediation-v3\tool-discovery.json` is required validation for this output. |
| Work is in scope for Phase 00A | pass | Only Phase 00A evidence files were created. |
| No non-local third-party provider used without approval | pass | Commands used local Windows tooling and local evidence files only. |
| No product dependency on MCP, external tooling, GitHub Actions, or helper agents introduced | pass | No product files were modified. |
| Reviewer findings reconciled | pass | Helper findings are included and reconciled above. |

## Remaining issues

- The PowerShell validator root calculation must be fixed before it can serve as reliable validation evidence.
- The Bash validator cannot run until WSL has a Linux distribution, but v3 remediation should not require WSL.
- Docker workflows are unavailable unless Docker Desktop/CLI is installed or the workflow is made Docker-optional.
- Scripts that call `python` or `python3` directly will fail on this host; they should use `py`, direct interpreter discovery, or bundled runtime paths.
- Desktop screenshot capture through direct .NET APIs is blocked by host security; browser or app-level verification should use Playwright or an approved local browser path.
- Phase 00B remains required before Phase 01 may begin.

## Completion statement

Files changed: `.forsetti/remediation-v3/tool-discovery-report.md` and `.forsetti/remediation-v3/tool-discovery.json`. Validation evidence: Windows-native discovery commands were run, required evidence was captured, required tool categories were checked, helper findings were reconciled, and the JSON output parses with required schema keys. Known issues: PowerShell validator root defect, unavailable WSL distribution, unavailable Docker, Store-alias Python commands, blocked direct screenshot capture, and pending Phase 00B. Documentation status: no canonical documentation changed. Release impact: none. Scope compliance: Phase 00A evidence-only scope was maintained.
