# Forsetti Agentic Edition SDK

**Product version: 1.1.0. Developer governance toolkit, not an application runtime SDK.**

Install this versioned toolkit outside the application repository. It supplies trusted governance data, approved contract/context templates, PowerShell target validation, bounded metadata setup, and a native macOS host executable in the macOS arm64 variant. It does not include the Apple or Windows application runtime.

Read the complete `CONSUMPTION_POLICY.md` at the SDK root and preserve `LICENSE` and applicable notices. Only approved generated metadata and the managed project instruction section cross into the governed repository. Keep SDK binaries, policies, schemas, and source/history external.

Start with [Getting Started](Documentation/Getting-Started.md), then [Governance Workflow](Documentation/Governance-Workflow.md). The [Command Matrix](Documentation/Command-Matrix.md) distinguishes host tools from target checks. [Compatibility](Documentation/Compatibility.md) separates host support, target profiles, prerequisites, and verification limits. [Source References](Documentation/Source-References.md) explains canonical precedence and the source map.

The portable archive contains no executable. The macOS arm64 archive adds `bin/forsetti-governance`. No Windows executable is shipped without actual Windows build and command evidence. A Windows edition profile describes target rules; it does not establish that the native Windows host was tested.

Every installation or consumer-validation run checks the SDK inventory and trusted source bundle before acting. `sdk-manifest.json` records the exact release source revision, assets/hashes, policy provenance, host details, and capability evidence. `payload-map.json` is the reviewed delivery allowlist. `bundle/product-manifest.json` remains the bundle integrity contract; the outer inventory does not replace policy authority. External `SHA256SUMS` covers the archives. Checksums establish consistency; consult the release evidence for any publisher-authentication claims.

Installation requires an explicitly authored project context and writes the approved `.forsetti` metadata plus one marked project `AGENTS.md` section. Use a dry run first. Existing changed context, conflicting locks, malformed instruction markers, unsafe paths, or upgrades require explicit reconciliation. Follow the recovery instructions in Getting Started after an interrupted write.

Native bundle checks establish bundle integrity. Target validation performs the documented static checks against supplied context, manifests, source, and real changed-file evidence. Neither operation approves a task or proves application runtime correctness. Independent review and the selected profile's native application evidence remain required.

See [Release Notes](Release-Notes.md) and the manifest/evidence shipped with this exact asset for executed checks, omitted platforms, and unverified cases. Installation does not enable hosted workflows or change global instructions, application targets, provider accounts, or repository settings.
