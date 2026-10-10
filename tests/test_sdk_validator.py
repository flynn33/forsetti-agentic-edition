"""Execute consumer validation with only an external SDK and temporary targets."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PWSH = os.environ.get("PWSH") or shutil.which("pwsh")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def assemble_validator_sdk(destination: Path) -> None:
    """Small explicit integrity fixture; full release-map tests live in packaging tests."""
    files = [
        ("core/validator/forsetti_validate.ps1", "core/validator/forsetti_validate.ps1"),
        ("core/validator/contract_rules.ps1", "core/validator/contract_rules.ps1"),
        ("core/validator/sdk_integrity.ps1", "core/validator/sdk_integrity.ps1"),
        ("core/validator/rules/forsetti_project_rules.ps1", "core/validator/rules/forsetti_project_rules.ps1"),
        ("sdk/Tools/Validate-Consumer.ps1", "Tools/Validate-Consumer.ps1"),
        ("sdk/Tools/SDK-Integrity.ps1", "Tools/SDK-Integrity.ps1"),
        ("CONSUMPTION_POLICY.md", "CONSUMPTION_POLICY.md"),
        ("bundle/VERSION", "VERSION"),
    ]
    files += [("core/schemas/" + name, "core/schemas/" + name) for name in ("forsetti-project-context.schema.json", "module-manifest-1.1.schema.json", "task-contract.schema.json", "edition-profile.schema.json")]
    files += [(p.relative_to(ROOT).as_posix(), p.relative_to(ROOT).as_posix()) for p in sorted((ROOT / "bundle").rglob("*")) if p.is_file()]
    for source, relative in files:
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / source, target)
    write_json(destination / "payload-map.json", {"schemaVersion": "1.0", "entries": [{"source": s, "destination": d} for s, d in files]})
    bundle = json.loads((destination / "bundle/product-manifest.json").read_text())
    revision = "1" * 40
    write_json(destination / "sdk-manifest.json", {
        "schemaVersion": "1.0", "product": "Forsetti Agentic Edition SDK", "version": bundle["version"],
        "sourceRevision": revision, "variant": "portable", "bundleManifestSHA256": digest(destination / "bundle/product-manifest.json"),
        "consumptionPolicy": {"sourcePath": "CONSUMPTION_POLICY.md", "sourceRevision": revision, "sha256": digest(destination / "CONSUMPTION_POLICY.md")},
        "files": [{"path": p.relative_to(destination).as_posix(), "sha256": digest(p)} for p in sorted(destination.rglob("*")) if p.is_file()],
        "generatedDestinations": ["AGENTS.md", ".forsetti/project.json", ".forsetti/modules.json", ".forsetti/project-context.json", ".forsetti/profile.lock.json", ".forsetti/policy.lock.json", ".forsetti/product.lock.json", ".forsetti/instructions/GOVERNANCE.md"],
    })


def create_consumer(target: Path, sdk: Path, edition="apple", framework=None) -> dict:
    framework = framework or ("0.1.5" if edition == "apple" else "0.2.0")
    platform = "macOS" if edition == "apple" else "Windows"
    context = json.loads((ROOT / "core/contracts/forsetti-project-context-template.json").read_text())
    context.pop("$schema")
    context.update(repository_mode="module_repo", forsetti_edition=edition, target_platform=platform, framework_version=framework,
                   edition_profile=f"editions/{edition}/forsetti-{edition}-{framework}.profile.json", module_type="service", module_id="com.example.service")
    write_json(target / ".forsetti/project-context.json", context)
    bundle = json.loads((sdk / "bundle/product-manifest.json").read_text())
    version = bundle["version"]
    profile_hash = digest(sdk / "bundle" / context["edition_profile"])
    write_json(target / ".forsetti/project.json", {
        "schemaVersion": "2.0", "repositoryType": "module_repository", "edition": edition, "targetPlatforms": [platform],
        "frameworkVersion": framework, "deploymentPattern": context["deployment_pattern"], "modulesPath": ".forsetti/modules.json",
        "profileLockPath": ".forsetti/profile.lock.json", "policyLockPath": ".forsetti/policy.lock.json", "productLockPath": ".forsetti/product.lock.json",
    })
    write_json(target / ".forsetti/modules.json", {"schemaVersion": "2.0", "modules": []})
    write_json(target / ".forsetti/profile.lock.json", {"schemaVersion": "2.0", "profileID": f"forsetti-{edition}-{framework}", "profileVersion": version,
                                                     "frameworkVersion": framework, "sourceRevision": profile_hash, "sha256": profile_hash, "supportStatus": "supported"})
    write_json(target / ".forsetti/policy.lock.json", {"schemaVersion": "2.0", "policyBundleID": f"ffae-policy-{version}", "policyBundleVersion": version, "sha256": bundle["policyBundleHash"]})
    write_json(target / ".forsetti/product.lock.json", {"schemaVersion": "2.0", "productVersion": version, "bundleID": bundle["bundleID"], "platform": f"{edition}-host", "sha256": digest(sdk / "bundle/product-manifest.json")})
    manifest = {"schemaVersion": "1.1", "manifestTemplateVersion": "1.1", "moduleID": "com.example.service", "displayName": "Example Service",
                "moduleVersion": {"major": 1, "minor": 0, "patch": 0}, "moduleType": "service", "supportedPlatforms": [platform],
                "minForsettiVersion": {"major": 0, "minor": int(framework.split('.')[1]), "patch": int(framework.split('.')[2])},
                "capabilitiesRequested": [], "entryPoint": "Example.ServiceModule",
                "iapProductID": None, "maxForsettiVersion": None, "defaultModuleRole": None,
                "runtimeRequirements": {"io": [], "ui": None, "dataIsolation": {"mode": "private_to_module", "ownedStoreIDs": [], "requiredDefaultRoles": []}}}
    write_json(target / "ModuleManifest.json", manifest)
    contract = json.loads((ROOT / "core/contracts/task-contract-template.json").read_text())
    contract.update(task_id="FAE-TASK-2026-10-10-001", title="Fixture authorized task", date="2026-10-10", forsetti_project_context=context)
    contract["scope"] = {"in_scope": ["Sources/Example.swift", "src/Example.cpp"], "out_of_scope": []}
    contract["required_outputs"] = ["Sources/Example.swift" if edition == "apple" else "src/Example.cpp"]
    contract["documentation_impact"].update(changelog_update=False, rationale="Temporary validation fixture task has no substantive release change.")
    write_json(target / "task.json", contract)
    source = contract["required_outputs"][0]
    (target / source).parent.mkdir(parents=True, exist_ok=True)
    (target / source).write_text("import ForsettiCore\nstruct Example {}\n" if edition == "apple" else "#include <ForsettiCore/Public.hpp>\nstruct Example {};\n")
    (target / "changed-files.txt").write_text(source + "\n")
    return context


@unittest.skipUnless(PWSH, "PowerShell 7.4+ required; set PWSH to the executable")
class SDKValidatorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="Forsetti validator ")
        self.base = Path(self.temp.name)
        self.sdk = self.base / "external SDK [trusted]"
        self.target = self.base / "consumer [project]"
        assemble_validator_sdk(self.sdk)
        self.context = create_consumer(self.target, self.sdk)

    def tearDown(self):
        self.temp.cleanup()

    def execute(self, *, core=False, **overrides):
        script = self.sdk / ("core/validator/forsetti_validate.ps1" if core else "Tools/Validate-Consumer.ps1")
        arguments = {"RepoRoot": self.target, "SDKRoot": self.sdk, "Mode": "consumer", "ContractPath": "task.json", "ProjectContextPath": ".forsetti/project-context.json",
                     "ManifestPath": "ModuleManifest.json", "ChangedFilesPath": "changed-files.txt", "OutputJson": "result.json"}
        arguments.update(overrides)
        command = [PWSH, "-NoProfile", "-File", str(script), "-Strict"]
        for key, value in arguments.items():
            if value is not None:
                command.extend(["-" + key, str(value)])
        result = subprocess.run(command, cwd=self.base, capture_output=True, text=True, timeout=45)
        self.last_result = result
        return result

    def mutate_json(self, relative, update):
        path = self.target / relative
        value = json.loads(path.read_text())
        update(value)
        write_json(path, value)

    def assert_block(self, result, text=None):
        self.assertNotEqual(0, result.returncode, result.stdout + result.stderr)
        if text:
            self.assertIn(text, result.stdout + result.stderr)

    def test_apple_windows_and_explicit_compatibility_profile(self):
        for edition, framework in [("apple", "0.1.5"), ("apple", "0.1.3"), ("windows", "0.2.0")]:
            with self.subTest(edition=edition, framework=framework):
                create_consumer(self.target, self.sdk, edition, framework)
                result = self.execute()
                self.assertEqual(0, result.returncode, result.stdout + result.stderr)
                report = json.loads((self.target / "result.json").read_text())
                self.assertEqual("pass", report["status"])
                self.assertEqual(str(self.target), report["invocation"]["repo_root"])
                self.assertFalse((self.target / "core").exists())
                self.assertFalse((self.target / "products").exists())

    def test_full_contract_scope_is_enforced(self):
        self.mutate_json("task.json", lambda obj: obj["scope"].update(in_scope=["elsewhere/**"]))
        self.assert_block(self.execute(), "FAE-C002")

    def test_contract_required_fields_and_context_equality(self):
        self.mutate_json("task.json", lambda obj: obj.pop("objective"))
        self.assert_block(self.execute(), "FAE-C001")
        create_consumer(self.target, self.sdk)
        self.mutate_json("task.json", lambda obj: obj["forsetti_project_context"].update(module_id="com.example.other"))
        self.assert_block(self.execute(), "FAE-F001")

    def test_unknown_framework_and_invalid_context(self):
        self.mutate_json(".forsetti/project-context.json", lambda obj: obj.update(framework_version="9.9.9", edition_profile="editions/apple/forsetti-apple-9.9.9.profile.json"))
        self.assert_block(self.execute())
        create_consumer(self.target, self.sdk)
        self.mutate_json(".forsetti/project-context.json", lambda obj: obj.update(uses_public_api_only="true"))
        self.assert_block(self.execute(), "canonical schema")

    def test_cross_edition_capability_and_undeclared_use(self):
        self.mutate_json(".forsetti/project-context.json", lambda obj: obj.update(capabilities_requested=["event_publishing"]))
        self.mutate_json("task.json", lambda obj: obj["forsetti_project_context"].update(capabilities_requested=["event_publishing"]))
        self.mutate_json("ModuleManifest.json", lambda obj: obj.update(capabilitiesRequested=["event_publishing"]))
        self.assert_block(self.execute(), "FAE-F009")
        create_consumer(self.target, self.sdk)
        (self.target / "Sources/Example.swift").write_text("import ForsettiCore\nlet client = NetworkingService()\n")
        self.assert_block(self.execute(), "FAE-F009")

    def test_windows_event_capability_remains_edition_specific(self):
        create_consumer(self.target, self.sdk, "windows")
        self.mutate_json(".forsetti/project-context.json", lambda obj: obj.update(capabilities_requested=["event_publishing"]))
        self.mutate_json("task.json", lambda obj: obj["forsetti_project_context"].update(capabilities_requested=["event_publishing"]))
        self.mutate_json("ModuleManifest.json", lambda obj: obj.update(capabilitiesRequested=["event_publishing"]))
        (self.target / "src/Example.cpp").write_text("void publishEvent();\n")
        result = self.execute()
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_invalid_manifest_and_service_ui(self):
        self.mutate_json("ModuleManifest.json", lambda obj: obj.update(schemaVersion="9.9"))
        self.assert_block(self.execute(), "manifest 1.1 schema")
        create_consumer(self.target, self.sdk)
        self.mutate_json("ModuleManifest.json", lambda obj: obj["runtimeRequirements"].update(ui={}))
        self.assert_block(self.execute())

    def test_private_import_copied_framework_and_dependency_direction(self):
        (self.target / "Sources/Example.swift").write_text("import ForsettiModulesExample\n")
        self.assert_block(self.execute(), "FAE-F013")
        create_consumer(self.target, self.sdk)
        copied = self.target / "Sources/ForsettiCore/Copy.swift"
        copied.parent.mkdir(parents=True)
        copied.write_text("import SwiftUI\n")
        (self.target / "changed-files.txt").write_text("Sources/ForsettiCore/Copy.swift\n")
        self.mutate_json("task.json", lambda obj: obj["scope"].update(in_scope=["Sources/**"]))
        self.assert_block(self.execute(), "FAE-F013")

    def test_direct_module_coupling(self):
        (self.target / "Sources/Example.swift").write_text("let directModule = OtherModule()\n")
        self.assert_block(self.execute(), "FAE-F006")

    def test_missing_empty_nonexistent_and_escaping_evidence(self):
        for evidence in [None, "", "does-not-exist.txt", "../escape.txt"]:
            with self.subTest(evidence=evidence):
                if evidence is None:
                    result = self.execute(ChangedFilesPath=None)
                else:
                    (self.target / "changed-files.txt").write_text(evidence + "\n")
                    result = self.execute()
                self.assert_block(result)

    def test_corrupted_locks_rejected_without_repinning(self):
        for relative in [".forsetti/profile.lock.json", ".forsetti/policy.lock.json", ".forsetti/product.lock.json"]:
            with self.subTest(relative=relative):
                create_consumer(self.target, self.sdk)
                self.mutate_json(relative, lambda obj: obj.update(sha256="0" * 64))
                before = (self.target / relative).read_bytes()
                self.assert_block(self.execute(), "lock differs")
                self.assertEqual(before, (self.target / relative).read_bytes())

    def test_sdk_tamper_extra_missing_and_duplicate_json_fail_before_validation(self):
        policy = self.sdk / "bundle/policies/capability-rules.json"
        original = policy.read_bytes()
        policy.write_bytes(original.replace(b"\n", b"\r\n"))
        self.assert_block(self.execute(), "Altered trusted file")
        policy.write_bytes(original)
        extra = self.sdk / "unexpected.txt"
        extra.write_text("unreviewed payload")
        self.assert_block(self.execute(), "Unexpected trusted file")
        extra.unlink()
        policy.unlink()
        self.assert_block(self.execute(), "Missing trusted file")
        policy.write_bytes(original)
        path = self.sdk / "sdk-manifest.json"
        path.write_text(path.read_text().replace('"schemaVersion": "1.0",', '"schemaVersion": "1.0", "schemaVersion": "1.0",', 1))
        self.assert_block(self.execute(), "Duplicate JSON property")

    def test_direct_installed_validator_also_checks_sdk(self):
        (self.sdk / "CONSUMPTION_POLICY.md").write_text("tampered")
        self.assert_block(self.execute(core=True), "FAE-C011")

    def test_inventory_duplicate_traversal_and_symlinks_rejected(self):
        manifest_path = self.sdk / "sdk-manifest.json"
        original = manifest_path.read_bytes()
        for path in ["VERSION", "../outside", "bundle/../VERSION", "C:/escape", "bundle/CON.json", "bundle/trailing.", "bundle/trailing "]:
            with self.subTest(path=path):
                obj = json.loads(original)
                obj["files"].append({"path": path, "sha256": "0" * 64})
                write_json(manifest_path, obj)
                self.assert_block(self.execute())
        manifest_path.write_bytes(original)
        file = self.sdk / "VERSION"
        original_version = file.read_bytes()
        outside = self.base / "outside-version"
        outside.write_bytes(original_version)
        file.unlink()
        file.symlink_to(outside)
        self.assert_block(self.execute(), "Links are not allowed")

    def test_source_profile_mode_stays_supported(self):
        result = subprocess.run([PWSH, "-NoProfile", "-File", str(ROOT / "core/validator/forsetti_validate.ps1"), "-RepoRoot", str(ROOT), "-Mode", "edition-profile", "-Strict"], capture_output=True, text=True, timeout=30)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_sdk_payload_source_traversal_rejected(self):
        path = self.sdk / "payload-map.json"
        value = json.loads(path.read_text())
        value["entries"][0]["source"] = "../escape"
        write_json(path, value)
        manifest = json.loads((self.sdk / "sdk-manifest.json").read_text())
        for entry in manifest["files"]:
            if entry["path"] == "payload-map.json":
                entry["sha256"] = digest(path)
        write_json(self.sdk / "sdk-manifest.json", manifest)
        self.assert_block(self.execute(), "Unsafe trusted inventory path")

    def test_nested_and_symlink_target_rejected(self):
        self.assert_block(self.execute(RepoRoot=self.base), "must not overlap")
        self.assert_block(self.execute(RepoRoot=self.sdk / "bundle"), "must not overlap")
        alias = self.base / "target alias"
        alias.symlink_to(self.target, target_is_directory=True)
        self.assert_block(self.execute(RepoRoot=alias), "Links are not allowed")
        parent_alias = self.base / "parent alias"
        parent_alias.symlink_to(self.base, target_is_directory=True)
        self.assert_block(self.execute(RepoRoot=parent_alias / self.sdk.name / "bundle"), "must not overlap")
        self.assert_block(self.execute(RepoRoot=parent_alias), "must not overlap")

    def test_validator_report_cannot_escape_or_overwrite_application_files(self):
        application = self.target / "Sources/Example.swift"
        before = application.read_bytes()
        self.assert_block(self.execute(OutputJson="Sources/Example.swift"))
        self.assertEqual(before, application.read_bytes())
        self.assert_block(self.execute(OutputJson=str(self.sdk / "new-report.json")), "must belong to the target")
        self.assertFalse((self.sdk / "new-report.json").exists())
        alias = self.base / "report parent alias"
        alias.symlink_to(self.base, target_is_directory=True)
        self.assert_block(self.execute(core=True, OutputJson=str(alias / self.sdk.name / "new-report.json")), "must not alter the immutable SDK")
        self.assertFalse((self.sdk / "new-report.json").exists())
        for relative in [".forsetti/project-context.json", ".forsetti/profile.lock.json", "task.json", "ModuleManifest.json"]:
            with self.subTest(relative=relative):
                before = (self.target / relative).read_bytes()
                self.assert_block(self.execute(OutputJson=relative), "must not replace")
                self.assertEqual(before, (self.target / relative).read_bytes())

    def test_contract_schemas_are_bound_locally_and_input_cannot_select_a_remote_rule(self):
        self.mutate_json("task.json", lambda obj: obj.update({"$schema": "https://invalid.example/unused-schema.json"}))
        result = self.execute()
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        self.mutate_json("task.json", lambda obj: obj.update({"$ref": "https://invalid.example/remote-rule.json"}))
        self.assert_block(self.execute(), "trusted canonical schema")

    def test_maintainer_core_ast_distinguishes_policy_data_from_invocations(self):
        result = subprocess.run([PWSH, "-NoProfile", "-File", str(ROOT / "core/validator/forsetti_validate.ps1"), "-RepoRoot", str(ROOT), "-Mode", "repo", "-Strict"], capture_output=True, text=True, timeout=30)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        fixture = self.base / "maintainer fixture"
        (fixture / "core").mkdir(parents=True)
        (fixture / "FORSETTI_CONSTITUTION.md").write_text("fixture")
        report = self.base / "maintainer-report.json"
        for invocation in ["& 'gh' version", "Start-Process -FilePath 'gh' -ArgumentList 'version'", "Start-Process -FilePath:'gh' -Wait", "Start-Process 'gh' -ArgumentList 'version'", "Start-Process -Wait 'gh' -ArgumentList 'version'", "Start-Process -ArgumentList 'version' -Wait 'gh'", "[System.Diagnostics.Process]::Start('gh', 'version')", "Start-Process -FilePath 'adapters/github-actions/workflows/script.ps1'", "[System.Diagnostics.Process]::Start('adapters/github-actions/workflows/script.ps1')", "& pwsh -File 'adapters/github-actions/workflows/sync-wiki-pages.ps1'", "& pwsh -f 'adapters/github-actions/workflows/sync-wiki-pages.ps1'", "& pwsh -NoProfile 'adapters/github-actions/workflows/sync-wiki-pages.ps1'", "& powershell -File:'adapters/github-actions/workflows/sync-wiki-pages.ps1'", "Start-Process -FilePath 'pwsh' -ArgumentList @('-NoProfile', '-File', 'adapters/github-actions/workflows/sync-wiki-pages.ps1')", "[System.Diagnostics.Process]::Start('pwsh', '-File adapters/github-actions/workflows/sync-wiki-pages.ps1')"]:
            with self.subTest(invocation=invocation):
                (fixture / "core/injected.ps1").write_text("# policy data cannot disguise an actual invocation\n" + invocation + "\n")
                result = subprocess.run([PWSH, "-NoProfile", "-File", str(ROOT / "core/validator/forsetti_validate.ps1"), "-RepoRoot", str(fixture), "-Mode", "repo", "-Strict", "-OutputJson", str(report)], capture_output=True, text=True, timeout=30)
                self.assert_block(result, "Core invokes a hosted or local-tool dependency")
                findings = json.loads(report.read_text())["findings"]
                matching = [f for f in findings if f["message"] == "Core invokes a hosted or local-tool dependency."]
                self.assertEqual(1, len(matching))
                self.assertIn("core/injected.ps1:2", matching[0]["evidence"][0])
        (fixture / "core/injected.ps1").write_text("$documentation = 'gh docker Invoke-WebRequest adapters/github-actions/workflows'\nStart-Process -FilePath 'pwsh' -ArgumentList 'gh'\n")
        subprocess.run([PWSH, "-NoProfile", "-File", str(ROOT / "core/validator/forsetti_validate.ps1"), "-RepoRoot", str(fixture), "-Mode", "repo", "-Strict", "-OutputJson", str(report)], capture_output=True, text=True, timeout=30)
        boundary = [f for f in json.loads(report.read_text())["findings"] if f["message"].startswith("Core script invocations")]
        self.assertEqual(1, len(boundary))
        self.assertEqual("pass", boundary[0]["decision"])


if __name__ == "__main__":
    unittest.main()
