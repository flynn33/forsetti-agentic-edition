# Forsetti Edition Profiles

Edition profiles are machine-readable governance inputs for Forsetti-compliant app and module work. They are binding references for FFAE contracts, agent instructions, validator modes, and completion evidence.

## Profiles

| Profile | Path | Framework Version | Platforms |
|---|---|---:|---|
| Shared invariants | `editions/shared/shared-forsetti-invariants.json` | n/a | all |
| Apple | `editions/apple/forsetti-apple-0.1.3.profile.json` | `0.1.3` | iOS, macOS |
| Windows | `editions/windows/forsetti-windows-0.2.0.profile.json` | `0.2.0` | Windows |

## Governance Rules

- A task contract must select one edition profile before Builder execution.
- Shared invariants apply to every profile.
- Profile platform, capability, dependency, manifest, and verification requirements override lower task instructions.
- Profiles are references for validation. FFAE must not copy or implement Apple or Windows runtime behavior.

## Drift Checklist

When a framework release changes public contracts, manifest shape, capabilities, dependency direction, module types, or verification commands:

- update the matching edition profile;
- update `core/schemas/edition-profile.schema.json` when profile shape changes;
- update `core/policies/forsetti-enforcement-rules.json` when enforcement meaning changes;
- update overlays and wiki summaries;
- record the change in `changelog/CHANGELOG.md`;
- run local JSON validation and the available validator checks.
