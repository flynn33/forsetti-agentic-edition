# Forsetti Agentic Edition Overview

> **Canonical source**: `README.md`
> **Last synced**: 2026-05-08, Phase 01 portable scaffold

Forsetti Agentic Edition is a governance and orchestration framework for repositories operated by AI coding agents, mixed human/AI teams, and automated software delivery systems.

It is not a runtime SDK or application framework. It is a governance layer that enforces disciplined delivery through constitutional governance, role boundaries, task contracts, compliance evidence, release traceability, and documentation integrity.

## Portable Architecture

Forsetti Agentic Edition is organized around three layers:

| Layer | Path | Purpose |
|---|---|---|
| Portable core | `core/` | Host-neutral governance doctrine, role boundaries, contract concepts, evidence requirements, and future validation interfaces. |
| Adapters | `adapters/` | Optional host integrations that translate local or hosted platform context into portable validation inputs. |
| Overlays | `overlays/` | Platform-specific execution guidance that preserves core governance meaning while documenting local expectations. |

GitHub Actions support is an optional adapter surface under `adapters/github-actions/`. It does not define canonical compliance rules.

## Core Documents

Authority flows downward:

| Rank | Document(s) | Authority |
|---|---|---|
| 1 | `FORSETTI_CONSTITUTION.md` | Highest authority. |
| 2 | Policy documents | Binding operational policy. |
| 3 | `standards/*.md` | Operational standards. |
| 4 | `contracts/*.md` | Task contract templates and task contracts. |
| 5 | `policies/*.json` | Machine-readable policy manifests. |
| 6 | `agents/*.md` | Role-specific instructions. |
| 7 | `wiki/*.md` | Derived summary content. Not canonical. |

Portable scaffold documents under `core/`, `adapters/`, and `overlays/` are subordinate documentation surfaces introduced for portability. They do not amend the root authority hierarchy.

## Repository Structure

The repository now includes:

- `core/` for portable governance scaffold documents.
- `adapters/github-actions/` for optional GitHub Actions integration documentation.
- `overlays/generic/`, `overlays/forsetti-apple/`, and `overlays/forsetti-windows/` for platform overlay scaffolds.
- Root governance, policy, standards, contracts, schemas, scripts, changelog, and wiki documentation.

## Operating Model

Every meaningful change must operate under a task contract, remain within authorized scope, update required documentation, include changelog evidence when required, and provide validation evidence before completion is claimed.

## Navigation

[Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)
