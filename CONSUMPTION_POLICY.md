# Forsetti Agentic Edition Consumption Policy

## Consume the governance product through an external installation

**Do not import, copy, vendor, embed, or use the entire Forsetti Agentic Edition repository as the starting tree of a governed project.** This prohibition applies even when the copied repository remains unmodified. A request to use Forsetti governance authorizes the allowlisted toolkit and project metadata below; it does not authorize copying the development repository.

Forsetti Agentic Edition SDK is a **developer governance toolkit, not an application runtime SDK**. Its policies, schemas, profiles, roles, approved templates, and trusted bundle are usable product data. They are not application runtime configuration and must not become application source, resources, Xcode application targets, C++ link dependencies, or shipping app assets.

This policy defines supported integration and engineering boundaries. It does not amend or replace [LICENSE](LICENSE). Preserve the license and applicable notices when distributing permitted material.

## 1. Immutable toolkit assets: install outside the governed repository

Install a versioned SDK archive in an external directory. Keep these release assets together and preserve their bytes:

| Asset | Permitted use and location |
| --- | --- |
| `bundle/VERSION`, `bundle/product-manifest.json`, and exactly its inventoried `editions/`, `policies/`, `schemas/`, and `instructions/` files | Trusted governance resources in the external SDK. The internal bundle retains its `platform: source` identity even beside a native host executable. |
| `Governance/` doctrine, required `agents/` role instructions, and `standards/` dependency closure | Read and follow the packaged constitution, compliance, change, release, documentation, accountability, and delivery rules. The release source map identifies each canonical source and packaged destination. |
| `Templates/` approved contract and project-context inputs | Read or instantiate the designated templates into project-owned records. Templates and their unresolved sample values are not evidence of approval. |
| `core/validator/` explicitly inventoried PowerShell validator and helpers, plus its mapped policy/schema/profile resources | Run target checks from the external toolkit against a separate target root. Do not copy `core/` into the target to satisfy resource lookup. |
| `Tools/` bounded installation, integrity, and validation wrappers | Development-time tools. They may write only the approved generated destinations in section 2. |
| `bin/forsetti-governance` or `bin/forsetti-governance.exe`, when included in a tested native-host variant | Execute on the stated host OS and architecture. This is a host tool, not an iOS executable or embeddable runtime library. Portable variants contain no native executable. |
| SDK `README.md`, `AGENTS.md`, `Documentation/`, `Release-Notes.md`, `VERSION`, `sdk-manifest.json`, and `payload-map.json` | Consumer entry points and delivery provenance. The SDK `AGENTS.md` is distinct from the development repository's maintainer instructions. |
| Complete `CONSUMPTION_POLICY.md`, `LICENSE`, and applicable notices | Keep with every SDK variant. The policy must be byte-identical to the recorded release source, with its source path, revision, and SHA-256 in delivery metadata. |

An inventory hash establishes consistency with the inventory, not publisher authentication or permission to package an arbitrary file. The reviewed source-to-destination allowlist determines eligibility. `sdk-manifest.json` records delivery provenance and does not replace `bundle/product-manifest.json` or canonical policy authority. Verify both before installation and target validation; do not regenerate trusted hashes to conceal altered inputs.

No repository-local immutable toolkit snapshot mode is supported by this release. Keep the SDK external. A future snapshot mode would require a separately reviewed exact allowlist, pinned hashes, explicit update workflow, and exclusion from application resources.

## 2. Project-owned metadata and managed outputs

The governed repository remains independently owned. The supported setup workflow may create the following files, plus their parent directories:

| Destination | Ownership and purpose |
| --- | --- |
| `.forsetti/project.json` | Native bootstrap project record; schema `2.0`. |
| `.forsetti/modules.json` | Project-owned module inventory. Keep actual identities and module membership accurate. |
| `.forsetti/project-context.json` | Validator context generated from the same explicit edition/profile selection. It is a different schema from `project.json`; the files are not interchangeable. |
| `.forsetti/profile.lock.json` | Managed pin for the selected framework profile and its bytes. |
| `.forsetti/policy.lock.json` | Managed pin for the trusted policy bundle. |
| `.forsetti/product.lock.json` | Managed pin for the product bundle and version. |
| `.forsetti/instructions/GOVERNANCE.md` | Managed copy of the approved target instruction block. |
| A single marked section in project `AGENTS.md` | Managed instructions between `<!-- FORSETTI-GOVERNANCE:BEGIN -->` and `<!-- FORSETTI-GOVERNANCE:END -->`. Preserve all unrelated project text. |

