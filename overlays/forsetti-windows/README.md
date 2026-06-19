# Forsetti Windows Governance Overlay

This overlay applies only to Windows work governed by the Windows edition profile.

## Binding Profile

Use `editions/windows/forsetti-windows-0.2.0.profile.json` unless the human owner provides an updated Windows profile. The profile binds framework version `0.2.0`, manifest schema/template `1.1`, supported platform, public products, capabilities, dependency rules, and verification commands.

## Native Toolchain

The native path is C++20, MSVC, CMake, CTest, PowerShell, vcpkg, and Windows SDK. Other tooling may collect evidence only when explicitly approved and must not become an FFAE core dependency.

## Public Contract Boundary

Public headers are the consumer contract. Consumer code must compose public targets only and must not patch `ForsettiCore`, `ForsettiPlatform`, or `ForsettiHostTemplate` internals. `ForsettiHostTemplate` is a sealed composition layer.

## Manifest and Capabilities

Windows manifest casing and capability names are exact. Manifest schema/template `1.1` is expected. Windows capability names include `event_publishing` in addition to shared capabilities. Runtime requirements must include I/O, UI, and data isolation fields.

## Evidence

Windows tasks must provide profile selection, manifest evidence, capability declarations, dependency boundary evidence, module-isolation evidence, public API evidence, and the Windows verification commands required by the selected profile when practical.
