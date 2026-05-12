# Forsetti Apple Overlay

The Forsetti Apple overlay is the Apple-platform alignment profile for Apple-platform work in Forsetti Agentic Edition.

## Purpose

Use this overlay for macOS, iOS, iPadOS, watchOS, tvOS, and visionOS repositories that need Forsetti governance while preserving native Apple implementation patterns.

This overlay defines platform alignment guidance only. It does not amend the root constitution, compliance policy, task contract requirements, release policy, or validator behavior.

## Platform Alignment Principles

Apple-aligned work must preserve these platform alignment principles:

1. **Native-first execution**: prefer native Apple toolchains and platform capabilities when they produce stronger local evidence.
2. **Contract-first delivery**: every meaningful change remains governed by a task contract before implementation.
3. **Boundary-first design**: isolate platform-specific behavior from portable core governance.
4. **Policy-first enforcement**: policy manifests and repository governance define obligations before local tools or host adapters.
5. **Host-agnostic modules**: reusable governance logic must not depend on Apple-only APIs unless explicitly scoped to this overlay.
6. **Capability enforcement**: platform capabilities should be explicit, least-privilege, and testable.
7. **Module identity validation**: platform modules should have stable names, ownership, and validation evidence.
8. **Module-scoped context**: evidence and configuration should stay close to the module or contract they support.
9. **Single active surface**: prefer one active UI, app, or automation surface unless the task contract documents a multi-surface model.

## Native Implementation Guidance

Apple repositories may use:

- Xcode, XCTest, Swift Package Manager, and platform simulators
- macOS shell tooling and local scripts
- signing, entitlements, and sandbox checks when relevant
- platform-specific accessibility, security, and privacy validation
- native build logs and test reports as evidence

These tools support evidence collection. They do not become portable core dependencies.

## Evidence Expectations

Apple overlay evidence should identify:

- the task contract and changed-file scope
- the native toolchain used
- build, test, validation, or simulator results
- signing, entitlement, or permission checks when relevant
- known platform limitations or skipped checks
- reviewer decisions

Evidence must be specific enough for a reviewer to reproduce or evaluate the result.

## Boundary

This overlay must not:

- redefine Forsetti compliance outcomes
- change task contract structure
- add role authority
- weaken documentation or changelog obligations
- require Apple tooling for non-Apple repositories
- move host-specific assumptions into the portable core
