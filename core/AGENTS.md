# Core Agent Instructions

This document defines operating boundaries for work inside `core/`. It is subordinate to root `FORSETTI_CONSTITUTION.md`, root policy documents, and root `AGENTS.md`.

## Purpose

Core work must preserve portable governance. Changes in `core/` may define host-neutral concepts, interfaces, documentation, and later validation primitives. They must not require a specific host platform, hosted workflow runner, IDE, container runtime, MCP server, browser, or provider-specific tool.

## Core Rules

- Treat `core/` as host-neutral.
- Keep dependency direction one-way: adapters and overlays may consume core concepts; core must not consume adapter or overlay behavior.
- State portable interfaces in terms of contracts, policies, evidence, validation requests, and validation results.
- Keep execution evidence separate from product requirements. Local tooling used during remediation must not become a core dependency.
- Escalate before changing root governance authority, root policy meaning, role boundaries, schemas, or machine-readable policies.

## Allowed Core Work

- Portable governance documentation
- Interface definitions for future implementation phases
- Host-neutral validation concepts
- Core package structure
- Evidence and acceptance criteria that apply across hosts

## Prohibited Core Work

- GitHub Actions workflow implementation
- Platform-specific command requirements
- IDE-specific requirements
- Hosted-service requirements
- MCP or provider-specific requirements
- Runtime implementation outside an approved task contract
- Changes that supersede root constitutional authority

## Review Expectations

Core changes require evidence that:

- all modified files are inside the task contract scope,
- no adapter or overlay dependency was introduced into core,
- documentation and changelog obligations are satisfied,
- validation results support the completion claim,
- known limitations are disclosed.
