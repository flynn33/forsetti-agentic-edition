<!-- FORSETTI-GOVERNANCE:BEGIN -->
## Forsetti Governance

This repository is governed by the pinned Forsetti Agentic Edition product described in:

```text
.forsetti/product.lock.json
.forsetti/policy.lock.json
.forsetti/profile.lock.json
.forsetti/instructions/GOVERNANCE.md
```

Keep the immutable SDK installation outside this repository. Read its complete
`CONSUMPTION_POLICY.md`, `Governance/FORSETTI_CONSTITUTION.md`, canonical policies,
role guidance, and `Documentation/Governance-Workflow.md`. The SDK is a developer
governance toolkit; it is not an application runtime dependency.

Before meaningful edits:

1. Identify the selected edition/version profile, target platform, deployment,
   module, capabilities, runtime requirements, and public API boundary in the
   authored `.forsetti/project-context.json`. The native `.forsetti/project.json`
   uses a different schema; never pass it as a validator project context.
2. Have the Architect create or amend an authorized task contract using the
   external SDK's `Templates/` inputs. Confirm scope, acting/reviewer roles and
   approval class before work; install/setup does not authorize a task.
3. Run the external SDK's PowerShell 7.4+ `Tools/Validate-Consumer.ps1` with
   `-RepoRoot`, `-SDKRoot`, the authorized `-ContractPath`, `-ManifestPath` when
   applicable, and actual `-ChangedFile` or `-ChangedFilesPath` evidence. Use
   `-Mode contract` before execution and `-Mode consumer -Strict` for the combined
   target checks. Project context defaults to `.forsetti/project-context.json`.
4. Remain within the authorized scope. Record real native build/test and runtime
   evidence required by the selected profile; static governance checks cannot
   establish application runtime correctness.
5. Deliver the changed-file list, command results, profile-mapped evidence,
   documentation/changelog, version impact, and known limits. Hand off to an
   independent Validator. Builders must not approve their own work; obtain the
   required Release Manager decision before publication or release completion.

For initial metadata setup on supported PowerShell hosts, use the external SDK's
`Tools/Initialize-Consumer.ps1 -RepositoryRoot <target> -ProjectContextPath <authored-json>`.
Use `-DryRun` first. Changed contexts, locks and managed instructions block normal
initialization; an upgrade requires `-UpgradeFromSDKRoot <verified-previous-sdk>`
and the explicit recovery workflow in `Documentation/Getting-Started.md`.

The macOS native executable supports `version`, `bundle verify`, `init`, `doctor`
and `discover`. Pass external `--bundle-root <SDK>/bundle` and explicit
`--repository-root <target>` where applicable. Native `init` writes native metadata;
the PowerShell initializer supplies the separately authored validator context.
Discovery produces observations/proposals that require review.

The Windows native router implements only `version` and `bundle verify`; a native
Windows asset is usable only when the release command matrix includes actual
Windows verification. Windows and portable consumers use the PowerShell setup
and target-validation workflow. Neither native router implements `task` commands.
`bundle verify` proves integrity, not task completion or application compliance.

Direct module coupling, direct module data sharing, undeclared capability use, private framework use, invalid manifests, and missing evidence are non-compliant.

Local instructions may narrow this section but may not weaken the pinned profile or shared Forsetti invariants.
<!-- FORSETTI-GOVERNANCE:END -->
