# Naming Standard

This standard defines mandatory naming conventions for all repository assets in the Forsetti Agentic Edition. These conventions are binding. Deviations are compliance violations.

## Top-Level Governance Documents

Format: `UPPER_SNAKE_CASE.md`

Top-level governance documents use uppercase snake case with the `.md` extension. These files sit at the repository root and represent foundational governance artifacts.

Examples:
- `FORSETTI_CONSTITUTION.md`
- `COMPLIANCE_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `RELEASE_POLICY.md`
- `DOCUMENTATION_POLICY.md`
- `CONTRIBUTING.md`
- `CODE_OF_DELIVERY.md`
- `AGENTS.md`
- `VISION.md`
- `README.md`

## Directory-Level Documents

Format: `lowercase-kebab-case.md`

Documents inside subdirectories use lowercase kebab case with the `.md` extension. These files are scoped to a specific domain (agents, standards, contracts, wiki).

Examples:
- `architect.md`
- `builder.md`
- `task-contract-template.md`
- `naming-standard.md`
- `review-standard.md`

## JSON Policy Manifests

Format: `lowercase-kebab-case.json`

Machine-readable policy manifests use lowercase kebab case with the `.json` extension.

Examples:
- `agent-roles.json`
- `compliance-rules.json`
- `repo-boundaries.json`

## JSON Schemas

Format: `lowercase-kebab-case.schema.json`

JSON schema files use lowercase kebab case with the `.schema.json` compound extension. The `.schema.json` suffix distinguishes schemas from data manifests.

Examples:
- `task-contract.schema.json`
- `release-entry.schema.json`

## Directories

Format: `lowercase` single words or `lowercase-kebab-case`

Directory names use lowercase. Single-word names are preferred when unambiguous. Multi-word names use kebab case.

Examples:
- `agents`
- `contracts`
- `policies`
- `standards`
- `changelog`
- `wiki`
- `schemas`
- `scripts`

## Canonical Role Names

Roles have two representations:

**Machine use**: `lowercase_snake_case`
- `architect`
- `builder`
- `validator`
- `release_manager`
- `documentation_manager`
- `governance_steward`

**Human display**: Title Case
- Architect
- Builder
- Validator
- Release Manager
- Documentation Manager
- Governance Steward

Machine identifiers are authoritative. Human display names are derived from the machine identifier.

## Label Namespaces

Format: `family:value` using lowercase

Labels use a namespace prefix separated by colon from the value. Both the family and value are lowercase.

Defined label families:
- `change:` — Change class (e.g., `change:feature`, `change:bugfix`, `change:governance`)
- `approval:` — Approval class (e.g., `approval:standard`, `approval:sensitive`, `approval:governance`)
- `status:` — Workflow status (e.g., `status:in-progress`, `status:review`, `status:blocked`)
- `role:` — Acting role (e.g., `role:architect`, `role:builder`, `role:validator`)
- `release:` — Version impact (e.g., `release:minor`, `release:major`, `release:patch`)
- `docs:` — Documentation status (e.g., `docs:needs-sync`, `docs:current`)

## Task IDs

Format: `FAE-{TYPE}-{NUMBER}`

Task identifiers use the `FAE` prefix followed by a type code and a zero-padded three-digit number.

Defined type codes:
- `TASK` — General task (e.g., `FAE-TASK-001`)
- `BUG` — Bug fix (e.g., `FAE-BUG-001`)
- `GOV` — Governance change (e.g., `FAE-GOV-001`)
- `REL` — Release task (e.g., `FAE-REL-001`)

## Compliance Rule IDs

Format: `FAE-C{NUMBER}`

Compliance rule identifiers use the `FAE-C` prefix followed by a zero-padded three-digit number.

Examples:
- `FAE-C001`
- `FAE-C002`

## Governing Principle

Names must reduce interpretation risk.

- If a name requires explanation to understand its purpose, the name must be reconsidered.
- Prefer explicit over clever.
- Prefer predictable over surprising.
- Prefer consistency over variety.

A naming violation is a compliance issue. Names are not cosmetic — they are governance infrastructure.

## Forsetti Enforcement Names

Forsetti rule IDs use `FAE-F###`. Canonical edition profile files use `forsetti-apple-<version>.profile.json` and `forsetti-windows-<version>.profile.json`. Manifest schema files use `module-manifest-<schema-version>.schema.json`.
