# Forsetti Windows Overlay

The Forsetti Windows overlay records Windows-native execution guidance for Forsetti Agentic Edition.

## Purpose

Windows work should use the local machine's native capabilities where they improve evidence quality, while preserving the same governance invariants as the portable core.

## Operating Expectations

- Prefer Windows-native validation paths when working on Windows.
- Use PowerShell validation when repository scripts provide it.
- Use installed IDE, build, test, and language tooling when it materially improves validation evidence.
- Treat Visual Studio, Visual Studio Code, MSBuild, Python, PowerShell, Git, and browser tooling as local execution resources, not portable core dependencies.
- Document unavailable tools as evidence context only when the phase requires those tools.

## Boundary

This overlay may describe Windows execution expectations. It must not require Windows for portable core consumers, redefine compliance rules, or make any IDE or local tool mandatory outside the Windows overlay.

## Phase 01 Status

This overlay is a scaffold. Detailed Windows alignment checks and platform validation are reserved for a later remediation phase.
