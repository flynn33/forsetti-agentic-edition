# Forsetti Edition Profiles

Edition profiles are machine-readable governance inputs for Forsetti-compliant app and module work. They are binding references for FFAE contracts, agent instructions, validator modes, and completion evidence.

## Profiles

| Profile | Path | Framework Version | Platforms |
|---|---|---:|---|
| Shared invariants | `editions/shared/shared-forsetti-invariants.json` | n/a | all |
| Apple (current) | `editions/apple/forsetti-apple-0.1.5.profile.json` | `0.1.5` | iOS, macOS |
| Apple (compatibility) | `editions/apple/forsetti-apple-0.1.3.profile.json` | `0.1.3` | iOS, macOS |
| Windows | `editions/windows/forsetti-windows-0.2.0.profile.json` | `0.2.0` | Windows |

## Governance Rules

- A task contract must select one edition profile before Builder execution.
- New or version-unspecified Apple work defaults to `0.1.5`.
- Apple `0.1.3` remains available only through explicit profile and framework-version selection for compatibility work.
- Unknown profile versions must fail closed; they must not resolve to the newest or oldest available profile implicitly.
- Shared invariants apply to every profile.
- Profile platform, capability, dependency, manifest, and verification requirements override lower task instructions.
- Profiles are references for validation. FFAE must not copy or implement Apple or Windows runtime behavior.

## Apple 0.1.5 Contract Notes

The current Apple profile records the supplied framework's source hashes, Swift tools and deployment targets, public products, internal verification target, current and legacy manifest behavior, capability mappings, runtime invariants, strict object-oriented implementation rules, sealed consumer boundaries, deployment patterns A through D, Xcode templates, activation strategies, dependency boundaries, and framework/consumer verification commands. The source contract pins 29 load-bearing files and the supplied upstream pass report.

Two distinctions are binding:

- `crypto_utilities` is a declared capability, not a `runtimeRequirements.io.kind`.
- Apple `0.1.5` has no `event_publishing` capability. The Windows profile retains its existing edition-specific capability.
- `ForsettiCore` must also remain free of `Combine`; this is an enforced target-level restriction, not a blanket ban on Combine in app-owned modules.
- Legacy manifest `1.0` decoding uses safe defaults: no I/O, no UI, no default module role, and `private_to_module` data isolation.

## Drift Checklist

When a framework release changes public contracts, manifest shape, capabilities, dependency direction, module types, or verification commands:

- update the matching edition profile;
- update `core/schemas/edition-profile.schema.json` when profile shape changes;
- update `core/policies/forsetti-enforcement-rules.json` when enforcement meaning changes;
- update overlays and wiki summaries;
- record the change in `changelog/CHANGELOG.md`;
- run local JSON validation and the available validator checks.
