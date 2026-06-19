# Source Baseline

Generated: 2026-06-19T16:56:42.623145+00:00

## Source Trees

| Source | Path | Role |
|---|---|---|
| forsetti-agentic-edition-main | `/volumes/nvme/GitHub/FFAE` | Target governance repository |
| Forsetti-Framework-Mac-iOS-main | `/volumes/nvme/GitHub/forsetti-framework-Mac-iOS` | Apple profile source reference |
| Forsetti-Framework-Windows-main | `/volumes/nvme/GitHub/Forsetti-Framework-Windows` | Windows profile source reference |

## Confirmed Framework and Manifest Versions

| Edition | Framework Version | Manifest Schema | Manifest Template |
|---|---:|---:|---:|
| Apple | 0.1.3 | 1.1 | 1.1 |
| Windows | 0.2.0 | 1.1 | 1.1 |

## Boundary

FFAE remains a governance-only repository. Apple and Windows runtime implementation changes are out of scope for this remediation. The Apple and Windows repositories are reference sources for edition profiles, shared invariants, manifest contracts, capabilities, dependency rules, and validation expectations.

## Correction Checkpoint

A stale local Windows tree under `/volumes/nvme/GitHub/MCOS/Forsetti-Framework-Windows-main/Forsetti-Framework-Windows-main` still contains schema 1.0 examples and was not used as the Windows 0.2.0 profile source.

## Workflow and Validator Mismatches Found

- The prior validator mode set lacked target Forsetti repository modes.
- The prior validator did not expose `-ProjectContextPath`, `-EditionProfilePath`, or `-ManifestPath`.
- The prior validator finding shape did not include the required `decision`, `evidence`, and `remediation` fields.
