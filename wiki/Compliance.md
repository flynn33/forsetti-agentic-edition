# Compliance

> **Canonical source**: [`COMPLIANCE_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/COMPLIANCE_POLICY.md)
> **Last synced**: 2026-05-10, FAE-GOV-2026-05-10-008 policy paths, docs, changelog, and release accuracy

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)](https://github.com/flynn33/forsetti-agentic-edition/blob/main/LICENSE.md)

---

## Compliance Doctrine

Compliance is determined by evidence, not confidence, assertion, or intent. A change is compliant only when required policy conditions are satisfied and evidence is present, current, and verifiable.

---

## Canonical Rule Registry

The canonical machine-readable compliance registry is `core/policies/compliance-rules.json`. The root file `policies/compliance-rules.json` is a compatibility mirror and must remain byte-for-byte identical to the core registry until the root policy hierarchy is amended.

---

## Compliance Outcomes

| Outcome | Meaning |
|---|---|
| Pass | Required conditions are met and evidence is present. |
| Request Changes | Issues are fixable within current scope and must be corrected before approval. |
| Block | A fundamental violation prevents progress until resolved and re-evaluated. |

---

## Compliance Rules

| Rule | Title | Decision |
|---|---|---|
| FAE-C001 | Task Contract Required Before Execution | block |
| FAE-C002 | Scope Boundary Enforcement | block |
| FAE-C003 | Role Separation Enforcement | block |
| FAE-C004 | Protected Asset Governance Gate | block |
| FAE-C005 | Changelog Entry Required for Substantive Changes | request changes |
| FAE-C006 | Breaking Change Disclosure Mandate | block |
| FAE-C007 | Completion Summary Truthfulness | block |
| FAE-C008 | Documentation Sync Compliance | request changes |
| FAE-C009 | Version Classification Accuracy | request changes |
| FAE-C010 | Governance Change Isolation | block |
| FAE-C011 | Evidence and Validation Integrity | block |
| FAE-C012 | AI Assistance Disclosure and Human Accountability | request changes |

---

## Required Evidence

Completion claims must identify files changed, validation results, known issues, documentation status, release impact, and scope compliance.

Scope evidence compares changed files against the task contract. Documentation evidence confirms required documentation and wiki sync. Release evidence confirms version impact, changelog accuracy, and migration guidance for breaking changes. Governance evidence confirms protected-path authority and governance isolation. Evidence integrity confirms that validation artifacts are current, specific, and traceable.

## Policy Gate Evidence

Machine-readable policy manifests can define local gate metadata in addition to canonical `FAE-C###` compliance rule IDs. Validator findings include policy-local rule IDs, condition IDs, and gate IDs when a manifest supplies that data.

Phase 05 policy gates cover protected path approval, role-limited path authority, policy mirror integrity, documentation sync, changelog entry completeness, changelog history integrity, and version classification consistency. These gates make the evidence behind a pass, request-changes, or block decision traceable to a specific manifest condition.

---

## Role Responsibilities

| Role | Compliance Responsibility |
|---|---|
| Architect | Defines measurable compliance criteria and reviews sensitive or breaking changes. |
| Builder | Produces evidence, updates documentation, creates changelog entries, and reports status accurately. |
| Validator | Evaluates compliance and renders pass, request-changes, or block decisions. |
| Release Manager | Confirms version impact, changelog integrity, and release readiness. |
| Documentation Manager | Confirms documentation sync and detects documentation drift. |
| Governance Steward | Authorizes governance-class changes and resolves governance ambiguity. |

---

<sub>

**Navigation**: [Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Documentation](Documentation) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
