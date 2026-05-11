# Forsetti Windows Overlay

The Forsetti Windows overlay aligns Windows work with the shared platform alignment profile while preserving native Windows implementation paths.

## Purpose

Use this overlay for Windows repositories, Windows-first workstations, .NET or Visual Studio solutions, PowerShell tooling, and repositories whose strongest local evidence comes from Windows-native execution.

This overlay narrows local execution guidance for Windows. It does not amend portable core governance, root policy, validator behavior, or task contract requirements.

## Alignment With Platform Principles

Windows work must preserve the same platform alignment principles:

- native-first execution
- contract-first delivery
- boundary-first design
- policy-first enforcement
- host-agnostic modules
- capability enforcement
- module identity validation
- module-scoped context
- **Single active surface**: prefer one active UI, app, or automation surface unless the task contract documents a multi-surface model.

Windows implementation may differ from Apple implementation, but the governance meaning must remain the same.

## Windows-Native Implementation Guidance

Windows repositories may use:

- Windows PowerShell or PowerShell 7
- Visual Studio, Visual Studio Code, MSBuild, .NET SDK, and solution-level test runners
- Python through the Windows launcher or installed interpreter
- Git for Windows and local repository diff evidence
- Windows security, permissions, registry, service, certificate, or event-log checks when relevant
- browser and desktop tooling when the task contract scopes UI evidence

Use the local machine's strongest available tooling when it improves evidence quality. If a tool is unavailable, document the limitation and use the next best local validation path.

## Evidence Expectations

Windows overlay evidence should identify:

- the task contract and changed-file scope
- shell, IDE, build, or test tooling used
- validator, test, or build output
- local path and environment assumptions that affect reproducibility
- Windows-specific permission or execution-policy considerations
- known tool gaps and fallback choices
- reviewer decisions

## Dependency Boundary

Visual Studio, Visual Studio Code, PowerShell, MSBuild, Python, browser tooling, and desktop automation are Windows overlay execution resources. They must not be treated as portable core dependencies unless a higher-authority policy or task contract explicitly changes that boundary.

## Boundary

This overlay must not:

- require Windows for portable core consumers
- redefine Forsetti compliance rules
- change task contract structure
- add role authority
- make IDEs, local tools, hosted workflows, MCP servers, Docker, or WSL mandatory outside this overlay
- weaken shared platform alignment principles
