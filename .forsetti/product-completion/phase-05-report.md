# Phase 05 Project And Multi-Module Discovery

## Status

Implemented for the Apple native command surface with structured SwiftPM and Xcode inspection. Windows CMake/MSBuild parity remains incomplete and is tracked for Windows native CLI completion.

## Files Changed

- `products/apple/Sources/GovernanceApple/LocalProcessRunner.swift`
- `products/apple/Sources/GovernanceApple/ProjectDiscoveryService.swift`
- `products/apple/Sources/ForsettiGovernanceCLI/CommandLineRouter.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`

## Implemented Behavior

- Added `discover` command routing.
- Verifies the product bundle before discovery.
- Detects SwiftPM, Xcode, CMake, and MSBuild markers.
- Uses `swift package dump-package --package-path` and parses structured SwiftPM JSON.
- Uses `xcodebuild -list -json -project` when Xcode projects are present.
- Reads CMake File API reply metadata when present.
- Discovers top-level module manifests by required manifest fields.
- Produces proposed `modules.json` inventory when `--output` is supplied.
- Detects duplicate module IDs.
- Detects module-bearing targets without manifests.
- Detects manifests without matching native targets.
- Detects overlapping source roots.
- Detects unsupported platforms.
- Detects direct target dependency edges between governed modules.
- Requests explicit reconciliation when observed inventory differs from approved `.forsetti/modules.json`.

## Evidence Paths

- `products/apple/Sources/GovernanceApple/ProjectDiscoveryService.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`
- `/tmp/ffae-discover-smoke.qE9tnS/.forsetti/discovery/modules.proposed.json`

## Verification

| Command | Result |
| --- | --- |
| `swift test --package-path products/apple` | Passed; 12 tests executed. |
| `swift build --package-path products/apple -c release` | Passed; release executable built. |
| `products/apple/.build/release/forsetti-governance discover --repository-root /tmp/ffae-discover-smoke.qE9tnS --bundle-root bundle --output /tmp/ffae-discover-smoke.qE9tnS/.forsetti/discovery/modules.proposed.json --format json` | Passed; discovered SwiftPM target and wrote proposed module inventory. |
| `python3 -m json.tool /tmp/ffae-discover-smoke.qE9tnS/.forsetti/discovery/modules.proposed.json` | Passed; proposal parsed as JSON. |

## Unresolved Findings

- Windows discovery currently recognizes CMake and MSBuild markers and reads existing CMake File API replies, but it does not yet generate CMake File API query/reply metadata or parse MSBuild project XML into a full target graph.
- The command requests reconciliation instead of overwriting approved `.forsetti/modules.json`.

## Exit Decision

Proceed to Phase 06 while carrying Windows discovery parity into the Windows native CLI completion work.
