# Forsetti Agentic Edition SDK 1.2.0

Developer governance toolkit, not an application runtime SDK. This additive SDK delivery introduces an external portable kit and a macOS arm64 host variant. It does not distribute either Forsetti runtime framework or a Windows native executable without actual Windows host evidence.

## Included changes

- **FAE-GOV-2026-10-10-016 — governance-only:** establish the complete Agentic consumption policy, distinguish external immutable toolkit assets from project-owned metadata, correct downstream instructions that previously required unsupported native task commands and Windows `doctor`, and separate trusted validator resources from the target root without changing policy meaning.
- **FAE-TASK-2026-10-10-017 — minor:** add the reviewed payload/source map, deterministic SDK assembly, bounded PowerShell setup/integrity/target wrappers, consumer documentation, and focused packaging/install/validation checks.
- **FAE-REL-2026-10-10-018 — release:** synchronize product version `1.2.0`, source bundle metadata, native version declarations, documentation, provenance, and archive/checksum delivery.

Existing source-library products remain available to their current users; this CLI-first release adds no governance-library embedding distribution or native task orchestration engine. Apple framework profiles `0.1.5` and explicit `0.1.3`, Windows profile `0.2.0`, and module manifest/template `1.1` remain distinct from the Agentic product version. No newer runtime profile alignment is claimed.

## Use and boundaries

Keep the extracted SDK external. Follow [Getting Started](Documentation/Getting-Started.md), [Command Matrix](Documentation/Command-Matrix.md), and the complete `CONSUMPTION_POLICY.md`. Initialize only approved target metadata from an explicitly authored context. Validate against pinned trusted resources with actual target contracts, manifests, changed-file evidence, and required native evidence; then obtain independent review.

Native `bundle verify` checks bundle integrity. PowerShell target checks have documented static/evidence-input limits. Neither establishes independent approval or application runtime acceptance. Checksums establish byte consistency; signing/notarization or publisher-authentication claims require separate evidence.

## Verification and publication status

The exact asset's `sdk-manifest.json` and accompanying release evidence identify its clean source revision, source policy/hash equality, payload inventory, prerequisite/host details, executed checks, and unverified cases. Preparation is not release readiness. Required gates and a separate Release Manager decision must be recorded before a readiness claim.

Actual native Windows execution and Windows executable delivery are not part of these assets. Windows-profile static fixtures do not establish Windows-host execution. Intel macOS native packaging and other host architectures are not claimed. Publication must identify remaining required host/platform checks explicitly; incomplete platform verification must not be described as fully verified support.

Accountable human owner: Jim Daley. Governing contracts: FAE-GOV-2026-10-10-016, FAE-TASK-2026-10-10-017, FAE-REL-2026-10-10-018. The canonical source changelog records each included change separately; review and validation evidence are separate from authorship attribution.
