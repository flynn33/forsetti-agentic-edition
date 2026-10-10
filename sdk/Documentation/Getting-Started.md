# Getting started

Use an independent application or module repository and an external SDK installation. Read the complete [consumption policy](../CONSUMPTION_POLICY.md), [SDK instructions](../AGENTS.md), and [compatibility guide](Compatibility.md). The SDK does not add an application runtime dependency or contain either runtime framework.

## 1. Extract and verify

Extract the archive into a versioned directory outside the target repository. Verify its archive checksum against the release's `SHA256SUMS` before use. PowerShell 7.4 or newer is required for the SDK tools and target validator on every host. The portable archive contains no native executable.

In PowerShell, use quoted absolute paths, including paths with spaces:

```powershell
$SDK = '/path with spaces/Forsetti-Agentic-SDK-1.2.0-portable'
$Target = '/path/to/MyApplication'
. "$SDK/Tools/SDK-Integrity.ps1"
Test-ForsettiSDKIntegrity -SDKRoot $SDK | Out-Null
```

The SDK inventory and internal bundle inventory must pass. Missing, altered, extra, duplicate, unsafe, or escaping paths are failures. Preserve the release bytes; do not regenerate hashes after a failure. Integrity checks do not authenticate the publisher or approve the application.

## 2. Author real project context

Use `Templates/core/contracts/forsetti-project-context-template.json` as input to author a project-specific context JSON file. Select a supported edition/version explicitly and fill in the target platform, repository mode, deployment/module identity, capabilities, runtime requirements, public API use, and framework-internals status. The template's sample values are not a validated selection. Keep the context input in a path authorized by the project's contract; the examples below use an external input.

The target must already be a Git repository. Keep its real application files and build configuration under its own ownership. Toolkit installation does not create a shipping application or obtain the runtime framework.

```powershell
$Context = '/path/to/authored-project-context.json'
& "$SDK/Tools/Initialize-Consumer.ps1" -SDKRoot $SDK `
  -RepositoryRoot $Target -ProjectContextPath $Context -DryRun
```

Review the proposed paths and selection. When they match the authorized target, run the same command without `-DryRun`:

```powershell
& "$SDK/Tools/Initialize-Consumer.ps1" -SDKRoot $SDK `
  -RepositoryRoot $Target -ProjectContextPath $Context
```

Setup generates `.forsetti/project.json`, `modules.json`, `project-context.json`, `profile.lock.json`, `policy.lock.json`, `product.lock.json`, and `instructions/GOVERNANCE.md`; it manages one marked section in project `AGENTS.md` and creates empty contract/task/evidence/validation directories. The native project record uses schema `2.0`; the validator context has a separate schema and additional module/capability fields. Both derive from the supplied selection. Do not pass `project.json` as validator context.

## 3. Create a governing contract and validate the target

Instantiate an approved JSON or Markdown contract from `Templates/` with real scope, authority, roles, evidence requirements, and acceptance criteria before meaningful work. JSON contracts are the structured template format. Do not copy completed upstream work or invent approval evidence.

Use [Governance Workflow](Governance-Workflow.md) to prepare actual changed-file and execution evidence, run target checks, and hand work to independent reviewers. The following call illustrates the combined target workflow; use an actual authorized contract and actual target manifest:

```powershell
& "$SDK/Tools/Validate-Consumer.ps1" -RepoRoot $Target -Mode consumer `
  -ContractPath "$Target/.forsetti/contracts/TASK.json" `
  -ProjectContextPath "$Target/.forsetti/project-context.json" `
  -ManifestPath "$Target/Resources/ForsettiManifests/MyModule.json" `
  -ChangedFilesPath "$Target/.forsetti/evidence/changed-files.txt" `
  -OutputJson "$Target/.forsetti/validation/consumer-validation.json" -Strict
```

Validation reports must belong to the target. Use a target-owned JSON report path; the wrapper rejects overwriting application inputs, governance metadata, contracts, manifests, or changed-file evidence. It may replace an existing recognized validator report.

An application/module context requires its manifest. Omit `-ManifestPath` only when the authored context's module type is `not_applicable`. Target validation is static and evidence-driven; run the selected profile's native application checks separately.

## 4. Repeat runs, conflicts, upgrades, and recovery

Repeat setup with the same verified SDK and authored selection. It must preserve unrelated agent text and application files. A dry run makes no writes. Changed project context, conflicting pins, duplicate or malformed instruction markers, unsafe paths, and unrecognized local state are conflicts; inspect and reconcile them instead of using overwrite shortcuts.

For a deliberate SDK upgrade, retain the verified previous installation and review the new plan:

```powershell
& "$SDK/Tools/Initialize-Consumer.ps1" -SDKRoot $SDK `
  -RepositoryRoot $Target -ProjectContextPath $Context `
  -UpgradeFromSDKRoot '/path/to/previous-verified-SDK' -DryRun
```

Proceed without `-DryRun` only after the approved upgrade matches the target's existing records. This is an explicit repin; selecting a new product version does not authorize a different framework profile. Preserve project-edited context and module records; reconcile any reported conflict through the project's contract workflow.

Before installation or upgrade, retain a recoverable copy of the affected metadata and `AGENTS.md`. Writes are bounded and staged with rollback on reported errors. A process interruption can still require manual recovery: inspect all planned destinations, restore the reviewed backup where necessary, verify SDK integrity, rerun a dry run, then rerun target checks. Do not report an interrupted installation as successful or fabricate validation records.

The macOS native `init`, `doctor`, and `discover` commands are optional host inspection/bootstrap surfaces described in [Command Matrix](Command-Matrix.md). Native `init` does not create the full validator context; use the SDK initializer with the authored context to reconcile native output. Windows source lacks those native commands and no Windows executable is included in this release's assets.
