# Phase 04 Downstream Installation And Bootstrap

## Status

Implemented for the Apple native command surface. Windows native command parity remains queued for the Windows CLI completion phase.

## Files Changed

- `products/apple/Sources/GovernanceApple/RepositoryBootstrapService.swift`
- `products/apple/Sources/ForsettiGovernanceCLI/CommandLineRouter.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`

## Implemented Behavior

- Added `init` command routing.
- Added `doctor` command routing.
- Verifies the product bundle before initialization and doctor validation.
- Validates repository root as a Git repository.
- Supports explicit `--edition`, `--platform`, `--framework-version`, and `--deployment-pattern`.
- Discovers Apple or Windows edition markers when not explicitly supplied.
- Writes the target `.forsetti` layout atomically.
- Preserves existing unrelated `AGENTS.md` content.
- Inserts or replaces the delimited governance instruction section.
- Blocks malformed existing governance sections.
- Writes `project.json`, `modules.json`, `profile.lock.json`, `policy.lock.json`, `product.lock.json`, and `instructions/GOVERNANCE.md`.
- Supports `--dry-run` without writing target files.
- Preserves initialization and lock timestamps on repeated `init`.
- Rolls back newly written files and directories on write failure.
- `doctor` validates bundle integrity, installed files, instruction section, profile lock, policy lock, product lock, required native tools, and active task state.

## Evidence Paths

- `products/apple/Sources/GovernanceApple/RepositoryBootstrapService.swift`
- `products/apple/Sources/ForsettiGovernanceCLI/CommandLineRouter.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`

## Verification

| Command | Result |
| --- | --- |
| `swift test --package-path products/apple` | Passed; 9 tests executed. |
| `swift build --package-path products/apple -c release` | Passed; release executable built. |
| `products/apple/.build/release/forsetti-governance init --repository-root /tmp/ffae-init-smoke.MIxxYo --bundle-root bundle --edition apple --platform macOS --framework-version 0.1.3 --deployment-pattern developer_testing --format json` | Passed; initialized a clean fixture repository. |
| `products/apple/.build/release/forsetti-governance doctor --repository-root /tmp/ffae-init-smoke.MIxxYo --bundle-root bundle --format json` | Passed; doctor reported valid bundle, instructions, locks, native tools, and task state. |

## Unresolved Findings

- Windows native `init` and `doctor` command parity is not implemented yet. The C++ product currently verifies bundles, reports version, and has Phase 03 tamper coverage.
- Discovery is intentionally conservative. Ambiguous repositories must pass explicit owner-supplied edition and platform values.

## Exit Decision

Proceed to Phase 05 while carrying Windows command parity into the Windows native CLI completion work.
