# Documentation

> **Canonical source**: [`DOCUMENTATION_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/DOCUMENTATION_POLICY.md)
> **Last synced**: 2026-05-11, FAE-GOV-2026-05-11-012 AI assistance accountability policy

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)](https://github.com/flynn33/forsetti-agentic-edition/blob/main/LICENSE.md)

---

## Purpose

Documentation is part of delivery. A change that affects understanding, usage, operation, governance, or release history is incomplete until the required documentation is updated or explicitly tracked under the policy.

This page summarizes `DOCUMENTATION_POLICY.md` for wiki navigation. The repository policy file remains authoritative.

---

## Canonical Source Rule

Repository markdown files are authoritative. Wiki pages are derived publishing surfaces that summarize, orient, and cross-reference repository sources.

If a wiki page, external page, cached copy, screenshot, conversation log, or third-party reference conflicts with repository markdown, the repository markdown is authoritative until the conflicting surface is corrected.

---

## Wiki Requirements

Wiki pages must:

- Reference the canonical source they derive from.
- Include a last-synced marker.
- Summarize and link to canonical sources rather than replacing them.
- Avoid introducing binding requirements that do not exist in a canonical source.
- Stay synchronized when canonical sources change.

---

## Required Sync Pairs

The documentation policy defines these canonical-to-wiki pairs:

| Canonical Source | Wiki Derived Page |
|---|---|
| `FORSETTI_CONSTITUTION.md` | `wiki/Constitution.md` |
| `AGENTS.md` | `wiki/Agent-Roles.md` and `wiki/Workflow.md` |
| `COMPLIANCE_POLICY.md` | `wiki/Compliance.md` |
| `AI_ASSISTANCE_POLICY.md` | `wiki/Compliance.md` |
| `RELEASE_POLICY.md` | `wiki/Releases.md` |
| `CHANGE_CONTROL_POLICY.md` | `wiki/Workflow.md` |
| `DOCUMENTATION_POLICY.md` | `wiki/Documentation.md` |
| `README.md` | `wiki/Overview.md` |

When a canonical source has multiple derived wiki pages, all derived pages must be updated or tracked for sync.

The canonical machine-readable sync manifest is `core/policies/docs-sync-rules.json`, with `policies/docs-sync-rules.json` as a byte-identical root mirror. The manifest expands the table above into enforceable sync pairs for role files, standards, changelog records, and canonical core policy manifests.

Machine-readable sync pairs include stable rule IDs, trigger paths, required derived paths, required evidence, rejection conditions, and failure actions. Contract-mode validation uses those pairs to request changes when a canonical source changes without the required derived wiki update or an approved deferral.

Additional core policy sync pairs include:

| Canonical Source | Wiki Derived Page |
|---|---|
| `core/policies/compliance-rules.json` | `wiki/Compliance.md` |
| `core/policies/ai-assistance-disclosure.json` | `wiki/Compliance.md` |
| `core/policies/repo-boundaries.json` | `wiki/Workflow.md`, `wiki/Compliance.md` |
| `core/policies/docs-sync-rules.json` | `wiki/Documentation.md` |
| `core/policies/versioning-rules.json` | `wiki/Releases.md` |
| `core/policies/changelog-rules.json` | `wiki/Changelog.md` |

---

## Documentation Impact

Every pull request must declare documentation impact. The review must account for README, wiki, governance document, glossary, and changelog obligations.

Required documentation depends on change class. Governance and breaking changes require wiki and changelog updates; README and glossary updates are required when the change affects repository overview or introduces new governance terminology.

---

## Drift

Documentation drift exists when documented state diverges from repository state. Drift includes stale references, missing wiki sync, README inaccuracy, glossary inconsistency, wiki contradiction, and orphaned documentation.

Detected drift must be reported or fixed in the current change. Unreported drift is a compliance issue.

---

## Review Authority

The Validator and Documentation Manager roles can request changes for documentation violations. Documentation rejection can only be resolved by fixing the violation, showing that the rejection condition does not apply, or obtaining an explicit governance exception through the governance change process.

---

<sub>

**Navigation**: [Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Documentation](Documentation) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
