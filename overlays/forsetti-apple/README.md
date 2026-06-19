# Forsetti Apple Governance Overlay

This overlay applies only to iOS and macOS work governed by the Apple edition profile.

## Binding Profile

Use `editions/apple/forsetti-apple-0.1.3.profile.json` unless the human owner provides an updated Apple profile. The profile binds framework version `0.1.3`, manifest schema/template `1.1`, supported platforms, public products, capabilities, dependency rules, and verification commands.

## Allowed Platform Surface

Swift, SwiftUI, Foundation, Apple frameworks, Xcode, Swift Package Manager, SwiftLint, and XCTest may be used in correct layers and modules. App-owned modules may use Apple-native APIs only when capabilities and runtime requirements are declared and bounded by the manifest.

## Core Boundary

`ForsettiCore` must remain platform/UI independent. It must not import SwiftUI, UIKit, AppKit, StoreKit, or `ForsettiPlatform`. Consumer code must depend on public Forsetti products and must not patch framework internals.

## Manifest and Runtime Requirements

Manifest schema/template `1.1` is expected. Modules must declare runtime requirements for I/O, UI surface, and data isolation. UI and app modules must declare the active UI runtime surface. Service modules must not contribute UI.

## Evidence

Apple tasks must provide profile selection, manifest evidence, capability declarations, dependency boundary evidence, module-isolation evidence, public API evidence, and the Apple verification commands required by the selected profile when practical.
