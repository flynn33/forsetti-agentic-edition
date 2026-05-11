# Generic Overlay

The generic overlay is the default host-neutral operating profile for Forsetti Agentic Edition.

## Purpose

Use this overlay when no platform-specific overlay is selected or when a repository must remain portable across local development environments, hosted runners, and managed workstations.

The generic overlay preserves Forsetti governance without assuming a shell, IDE, operating system, browser, MCP server, container runtime, hosted workflow provider, or language toolchain.

## Operating Profile

Generic overlay work must:

- use repository files as canonical source
- operate under a task contract for meaningful work
- keep changed files inside contract scope
- preserve role authority boundaries
- produce validation evidence before completion claims
- disclose known issues, skipped checks, and unavailable tools
- keep host-specific setup outside the portable core

## Validation Evidence

Validation evidence should use the strongest local tool available to the repository. Acceptable evidence includes:

- Forsetti local validator output
- language or repository test runner output
- JSON, schema, or structured data parse results
- file search results proving required files and prohibited patterns
- changed-file evidence compared with the governing task contract
- reviewer decisions recorded in the pull request or phase report

If a tool is unavailable, report that fact as evidence context. Do not convert tool availability into a product requirement unless a higher-authority policy or task contract explicitly requires it.

## Dependency Boundary

The generic overlay must not make Forsetti depend on:

- a specific operating system
- a specific IDE or editor
- MCP servers
- hosted workflows
- container runtimes
- browser automation
- vendor-specific services
- advisory subagents

Teams may use those tools to collect evidence. The portable core remains independent of them.

## Acceptance Checklist

- Required task contract exists.
- Changed files match contract scope.
- Required documentation and changelog updates are complete.
- Validator or equivalent local checks ran, or skipped checks are disclosed.
- No platform-specific requirement was added to portable core behavior.
- Completion summary cites concrete evidence.
