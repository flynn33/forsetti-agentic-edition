# Governance workflow

Follow the packaged constitution, policies, role instructions, standards, and selected edition profile. [Source References](Source-References.md) maps their canonical repository names to SDK paths. This workflow uses actual contract, evidence, and validation tools; native `task` commands are unsupported.

## Authorize and scope

Before meaningful work, identify the accountable human owner and initiating request. An Architect prepares a contract from the approved `Templates/` input. Complete its context, scope, required outputs, change and approval classes, documentation/release impact, acting/reviewer roles, required approvals, and acceptance criteria. The human owner's authority and required elevated reviews must be recorded; a template or generated file does not grant authority.

Select an exact supported profile under `bundle/editions/`. Supply an accurate project context with edition, target platform, framework version, manifest/template versions, deployment/module identity, capabilities, runtime requirements, public API use, and framework-internals status. Product version and framework/profile versions have different meanings. Unknown versions and mismatched editions must fail closed.

For structured contracts, start from `Templates/core/contracts/task-contract-template.json`. JSON templates retain their source schema links under `Templates/core/schemas/`; instantiated project records should reference the trusted installed schema through the project's explicit mapping, not an unresolved template-relative path. Markdown templates and their preserved dependency closure are also packaged. The source map identifies the contract/context schemas used by validation.

## Execute with real evidence

Work only within the authorized contract scope. Preserve sealed-runtime and public API boundaries, edition-specific capabilities, module isolation, one-way dependencies, and required runtime declarations. If additional scope or authority is required, obtain a contract amendment before editing those files.

Record the actual files changed from the target's Git state and the base/revision used. `-ChangedFilesPath` accepts a newline-delimited list of target-relative paths. Include untracked/new files as applicable. Confirm that the list corresponds to readable changed target files or genuine tracked Git deletions, and the reviewed diff; do not supply an empty or invented list to make evidence mode pass.

Run the selected profile's real application toolchain checks. Retain exact commands, results, logs, failures, skipped cases, and environment details. Static SDK checks do not execute native app tests or establish physical-device/runtime acceptance. A supplied upstream validation report is profile provenance, not fresh evidence for this target.

Update the project's required documentation and changelog along with the change. Each meaningful change needs its own accurate class, version impact, summary, affected area, task reference, and approval class. Breaking changes need migration guidance and elevated review.

## Run target checks

Use `Tools/Validate-Consumer.ps1` from the external SDK. The wrapper verifies SDK and bundle integrity before checking target context and installed pins. The default `consumer` mode combines target checks; it does not run maintainer `repo` or `all` checks against an application.

```powershell
& "$SDK/Tools/Validate-Consumer.ps1" -RepoRoot $Target -Mode consumer `
  -ContractPath "$Target/.forsetti/contracts/TASK.json" `
  -ProjectContextPath "$Target/.forsetti/project-context.json" `
  -ManifestPath "$Target/Resources/ForsettiManifests/MyModule.json" `
  -ChangedFilesPath "$Target/.forsetti/evidence/changed-files.txt" `
  -OutputJson "$Target/.forsetti/validation/consumer-validation.json" -Strict
```

Use a target-owned JSON report path. The wrapper refuses to replace application inputs, metadata, contracts, manifests, or changed-file evidence; an existing recognized validator report may be replaced.

For focused investigations, select `contract`, `project-context`, `edition-profile`, `manifest`, `dependencies`, `capabilities`, `module-isolation`, or `evidence`. Keep the same actual target inputs. A module context requires its real manifest; `not_applicable` contexts can omit it. Do not combine Apple and Windows capability allowlists.

Read the JSON findings and exit result. Findings preserve `FAE-C###`/`FAE-F###` and policy-local condition/gate identifiers where applicable. A non-success result remains unresolved until the actual cause is repaired and the appropriate checks rerun. Do not weaken rules, suppress findings, rewrite source-contract hashes, or regenerate consumer pins after tampering to manufacture success.

The validator's source/dependency/capability/isolation scans and evidence-input inspection have static coverage. They are not complete language parsers, runtime tracing, proof that every required command ran, or independent approval. A pass must be reported with that scope and the separate real native evidence.

## Independent handoff and release

The Builder provides a completion summary with the complete changed-file list, exact executed checks/results, known issues and unverified cases, documentation/changelog status, version impact, and scope evidence. Record accountable human ownership, acting governed role, contract ID, actual review/validation evidence, and required approval evidence without tool attribution.

A separate Validator reviews the work and evidence. Documentation Manager, Architect, Governance Steward, and Release Manager reviews apply when required by the change/approval class. The Builder must not claim independent approval for its own checks. Never create successful task or approval records without an actual authorized decision.

Release readiness requires validated included changes, complete individual changelog entries, accurate aggregate version classification, synchronized documentation, no unresolved blocking violations, migration notes when applicable, and an explicit Release Manager decision. Archive hashes, file presence, native `doctor`, and toolkit integrity do not replace those gates.
