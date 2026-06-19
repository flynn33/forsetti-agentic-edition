# Phase 00B MCP And Subagent Execution Policy

## Purpose

This policy governs MCP and helper-role use during v3 remediation. It is evidence policy for remediation work only. It must not become a product runtime requirement.

## Provider Order

1. Use existing local tooling first.
2. Use a locally created wrapper only when direct local tooling is insufficient and the wrapper is scoped.
3. Use provider-supplied fallback tooling only after local-first absence, failure, or unreasonable local creation is documented.
4. Require explicit human approval for provider-recommended third-party tooling, non-local third-party MCP servers, and non-local third-party helper providers.
5. Deny unknown providers.

## Allowed Without Extra Approval

- PowerShell filesystem and terminal commands inside the authorized scope.
- Local `git.exe` for repository state and Git operations when the phase authorizes them.
- Local `rg.exe`, PowerShell search, and local JSON parsing.
- Local `.forsetti/remediation-v3/` evidence files for persistent context.
- Local build/test/editor/browser tools discovered in Phase 00A when the phase explicitly needs them and evidence is logged.
- Repo/package-defined helper roles from the v3 roster, as scoped helpers only.

## Restricted MCP Entries

- Package-backed `npx` MCP entries may be used only when provider identity, version, scope, data exposure, and command configuration are recorded.
- Runtime network fetch through `npx -y` is not allowed unless the phase records local-first evidence and approval status.
- Mutable package selectors such as `@latest` are blocked unless pinned or explicitly approved.
- Browser, desktop, keyboard/mouse, and computer-control tooling require phase scope, data-exposure notes, duration, and result evidence.
- Docker control is blocked until Docker is locally available and the phase requires it.

## Explicit Approval Requirements

An exception must record:

- provider identity,
- server or helper name,
- purpose,
- data exposure,
- command or configuration,
- duration,
- rollback path,
- risk acceptance.

## Helper Role Rules

- Helpers are bounded advisory or execution roles.
- Helpers must receive role, phase, scope, allowed files, prohibited files, required outputs, and stop conditions.
- Helpers must report files touched and limitations.
- Helpers may not approve policy, validate their own work, override controlling documents, silently expand scope, or claim completion without evidence.
- Disagreements between helpers are resolved against the controlling phase file, provider policy, and repository instruction hierarchy.

## Evidence Requirements

Every MCP or helper use must record:

- name,
- provider classification,
- local-first decision,
- command or invocation path when applicable,
- purpose,
- files touched,
- result,
- failure notes,
- fallback used, if any.

Secrets and tokens must not be written into evidence.

## Stop Conditions

Stop and report failure if:

- required outputs cannot be produced,
- JSON evidence cannot be parsed,
- provider identity cannot be verified for a required tool,
- non-local provider approval is required but absent,
- a helper attempts to approve its own work,
- scope would expand beyond the phase contract,
- product dependency on MCP servers, hosted tooling, GitHub Actions, or helper roles would be introduced.