The initializer may create empty `.forsetti/contracts/`, `.forsetti/tasks/`, `.forsetti/evidence/`, and `.forsetti/validation/` directories. Project-authorized contracts, task records, actual command evidence, validation reports, and independent review decisions may subsequently live there. They must describe that project and real work. They are not copies of upstream maintainer state. An explicitly scoped contract may choose other project-owned evidence paths; it does not widen the immutable toolkit allowlist.

Instantiate approved Markdown or JSON contract templates with real scope, accountable human owner, governed roles, selected project context, required approvals, and acceptance criteria before meaningful work. Never transplant completed upstream contracts, example approval, validation success records, or historical evidence as the consumer's state.

Review a dry run before installation. Repeated setup with the same verified selection must preserve unrelated instructions and application files. Changed project context, conflicting locks, malformed or duplicate managed blocks, unsafe paths, or a new profile/toolkit pin require a deliberate reconciliation workflow. Do not silently overwrite local metadata or repin it. Recover partial writes from a reviewed backup, inspect the resulting files, and rerun integrity and target checks before proceeding.

Generated governance metadata may be tracked according to the project's governance and privacy rules. It belongs to development governance; do not add it to an application bundle or runtime dependency graph. Installation must not change global instructions, application build files, provider accounts, or hosted workflows.

## 3. Optional adapters and subordinate guidance

GitHub Actions support is an optional, separately requested adapter. It requires its own reviewed inventory and authorized host configuration. The base SDK does not install `.github/workflows/`, enable hosted checks, change repository settings, or require paid hosting, an LLM, agent server, orchestrator, MCP server, or provider account.

Consumer-relevant platform overlays may be supplied only when specifically allowlisted. They remain subordinate to canonical policies and the selected edition profile. They cannot redefine rules or combine Apple and Windows capabilities. Required machine-readable policy semantics remain in the bundle even when they describe optional tooling; excluding infrastructure is not permission to delete policy entries.

## 4. Maintainer source and history: read separately, do not transplant

The following are excluded from SDK release payloads and from wholesale downstream copying:

- Native implementation sources, headers, build projects, full `products/` trees, and native test binaries.
- Test suites, conformance fixtures, sample approval/evidence, completed maintainer contracts, and `.forsetti/alignment/`, `.forsetti/product-completion/`, or remediation history.
- Git metadata, caches, secrets, signing keys, upstream validation logs, roadmap/VISION material, wiki copies, and repository maintenance configuration.
- Apple or Windows application-runtime implementations, runtime binaries, sample applications, and framework module scaffolds. Their governance profiles are permitted; the runtimes themselves are separate products.

A separate development checkout may be used to inspect source, build host tools, or perform explicitly authorized toolkit maintenance. That checkout must not become an application foundation, target, vendored dependency, submodule, subtree, or runtime resource tree. This release retains existing source-library products for their existing users but adds no governance-library embedding distribution. Do not invent a root SwiftPM package dependency for the nested Apple host package.

## 5. Enforcement and evidence boundaries

Keep product version, bundle/schema version, framework profile version, and module manifest/template version separate. Agentic product `1.2.0` does not select framework `1.2.0`; Windows profile `0.2.0` does not select Agentic product `0.2.0`. Unknown framework versions fail closed. A newer framework release requires explicit source-backed profile alignment before support is claimed.

Bundle verification proves the inventoried bundle bytes and structure passed that check. It does not approve a task, establish application compliance, prove runtime behavior, or replace an independent Validator decision. Target checks must inspect the real target, actual changed-file evidence, the selected profile, and the required native application evidence. Static or heuristic findings have the limits documented in the command and compatibility guides.

Preserve sealed-runtime, public API, manifest, capability, dependency-direction, and module-isolation rules. Preserve strict outcomes, rule identifiers, required evidence, task authority, independent role decisions, and release gates. Packaging does not authorize relaxing a failing rule. Builders may report executed checks; they must not approve their own work.

## 6. Upstream boundary provenance

The shared consume-the-product boundary was reviewed against the immutable [Apple Forsetti consumption policy at `baf20c37740911595be034231f60dc433c5445bf`](https://github.com/flynn33/Forsetti-Framework-Mac-iOS/blob/baf20c37740911595be034231f60dc433c5445bf/CONSUMPTION_POLICY.md), source path `CONSUMPTION_POLICY.md`, SHA-256 `c467e128bfb6afa5bec9f08e7fb18a36d7424b3f395d972452e1e6dcae5057ca`.

That Apple policy governs its own Swift products and scaffolds. It is a provenance reference for the shared boundary, not the Agentic artifact allowlist. This edition's complete policy and reviewed delivery map define the Agentic governance product boundary. Each runtime edition retains its own policies and licensing; this toolkit grants no permission to copy those repositories.
