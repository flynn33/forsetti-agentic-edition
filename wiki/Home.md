# Forsetti Agentic Edition

> **Canonical source**: `README.md`
> **Last synced**: 2026-05-11, FAE-TASK-2026-05-11-013 platform overlay guidance

## Welcome

This wiki provides navigational documentation for the Forsetti Agentic Edition governance framework. Repository markdown files are canonical. Wiki pages are derived orientation surfaces.

## Portable Architecture

| Layer | Path | Purpose |
|:-----|:-----|:--------|
| Portable core | `core/` | Host-neutral governance doctrine, role boundaries, enforceable task contract structure, evidence requirements, canonical policy registries with pre-merge gate metadata, and local validation interfaces. |
| Adapters | `adapters/` | Optional host integrations that translate platform context into portable validation inputs. GitHub Actions workflow implementation lives in `adapters/github-actions/workflows/`. |
| Overlays | `overlays/` | Host-neutral and platform-specific execution guidance that preserves core governance meaning. |

GitHub Actions workflow files are wrappers around adapter-owned scripts. They preserve hosted check names while keeping enforcement logic and local-validator invocation outside the portable core.

Phase 08 overlays provide `generic`, Apple-platform, and Windows-native guidance profiles. They remain subordinate to root governance documents and canonical core policy registries.

## Quick Navigation

| Page | Description | Source |
|:-----|:------------|:-------|
| [Overview](Overview) | Repository overview, structure, and portable architecture | `README.md` |
| [Constitution](Constitution) | Foundational principles, authority hierarchy, and governance doctrine | `FORSETTI_CONSTITUTION.md` |
| [Agent Roles](Agent-Roles) | The governed roles, their authorities, and boundaries | `AGENTS.md`, `agents/*.md` |
| [Workflow](Workflow) | Change control lifecycle, approval classes, and documentation policy | `CHANGE_CONTROL_POLICY.md`, `DOCUMENTATION_POLICY.md` |
| [Compliance](Compliance) | Canonical compliance registry, evidence requirements, accountability policy, and outcomes | `COMPLIANCE_POLICY.md`, `AI_ASSISTANCE_POLICY.md`, `core/policies/compliance-rules.json` |
| [Releases](Releases) | Versioning model, release readiness, and impact classification | `RELEASE_POLICY.md` |
| [Changelog](Changelog) | Version history and change records | `changelog/CHANGELOG.md` |
| [Glossary](Glossary) | Key terms and definitions | Various |

## Core Principles

1. **Contract Before Action** - No meaningful work begins without a governing contract.
2. **Scope Is Binding** - Work stays within defined boundaries.
3. **Truthfulness Is Mandatory** - Status claims must match evidence.
4. **Governance Overrides Convenience** - Required process is not optional.
5. **Documentation Is Part of Delivery** - Documentation drift is a compliance issue.
6. **Compliance Must Be Measurable** - Evidence determines compliance.
7. **Release Integrity Is Non-Negotiable** - Release claims require validation.

## Getting Started

1. Read [Constitution](Constitution) to understand governance principles.
2. Review [Agent Roles](Agent-Roles) to understand role boundaries.
3. Study [Workflow](Workflow) for change control procedures.
4. Check [Compliance](Compliance) for blocking violation rules.
5. Use local validator contract mode when reviewing changed files against a governing task contract, protected path rules, role-limited path rules, documentation sync obligations, and changelog/version evidence.

## Navigation

[Home](Home) | [Overview](Overview) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)
