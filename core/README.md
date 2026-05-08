# Portable Core

The portable core contains host-neutral Forsetti Agentic Edition governance concepts. It defines the delivery model that adapters and overlays consume, without depending on a hosting platform, workflow runner, IDE, local MCP server, browser, container runtime, or provider-specific tool.

## Purpose

The core exists to make Forsetti governance portable across repositories and execution environments. It describes the invariant rules and interfaces that must remain stable while platform adapters and overlays handle local differences.

## Core Boundaries

The core owns:

- contract-first execution
- role authority boundaries
- scope binding
- compliance evidence requirements
- release impact classification
- documentation integrity
- portable validation concepts

The core does not own:

- hosted workflow syntax
- platform-specific shell commands
- IDE configuration
- browser automation
- container orchestration
- provider-specific tool setup
- downstream application runtime behavior

## Portable Interfaces

Later implementation phases may add concrete files under this directory. Phase 01 establishes the interface names only.

| Interface | Purpose |
|---|---|
| `TaskContract` | Defines scope, change class, approval class, required outputs, validation gates, and completion evidence. |
| `PolicyRegistry` | Provides canonical rule identifiers, severities, evidence requirements, and remediation guidance. |
| `ValidationRequest` | Carries repository root, changed files, contract path, policy registry path, and optional environment metadata into validation. |
| `ValidationResult` | Reports pass, request-changes, or block decisions with findings, evidence paths, and unresolved issues. |
| `Adapter` | Translates host-specific context into a portable validation request. |
| `Overlay` | Narrows local execution guidance without changing core governance meaning. |

## Dependency Direction

Adapters and overlays depend on the core. The core does not depend on adapters or overlays.

```text
adapters/*  -> core
overlays/*  -> core
core        -> no adapters, no overlays, no hosted workflow dependency
```

## Phase 01 Status

This directory is a scaffold. It does not yet contain the canonical policy registry, portable validator engine, or executable enforcement code. Those are reserved for later remediation phases.
