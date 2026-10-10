# SDK consumer instructions

This is the consumer entry point for Forsetti Agentic Edition SDK. It is a developer governance toolkit, not an application runtime SDK. Keep the SDK external to the target repository and read `CONSUMPTION_POLICY.md` before copying or generating any artifact.

Use the actual paths and commands in [Getting Started](Documentation/Getting-Started.md) and [Command Matrix](Documentation/Command-Matrix.md). Required prerequisites and platform limits are in [Compatibility](Documentation/Compatibility.md). Unsupported native task commands are not part of onboarding.

Authority follows the accountable human owner's instruction, selected edition/version profile, shared sealed-runtime invariants, constitution, canonical policies, machine-readable rules, role instructions/standards, task contracts, and local instructions. Read the complete `Governance/FORSETTI_CONSTITUTION.md`, governing policies, `Governance/CODE_OF_DELIVERY.md`, and the instructions for your governed role under `Governance/agents/`. [Source References](Documentation/Source-References.md) maps repository source names to installed paths.

Before meaningful target work, establish a real authorized contract using `Templates/`, identify the target repository mode, edition/platform, exact framework/profile versions, manifest/template versions, deployment/module identity, capabilities, runtime requirements, public API boundary, and framework-internals status. Confirm scope, acting role, reviewer role, and required approval class. Do not use a sample template's default identity as the target's verified identity.

Use `Tools/Initialize-Consumer.ps1` with an authored context and review its dry run. Keep unrelated project instructions and application files intact. Native `.forsetti/project.json` and validator `.forsetti/project-context.json` have different schemas. Do not substitute one for the other. Do not overwrite changed context or repin locks silently.

For delivery, run `Tools/Validate-Consumer.ps1` against the separate target with real contract, context, manifest where applicable, changed-file evidence, and command evidence. Use target modes; `repo` and `all` are maintainer checks. Preserve strict outcomes, rule IDs, edition-specific capabilities, public API boundaries, sealed runtime, dependency direction, and module isolation.

Record the accountable human owner, acting governed role, contract ID, actual validation/review evidence, and required approval evidence. Do not add tool, model, vendor, automation, or agent attribution to source, public records, commits, or release notes. Report failed, skipped, partial, stale, and unavailable checks accurately.

A Builder may report executed checks but must hand completed work to an independent Validator and the other required reviewers. Neither SDK integrity, a static target check, nor task-template presence is an independent approval or runtime acceptance. Update required project documentation/changelog and satisfy release gates before claiming completion.
