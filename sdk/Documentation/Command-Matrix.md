# Command matrix

The command router sources and actual release evidence define availability. The archive's `sdk-manifest.json` records the host, architecture, prerequisites, and advertised capabilities; actual command results are recorded in release evidence. Product `1.1.0`, bundle schema `2.0`, framework profiles, and module manifest/template versions are separate values.

## SDK tools

Run these PowerShell scripts with PowerShell 7.4 or newer. They are development-time host tools; target edition selection is independent from host OS.

| Tool | Function | Evidence boundary |
| --- | --- | --- |
| `Tools/SDK-Integrity.ps1`, dot-sourced `Test-ForsettiSDKIntegrity -SDKRoot <path>` | Verify exact SDK inventory and source bundle, then return parsed metadata or throw. | Byte/path integrity, not application compliance or publisher authentication. |
| `Tools/Initialize-Consumer.ps1 -RepositoryRoot <Git-target> -ProjectContextPath <authored.json> [-SDKRoot <path>] [-DryRun] [-UpgradeFromSDKRoot <verified-prior-SDK>]` | Create approved metadata and manage project instructions from an explicit context. | Setup, not task authorization, runtime integration, or independent approval. |
| `Tools/Validate-Consumer.ps1 -RepoRoot <target> -Mode <target-mode> ... [-Strict]` | Verify toolkit and locks, then validate the separate target using trusted resources. | Static target checks plus supplied evidence; independent review and native runtime evidence remain required. |

Target modes are `consumer`, `contract`, `project-context`, `edition-profile`, `manifest`, `dependencies`, `capabilities`, `module-isolation`, and `evidence`. `consumer` combines target checks without maintainer `repo`/`all` modes. Supply `-ContractPath`, `-ProjectContextPath`, `-ManifestPath` when applicable, `-ChangedFilesPath`, and optionally `-OutputJson` as shown in [Getting Started](Getting-Started.md).

`core/validator/forsetti_validate.ps1` retains direct target modes and maintainer `repo`/`all`. Direct use separates `-RepoRoot` (target), `-SDKRoot` (installed toolkit), and `-BundleRoot` (trusted bundle). Consumers should use the wrapper, which verifies delivery assets and reconciles generated pins before target checks. Maintainer modes require upstream repository structure and are not downstream onboarding commands.

## Native host router

| Command | macOS arm64 SDK | Windows native source | Meaning |
| --- | --- | --- | --- |
| `version` | Included host command | Implemented; executable omitted pending Windows evidence | Reports Agentic product version. |
| `bundle verify --bundle-root <SDK/bundle>` | Included host command | Implemented; executable omitted pending Windows evidence | Checks internal bundle integrity. |
| `init --repository-root <target> --bundle-root <SDK/bundle> --edition <edition> --platform <platform> --framework-version <version> --deployment-pattern <pattern> [--dry-run]` | Included host command | Unsupported | Native bootstrap metadata/instruction plan; does not fabricate full validator context. |
| `doctor --repository-root <target> --bundle-root <SDK/bundle>` | Included host command | Unsupported | Inspect native bootstrap records/pins. |
| `discover --repository-root <target> --bundle-root <SDK/bundle> [--output <file>]` | Included host command | Unsupported | Inspect project structure and report reconciliation findings. |
| `task status`, `task begin`, `task check`, `task submit`, `task validate`, `task complete` | Unsupported | Unsupported | No task orchestration engine is provided. |

Example macOS native invocations, with the SDK and target set to absolute paths:

```powershell
& "$SDK/bin/forsetti-governance" version
& "$SDK/bin/forsetti-governance" bundle verify --bundle-root "$SDK/bundle"
& "$SDK/bin/forsetti-governance" init --repository-root $Target `
  --bundle-root "$SDK/bundle" --edition apple --platform iOS `
  --framework-version 0.1.5 --deployment-pattern single_app_module --dry-run
& "$SDK/bin/forsetti-governance" doctor --repository-root $Target --bundle-root "$SDK/bundle"
& "$SDK/bin/forsetti-governance" discover --repository-root $Target --bundle-root "$SDK/bundle"
```

`doctor` expects initialized metadata. Discovery may return reconciliation findings rather than a clean pass. Preserve reported outcomes. Unsupported commands must return a non-success result; do not substitute invented successful task commands. The supported governance workflow uses authorized contracts, actual evidence, PowerShell target checks, and independent handoff.

No native Windows readiness is claimed from macOS or Linux C++ execution. No portable executable is implied by the portable archive name. Use [Compatibility](Compatibility.md) and the exact asset's evidence to distinguish source availability, tested host execution, and target-profile coverage.
