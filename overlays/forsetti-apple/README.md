# Forsetti Apple Governance Overlay

This overlay applies only to iOS and macOS work governed by an Apple edition profile. It documents execution expectations and remains subordinate to the selected versioned profile and shared invariants.

## Binding Profile

Use `editions/apple/forsetti-apple-0.1.5.profile.json` for current Apple work. Project-context templates and the Apple native bootstrap default to framework `0.1.5`. The retained `0.1.3` profile may be selected only by explicitly setting both the framework version and versioned profile path. Unknown versions must block initialization.

The current profile binds Swift tools `5.10`, iOS `17.0`, macOS `14.0`, manifest schema/template `1.1`, safe legacy `1.0` defaults, source-contract hashes, public products, internal targets, capabilities, I/O kinds, default roles, runtime invariants, strict object-oriented implementation rules, sealed consumer boundaries, deployment patterns A through D, dependency rules, activation strategies, Xcode templates, and verification commands.

## Product and Target Boundaries

Consumer applications and modules may depend only on public products:

- `ForsettiCore`
- `ForsettiPlatform`
- `ForsettiHostTemplate`

`ForsettiModulesExample` is an internal verification target. It must not be exposed as a public dependency or used as a consumer integration surface.

## Allowed Platform Surface

Swift, SwiftUI, Foundation, Apple frameworks, Xcode, Swift Package Manager, SwiftLint, and XCTest may be used in their correct layers and owning modules. App-owned modules may use Apple-native APIs only when the relevant capabilities and runtime requirements are declared and the selected profile permits the dependency direction.

## Core and Dependency Boundaries

`ForsettiCore` remains independent of `ForsettiPlatform`, `ForsettiModulesExample`, `ForsettiHostTemplate`, SwiftUI, UIKit, AppKit, StoreKit, and Combine. `ForsettiPlatform` depends on `ForsettiCore` and must not depend on the host or internal example target. `ForsettiHostTemplate` may compose the two public lower layers but must not import `ForsettiModulesExample`. Consumer modules use public products only and do not reference other module implementations directly.


## Object-Oriented and Consumer Integration Rules

Apple work must preserve protocol-first public contracts, constructor dependency injection, cohesive single-purpose objects, tight access control, and `final` production classes unless subclassing is a deliberate documented API decision. Global mutable state, implicit singleton coupling, service-locator shortcuts, silent error swallowing, unsafe force unwraps, and degraded `Sendable` or concurrency correctness are prohibited.

Consumer applications treat Forsetti as a sealed dependency. App-specific behavior belongs in app-owned modules composed through public products and bootstrap/runtime contracts. Missing extension points require an upstream framework enhancement; copying or patching framework internals is not an authorized workaround.

## Deployment Patterns

- **Pattern A — single app module:** the recommended starting point; one app-owned `ForsettiAppModule` owns the application surface.
- **Pattern B — multi-module single app:** exactly one UI module plus independently bounded service modules.
- **Pattern C — developer testing:** framework controls remain visible only for development and module evaluation.
- **Pattern D — dashboard or multi-app host:** explicit framework controls and routing overlays are added intentionally through public contracts.

## Manifest and Runtime Requirements

Manifest schema/template `1.1` uses object-encoded semantic versions, reverse-DNS module identifiers outside the reserved `forsetti.` namespace, Swift type-path entry points, and explicit `io`, `ui`, and `dataIsolation` runtime requirements. Legacy schema/template `1.0` remains decodable with safe defaults: no I/O, no UI, no default module role, and `private_to_module` data isolation.

- UI and app modules declare their active UI runtime surface.
- Service modules declare `ui: null` and cannot provide UI contributions.
- Each I/O kind requires its mapped capability.
- `framework_mediated_shared` data isolation requires a `shared_database` provider.
- Default module roles must be valid for the module type and must declare their mapped capability where required.
- Service resolution is scoped to the requesting module and its granted capabilities.

`crypto_utilities` is a capability but is not an Apple I/O provider kind. Apple `0.1.5` defines no separate `event_publishing` capability; publishing through framework context does not create an additional manifest capability requirement.

## Runtime Lifecycle

Manifest discovery establishes registration before activation. Registration identity and the resolved implementation must agree. Only one UI or app module may be active at a time, service modules may remain active concurrently, and restored modules pass through normal compatibility, entitlement, capability, and runtime-requirement gates.

## Evidence

Apple tasks must provide selected-profile evidence, manifest evidence, capability and runtime-requirement evidence, dependency and module-isolation evidence, public API evidence, and the verification commands required by the selected profile. Framework verification includes the guardrail script and an iOS Simulator package build. Consumer verification includes Swift tests with coverage and strict SwiftLint when those tools are available. Unavailable Xcode or Apple SDK commands must be recorded as limitations, never represented as passing results.
