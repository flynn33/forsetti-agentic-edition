# Source references and canonical precedence

The release's `sdk-manifest.json` records its exact source repository and revision. `payload-map.json` is the reviewed source-to-destination allowlist; inventory entries record copied bytes and SHA-256. The complete [consumption policy](../CONSUMPTION_POLICY.md) is copied byte-identically from that recorded revision. Its source path, revision, and hash remain delivery provenance rather than a new policy authority.

Canonical precedence is human owner instruction, selected edition/version profile, shared sealed-runtime invariants, constitution, root policy documents, canonical machine-readable rules, roles/standards/templates, task contracts, then local instructions. The SDK preserves this precedence. Its consumer entry `AGENTS.md` is not the development repository's maintainer `AGENTS.md`; derived guides do not amend doctrine.

## Installed doctrine and dependency closure

Canonical Markdown is preserved without rewriting policy meaning. The relative root/role/standard/template structure under `Governance/` allows these consumer dependencies to resolve:

| Canonical source | Installed destination |
| --- | --- |
| `FORSETTI_CONSTITUTION.md` | [Governance/FORSETTI_CONSTITUTION.md](../Governance/FORSETTI_CONSTITUTION.md) |
| `COMPLIANCE_POLICY.md` | [Governance/COMPLIANCE_POLICY.md](../Governance/COMPLIANCE_POLICY.md) |
| `CHANGE_CONTROL_POLICY.md` | [Governance/CHANGE_CONTROL_POLICY.md](../Governance/CHANGE_CONTROL_POLICY.md) |
| `RELEASE_POLICY.md` | [Governance/RELEASE_POLICY.md](../Governance/RELEASE_POLICY.md) |
| `DOCUMENTATION_POLICY.md` | [Governance/DOCUMENTATION_POLICY.md](../Governance/DOCUMENTATION_POLICY.md) |
| `ACCOUNTABILITY_POLICY.md` | [Governance/ACCOUNTABILITY_POLICY.md](../Governance/ACCOUNTABILITY_POLICY.md) |
| `CODE_OF_DELIVERY.md` | [Governance/CODE_OF_DELIVERY.md](../Governance/CODE_OF_DELIVERY.md) |
| `agents/architect.md`, `builder.md`, `validator.md`, `release-manager.md`, `docs-manager.md` | Same filenames under `Governance/agents/`. |
| `standards/review-standard.md`, `changelog-standard.md`, `naming-standard.md`, `versioning-standard.md`, `documentation-standard.md`, `mcp-local-helper-standard.md` | Same filenames under `Governance/standards/`. Optional local-helper guidance does not impose a provider/service dependency. |
| `contracts/task-contract-template.md`, `bugfix-contract-template.md`, `governance-change-template.md`, `release-contract-template.md` | Same relative structure under `Governance/contracts/` and reusable inputs under `Templates/contracts/`. |
| `core/contracts/forsetti-project-context-template.json`, `task-contract-template.json` | Same relative structure under `Governance/core/contracts/` and `Templates/core/contracts/`. |
| `core/schemas/forsetti-project-context.schema.json`, `task-contract.schema.json`, `module-manifest-1.1.schema.json` | Explicit canonical-byte closure mirrors under `Governance/core/schemas/`, `Templates/core/schemas/`, and `core/schemas/` as mapped. |
| `LICENSE` | SDK root `LICENSE` and byte-identical `Governance/LICENSE` for doctrine link closure. |

For example, a policy's `core/policies/compliance-rules.json` refers to the canonical registry whose release product bytes are at [bundle/policies/compliance-rules.json](../bundle/policies/compliance-rules.json). Matching root `policies/` paths in doctrine are compatibility mirrors, not independent authorities. The bundle retains all approved policy semantics, including rules that describe optional services or hosted tools.

## Trusted resources and reusable inputs

| Source family | SDK mapping and authority |
| --- | --- |
| `bundle/product-manifest.json` and its required entries | Preserved under `bundle/`; internal native integrity contract and canonical synchronized resources. |
| `editions/apple/*.profile.json`, `editions/windows/*.profile.json`, shared invariants | Approved pinned profile files under `bundle/editions/`. |
| Canonical `core/policies/*.json`, approved operational policy inputs, and compatibility mirrors | Generator-synchronized bundle resources under `bundle/policies/`; canonical precedence remains with the source registry where designated. |
| Product schemas and explicitly needed validator schemas | Bundle schemas plus precisely mapped `core/schemas/` compatibility resources; no bulk `core/` copy. |
| `core/validator/forsetti_validate.ps1`, `contract_rules.ps1`, `rules/forsetti_project_rules.ps1`, integrity/helper closure | Explicit allowlist under SDK `core/validator/`. Reads SDK/bundle resources while inspecting a separate target. |
| `bundle/instructions/target-agents-section.md` | Immutable instruction input for managed target outputs. |
| `sdk/README.md`, `AGENTS.md`, `Release-Notes.md`, `Documentation/`, `Tools/` | Consumer docs/tools mapped to SDK root destinations. |

Use the actual `payload-map.json` rather than a directory wildcard when auditing a release. An added source file is not eligible merely because an inventory generator can hash it. Schemas and templates retain source bytes; instantiated contracts/context must replace sample values and resolve resources explicitly through the installed mapping.

## Maintainer-only references

Doctrine may name repository documentation inventories, wiki sync obligations, maintainer instructions, VISION/roadmap, contribution policy, hosted adapter paths, or upstream historical records. These references describe toolkit maintenance; they are not dependencies to copy into a consumer. The SDK deliberately omits maintainer root `AGENTS.md`, VISION, wiki, completed contracts/evidence, native source trees, and runtime frameworks. Read such references at the source revision recorded in `sdk-manifest.json` using `https://github.com/flynn33/forsetti-agentic-edition/blob/<sourceRevision>/<sourcePath>`. They cannot override this edition's consumer allowlist.

The upstream repository baseline used to identify the onboarding/router mismatch was [Agentic commit `50805ad627e7bbc8052c5b422e6e38b4d1964911`](https://github.com/flynn33/forsetti-agentic-edition/tree/50805ad627e7bbc8052c5b422e6e38b4d1964911). Release metadata identifies the resulting release source; the baseline is not a claim that current release bytes equal that older commit.

The shared consume-the-product boundary references the immutable [Apple consumption policy](https://github.com/flynn33/Forsetti-Framework-Mac-iOS/blob/baf20c37740911595be034231f60dc433c5445bf/CONSUMPTION_POLICY.md), revision `baf20c37740911595be034231f60dc433c5445bf`, SHA-256 `c467e128bfb6afa5bec9f08e7fb18a36d7424b3f395d972452e1e6dcae5057ca`. It governs that edition's products; it is not the Agentic artifact allowlist and does not align a newer runtime release to an older governance profile.
