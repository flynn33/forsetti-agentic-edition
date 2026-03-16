# Agent Roles

> Canonical sources: [`AGENTS.md`](../AGENTS.md), [`agents/*.md`](../agents/)

Summary of the governed roles in the Forsetti Agentic Edition.

## Role Model

| Role | Authority | Primary Outputs |
|------|-----------|----------------|
| **Architect** | Planning | Task contracts, change classification, scope definition |
| **Builder** | Execution | Implementation changes, documentation updates, changelog entries |
| **Validator** | Verification | Compliance reports, pass/request-changes/block decisions |
| **Release Manager** | Release | Release readiness assessments, release notes, version confirmation |
| **Documentation Manager** | Documentation | Documentation compliance assessments, drift reports, sync status |

An elevated **Governance Steward** authority exists for constitutional amendments and governance-class changes.

## Key Rules

- Each role operates within explicit authority boundaries
- No role may exceed its defined authority
- No role may validate its own work
- All roles must follow the mandatory work sequence defined in AGENTS.md

## Detailed Role Definitions

- [Architect](../agents/architect.md)
- [Builder](../agents/builder.md)
- [Validator](../agents/validator.md)
- [Release Manager](../agents/release-manager.md)
- [Documentation Manager](../agents/docs-manager.md)
