# Phase 00B Local MCP Inventory Report

## Phase

- Phase ID: 00B
- Phase name: MCP and Sub-Agent Inventory, Allowlist, and Execution Policy
- Branch: `audit/v3-mcp-subagent-governance`
- Result: pass

## Summary

Phase 00B inventoried the local MCP/tooling surface and created an allowlist. The remediation package catalog lists 23 desired MCP capabilities. This host has 10 enabled Codex MCP entries in the user-level Codex config, all using `npx` over stdio. This already-running session does not expose those entries as active callable namespaces, so Phase 00B used local equivalents for the required checks.

Configured package-backed MCP entries are treated as inventory, not product dependencies. Active use is restricted by the execution policy unless local-first evidence, provider identity, scope, data exposure, and version/pin conditions are satisfied. Unknown providers and unapproved non-local providers are denied.

## Required Phase 00B Coverage

| Required capability | Local equivalent used | Configured MCP status | Decision |
|---|---|---|---|
| `filesystem` | PowerShell filesystem access | Configured as `filesystem`; active namespace unavailable in this session | Allow local equivalent; configured entry restricted to scoped paths. |
| `terminal-shell` | PowerShell shell tool | No separate MCP entry needed | Allow. |
| `file-search` | Local `rg` and PowerShell search | No configured MCP entry | Allow local equivalent. |
| `persistent-context` | `.forsetti/remediation-v3/` evidence files | `memory` configured; active namespace unavailable in this session | Allow file-backed phase evidence; memory entry restricted until active namespace is available and scope is logged. |
| `knowledge-graph` | Package roster/catalog JSON plus local structured evidence | No verified graph server | Allow local structured evidence for Phase 00B; do not claim live graph server availability. |
| `local-git` | Local `git.exe` | `git` configured; active namespace unavailable in this session | Allow local Git; configured entry restricted until provider and version conditions are satisfied. |

## Configured MCP Entries

| Entry | Command | Local package evidence | Risk / exposure | Phase 00B decision |
|---|---|---|---|---|
| `filesystem` | `npx -y @modelcontextprotocol/server-filesystem A:\Codex\Forsetti-Framwork-Agentic-Edition A:\Codex\forsetti-codex-remediation-package-v2` | `@modelcontextprotocol/server-filesystem` 2026.1.14, SHA-256 `a7fb83c2a8000d1d69e632f6c7ce150db8ea615df9e605bc8a14ac78832cab9e` | Repository and v2 package filesystem access; v3 package path missing from configured scope. | Allow only with scoped paths and evidence; prefer direct local filesystem in this session. |
| `memory` | `npx -y @modelcontextprotocol/server-memory` | `@modelcontextprotocol/server-memory` 2026.1.26, SHA-256 `04d82390b45f06533a9fd2ab3a7d973125618f55c70d3b69f8442144c9d4de01` | Persistent context storage; active namespace unavailable. | Restricted until active and evidence logging works. |
| `sequential-thinking` | `npx -y @modelcontextprotocol/server-sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` 2025.12.18, SHA-256 `75f1b3d71af33bcab50defcb70cb14866f1a86a6f1cec84680a32d069ab68987` | Planning support only. | Restricted until active; local planning in main session is allowed. |
| `playwright` | `npx -y @playwright/mcp --browser chrome --caps vision pdf devtools --isolated --headless` | `@playwright/mcp` 0.0.75 and 0.0.70 found in local npx cache | Browser state, screenshots, local files downloaded by browser. | Restricted to explicit browser-validation phases with scope and data exposure logged. |
| `chrome-devtools` | `npx -y chrome-devtools-mcp --headless --isolated --no-usage-statistics --slim` | `chrome-devtools-mcp` 0.21.0 and 0.25.0 found in local npx cache | Browser DOM, console, network, page state. | Restricted to explicit browser/debug phases with scope logged. |
| `computer-use` | `npx -y @github/computer-use-mcp` | `@github/computer-use-mcp` 0.1.26, SHA-256 `4a230fe340cd2dfcb02cd184b89fe7e36a328c56e879bc938dfeba7c89e687a8` | Desktop control and screen context. | Restricted; use only when shell/file/browser paths are insufficient. |
| `desktop-commander` | `npx -y @wonderwhy-er/desktop-commander@latest` | `@wonderwhy-er/desktop-commander` 0.2.40, SHA-256 `78559cac7d6815e6d9e59f2c50c0ead96d6f0ecd0eea2a7888d3a8525cab395e` | Broad desktop/filesystem control; command uses mutable `@latest`. | Block active use until pinned or explicitly approved. |
| `git` | `npx -y @cyanheads/git-mcp-server` | `@cyanheads/git-mcp-server` 2.15.1, SHA-256 `341eb22f2e452869916f86538454a81645d3629b6e32958ce6932d726af5adb3` | Repository history and working tree. | Prefer local `git.exe`; MCP entry restricted until provider and version conditions are satisfied. |
| `sqlite` | `npx -y mcp-sqlite C:\Users\james\.codex\sqlite\forsetti-agentic-edition.sqlite` | `mcp-sqlite` 1.0.9, SHA-256 `5e3342051ddb34f42a3bc5dc278437530d8c8cc69b33b3d042b24ba65cdfba8d` | Local SQLite state file access. | Restricted to explicit local evidence database needs. |
| `docker` | `npx -y mcp-docker-server` | `mcp-docker-server` 1.0.1, SHA-256 `e29959d9b82c67562b85d9a50a7f3b48f295b9cd9ae2cfc107794f432dfbda53` | Container control; Docker CLI/Desktop absent. | Block until Docker is installed and phase scope requires it. |

## Allowlist

- PowerShell filesystem operations for repository and remediation package reads/writes.
- PowerShell terminal execution for validation and discovery commands.
- Local `git.exe` for branch, diff, status, history, staging, commit, and push when authorized.
- Local `rg.exe` and PowerShell search for repository indexing and evidence discovery.
- Local `.forsetti/remediation-v3/` files for persistent phase context.
- Local JSON parsing through `py`, bundled Python, or PowerShell JSON APIs.
- Visual Studio, MSBuild, .NET, Node, npm/npx, VS Code, Chrome, Edge, and Playwright when a phase explicitly needs them and evidence is logged.

## Requires Approval Or Extra Conditions

- Any non-local provider.
- Any package-backed MCP command that would fetch from the network at runtime.
- Any unpinned package-backed MCP command, especially commands using `@latest`.
- Browser, desktop, keyboard/mouse, or computer-control tooling when it could expose screen contents, DOM state, browser data, or GUI context.
- Docker control after Docker installation, if third-party images or network pulls are involved.
- Any mutation to user-level Codex config beyond the already recorded setup.

## Deny Rules

- Unknown provider identity.
- Skipping local-first discovery.
- Treating a package recommendation as an approved provider without verification.
- Writing secrets or tokens into evidence.
- Introducing a product dependency on MCP servers, hosted tooling, GitHub Actions, or helper roles.
- Allowing helper roles to approve policy, validate their own work, or mark phase gates complete without evidence.

## Validation Notes

- `codex mcp list` and `codex mcp get <server>` succeeded for the configured entries.
- Local npm cache package.json files were found for all 10 configured entries.
- Package versions and SHA-256 hashes were captured from local package.json files.
- A repo scan excluding `.forsetti` found no package-level runtime references to the configured MCP packages.
- A secondary Phase 00B acceptance-gate reference in the remediation package still names v2 evidence paths; this inventory follows the controlling Phase 00B Markdown and JSON files that require v3 outputs.
