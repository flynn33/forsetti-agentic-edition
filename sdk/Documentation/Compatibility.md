# Compatibility and verification limits

Forsetti Agentic Edition SDK `1.2.0` is a developer governance toolkit. Host OS/architecture support describes where a tool executes; target profiles describe the framework rules it checks. They are independent.

## Delivery variants and prerequisites

| Variant or tool | Host requirements | Release boundary |
| --- | --- | --- |
| Portable SDK | PowerShell 7.4 or newer for setup, integrity, and validation | No native executable. Platform-specific execution status is recorded in release evidence. |
| macOS arm64 SDK | macOS 13 or newer, arm64; PowerShell 7.4 or newer for SDK wrappers/validator | Adds the built macOS host executable. An Apple profile's app deployment minimum may be higher than this host minimum. |
| Windows native executable | Native C++20 product source exists; Windows build and command checks required | Omitted from these assets while actual Windows execution remains unverified. |

Setup requires Git 2.30 or newer and an existing target Git repository. The tested PowerShell host for this preparation is 7.6.6 on macOS; that execution does not establish a Windows-host result.

Consumer tools do not require Python, Node, Java, an LLM, a provider account, an MCP server, or hosted workflow execution. Python may be used by maintainers to assemble and test releases. Normal installation keeps SDK data/binaries outside the application and writes only approved governance metadata.

No Intel macOS native asset or Windows native architecture is implied by arm64 or portable packaging. No signing or notarization claim follows from hashes; consult actual release evidence for any such claims. A macOS C++ check is not Windows execution.

## Profile and schema distinctions

| Metadata | Value or source | Interpretation |
| --- | --- | --- |
| Agentic product version | `1.2.0`, SDK and bundle `VERSION` | Toolkit release version. |
| Internal product bundle schema | `2.0` | Bundle inventory/metadata contract. Internal platform remains `source`. |
| Native generated project record | schema `2.0`, `.forsetti/project.json` | Native bootstrap representation. |
| Validator context | `core/schemas/forsetti-project-context.schema.json` | Separate snake_case target context, generated from an explicitly authored selection. |
| Current Apple profile | Framework `0.1.5` | Default current Apple alignment. |
| Explicit compatibility Apple profile | Framework `0.1.3` | Selected deliberately; no silent fallback from unknown versions. |
| Windows profile | Framework `0.2.0` | Windows target governance rules; not native Windows host readiness. |
| Module manifest/template | Selected profile, current contract `1.1` | Runtime module contract distinct from toolkit schemas; preserve profile-specific legacy rules. |

The Apple `0.1.5` profile records Swift tools `5.10`, iOS `17.0`, and macOS `14.0` for its runtime/app contract. The native governance host's macOS minimum is `13.0`. Keep those deployment contexts separate. Selecting a newer runtime/framework tag is unsupported until a reviewed, source-backed profile explicitly covers it.

Apple and Windows keep their own capabilities and public APIs. Apple `crypto_utilities` is a capability, not an I/O provider kind. Windows alone has the inspected `event_publishing` capability mapping; do not create a combined cross-edition allowlist.

## What checks establish

| Check | Establishes | Requires separate evidence |
| --- | --- | --- |
| SDK inventory | Expected delivery paths/bytes and pinned provenance are consistent. | Publisher authentication, target compliance. |
| Native `bundle verify` | Internal bundle inventory/structure passed that verifier. | Outer delivery integrity, application behavior, task approval. |
| Initialization/dry run | Reviewed metadata setup plan and generated target records. | Actual task authority, runtime installation, module correctness. |
| Native `doctor`/`discover` | Native bootstrap/discovery findings. | Full validator context, independent review, app runtime tests. |
| PowerShell target checks | Contract/context/profile/manifest rules and documented static checks on supplied evidence. | Native toolchain execution, full semantic/runtime analysis, independent approval. |

Static scans can identify patterns and input inconsistencies, but cannot prove the absence of all private API access, hidden dependencies, undeclared behavior, or runtime isolation defects. Evidence mode inspects provided changed-file inputs; it does not certify execution logs or reviewer authority by itself. Preserve required native checks and independent review.

Use the exact asset's `sdk-manifest.json`, release logs, and [Release Notes](../Release-Notes.md) for executed commands and unrun cases. Source implementation, a prior report, portable packaging, and profile provenance are not fresh host-platform acceptance. Unverified host/platform cases must remain explicitly unverified in publication and consumer decisions.
