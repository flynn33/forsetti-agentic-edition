# Phase 00B Local Subagent Inventory Report

## Phase

- Phase ID: 00B
- Phase name: MCP and Sub-Agent Inventory, Allowlist, and Execution Policy
- Branch: `audit/v3-mcp-subagent-governance`
- Result: pass

## Summary

The v3 package roster defines 27 bounded helper roles. Phase 00B used the required helper set: `multi-agent-coordinator`, `security-auditor`, `security-guardian`, `prompt-engineer`, and `documenter`. Their outputs were advisory findings and were reconciled into the MCP inventory and execution policy.

Helpers are remediation aids only. They may inspect, advise, implement scoped work when assigned, and report findings. They may not approve policy, validate their own work, override controlling documents, mark gates complete without evidence, or become a product dependency.

## Required Helper Results

| Helper role | Status | Findings summary | Reconciled? |
|---|---|---|---|
| `multi-agent-coordinator` | completed | Required eight outputs, scoped branch, inventory structure, provider decision order, and evidence reconciliation. | Yes. |
| `security-auditor` | completed | Configured `npx -y` MCP entries can fetch at runtime and need provider identity/version/scope decisions; mutable or broad-scope entries require restrictions. | Yes. |
| `security-guardian` | completed | Existing local tooling is allowed; non-local providers and unknown identity require denial or explicit approval; helpers cannot approve policy or own work. | Yes. |
| `prompt-engineer` | completed | Future helper prompts must include role, phase, scope, files, stop conditions, and must frame outputs as findings only. | Yes. |
| `documenter` | completed | Required Markdown/JSON structures for the eight Phase 00B outputs. | Yes. |

## Roster Summary

Allowed as bounded helpers when phase scope requires them:

`multi-agent-coordinator`, `architect`, `architect-reviewer`, `microservices-architect`, `graphql-architect`, `api-designer`, `security-auditor`, `sentinel`, `security-guardian`, `code-reviewer`, `security-reviewer`, `test-writer`, `tdd-guide`, `performance-engineer`, `performance-profiler`, `refactorer`, `backend-developer`, `frontend-developer`, `devops-engineer`, `data-engineer`, `mlops-engineer`, `documenter`, `prompt-engineer`, `git-workflow-manager`, `build-error-resolver`, `ux-researcher`, `fintech-engineerer`.

## Allowlist

- Repo/package-defined helper roles from `subagents/subagent-roster.json`.
- In-session helper agents spawned for a concrete phase task.
- Read-only advisory helpers for architecture, security, documentation, build/test, and workflow review.
- Scoped worker helpers only when the file ownership boundary is explicit and non-overlapping.

## Restrictions

- Helpers cannot approve policy or their own work.
- Helpers cannot override the instruction hierarchy.
- Helpers cannot widen file scope silently.
- Helpers cannot claim completion without validation evidence.
- Helpers cannot introduce product dependency on helper orchestration.
- Non-local helper providers require explicit approval with provider identity, purpose, data exposure, duration, rollback path, and risk acceptance.

## Validation Notes

- `subagents/subagent-roster.json` parsed successfully.
- The roster contains 27 helper roles.
- Required Phase 00B helpers were invoked and their findings were reconciled.
- No repository product files were modified by helpers.
