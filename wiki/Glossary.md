# Glossary

> **Canonical sources**: repository governance documents and overlay guidance documents referenced by each term
> **Last synced**: 2026-05-11, FAE-TASK-2026-05-11-013 platform overlay guidance

Key terms used throughout the Forsetti Agentic Edition governance framework.

**Approval Class**: The required authority level for a change (standard, sensitive, governance-class, emergency, release-critical). Defined in `CHANGE_CONTROL_POLICY.md`.

**Adapter**: An optional host integration that translates platform-specific context into portable Forsetti validation inputs without defining canonical governance rules.

**AI Assistance Accountability**: The requirement that AI-assisted work remains accountable to a human owner and governed role, with contract, review, validation, and required approval evidence. Defined in `AI_ASSISTANCE_POLICY.md`.

**Blocking Violation**: A compliance failure that prevents a change from being merged. Defined in `COMPLIANCE_POLICY.md`.

**Breaking Change**: A change that alters governance rules in a way that existing consumers must adapt. Defined in `RELEASE_POLICY.md`.

**Canonical Source**: The authoritative version of a document — always the repository markdown file. Defined in `DOCUMENTATION_POLICY.md`.

**Change Class**: The classification of a change by type (feature, bugfix, refactor, docs, governance, release, metadata, breaking-change). Defined in `CHANGE_CONTROL_POLICY.md`.

**Compliance Report**: A structured assessment of whether work meets governance requirements, rendered by the Validator. Defined in `COMPLIANCE_POLICY.md`.

**Constitutional Amendment**: A formal change to `FORSETTI_CONSTITUTION.md` requiring governance-class approval and a standalone governance change process.

**Core**: The portable governance layer that contains host-neutral Forsetti doctrine, interfaces, and validation concepts.

**Derived Content**: Content that summarizes or references a canonical source (e.g., wiki pages). Not authoritative.

**Documentation Drift**: A state where documentation no longer accurately reflects the current repository state. Defined in `DOCUMENTATION_POLICY.md`.

**Drive-By Edit**: An unauthorized modification to files outside the task contract scope. Prohibited.

**Escalation**: The process of raising a task to higher authority when it exceeds the acting role's authority or when ambiguity cannot be resolved.

**Evidence**: Observable artifacts (file changes, test results, validation output) that demonstrate compliance with governance requirements.

**Governance Steward**: An elevated authority role for constitutional amendments and governance-class changes.

**Governance-Only**: A version impact classification for constitutional/compliance changes tracked in the changelog but not in semantic versioning.

**Non-Attribution**: The prohibition on crediting a tool, model, vendor, automation, or agent as author, contributor, reviewer, validator, approver, releaser, maintainer, or source of work. Defined in `AI_ASSISTANCE_POLICY.md`.

**Edition Profile**: A machine-readable Forsetti profile under `editions/` that binds edition name, framework version, platforms, native toolchain, public products, manifest versions, module types, capabilities, dependency rules, and verification commands.

**Forsetti Project Context**: The required pre-execution context for Forsetti work: repository mode, edition, target platform, framework version, edition profile, manifest versions, deployment pattern, module type, requested capabilities, runtime requirement status, public API status, and framework-internals status.

**Manifest 1.1**: The Forsetti module manifest model requiring schema/template `1.1`, module identity, module type, supported platforms, capabilities, entry point, and runtime requirements for I/O, UI, and data isolation.

**Module Isolation**: The invariant that modules do not import, include, call, store data with, or directly reference other module implementation symbols. Intermodule interaction must use Forsetti orchestration contracts.

**Public API Boundary**: The requirement that consumer code uses public Forsetti products/contracts and does not patch sealed framework internals.

**Platform Overlay**: Host-neutral or platform-specific guidance under `overlays/` that narrows local execution expectations while preserving portable core governance meaning. Phase 08 defines generic, Apple-platform, and Windows-native overlay profiles.

**Portable Core**: The host-neutral Forsetti layer under `core/`. It must not depend on adapters, overlays, hosted workflows, IDEs, local MCP servers, container runtimes, or provider-specific tooling.

**Interpretation Debt**: The cost created when documentation is ambiguous enough that readers must guess or assume meaning.

**Meaningful Change**: A change that alters governance rules, policy content, role definitions, contract templates, standards, schemas, or enforcement mechanisms. Requires a task contract.

**Protected Path**: A file or directory requiring elevated authority (governance-class or sensitive) to modify. Listed in `policies/repo-boundaries.json`.

**Role Authority**: The defined boundaries of what a governed role may and may not do. Exceeding role authority is prohibited.

**Scope Binding**: The principle that the task contract defines the boundaries of authorized work. Changes outside scope are violations.

**Task Contract**: A structured document defining scope, authority, expected outputs, and validation requirements for a task. Created from templates in `contracts/`.

**Truthfulness Standard**: The requirement that delivered claims match observable evidence. Defined in `COMPLIANCE_POLICY.md`.

**Version Impact**: The classification of how a change affects the semantic version (none, patch, minor, major, governance-only). Defined in `RELEASE_POLICY.md`.
