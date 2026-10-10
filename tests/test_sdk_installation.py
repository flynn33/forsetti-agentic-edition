import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("sdk_installation_packaging", ROOT / "scripts/build-sdk.py")
SDK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SDK)


class SDKInstallationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pwsh = os.environ.get("PWSH") or shutil.which("pwsh")
        if not cls.pwsh:
            raise unittest.SkipTest("PowerShell 7.4+ is required for installation execution")
        cls.temporary = tempfile.TemporaryDirectory(prefix="Forsetti SDK installation ")
        cls.base = Path(cls.temporary.name)
        _, archive, _ = SDK.assemble(ROOT, cls.base / "assembly", "portable", None, True)
        cls.product = SDK.extract_verified_archive(archive, cls.base / "relocated SDK with spaces")

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def fixture(self, edition="apple"):
        temporary = tempfile.TemporaryDirectory(prefix="governed consumer ")
        self.addCleanup(temporary.cleanup)
        base = Path(temporary.name)
        target = base / "consumer application"
        target.mkdir()
        (target / ".git").mkdir()
        (target / "App.swift").write_bytes(b"// Owner application file\r\n")
        (target / "AGENTS.md").write_bytes(b"Owner rules\r\nKeep this text.\r\n")
        context = json.loads((self.product / "Templates/core/contracts/forsetti-project-context-template.json").read_text())
        if edition == "windows":
            context.update(forsetti_edition="windows", framework_version="0.2.0", target_platform="Windows",
                           edition_profile="editions/windows/forsetti-windows-0.2.0.profile.json")
        context_file = base / "authored project context.json"
        context_file.write_text(json.dumps(context), encoding="utf-8")
        return target, context_file

    def invoke(self, target, context, *arguments, product=None):
        toolkit = product or self.product
        result = subprocess.run([self.pwsh, "-NoLogo", "-NoProfile", "-File", str(toolkit / "Tools/Initialize-Consumer.ps1"),
                                 "-RepositoryRoot", str(target), "-ProjectContextPath", str(context), *arguments],
                                cwd=target.parent, capture_output=True, text=True)
        return result

    def assert_pass(self, result):
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def state(self, target):
        return {path.relative_to(target).as_posix(): path.read_bytes() for path in target.rglob("*") if path.is_file()}

    def test_dry_run_writes_nothing_then_idempotent_profile_mapping(self):
        for edition in ("apple", "windows"):
            with self.subTest(edition=edition):
                target, context = self.fixture(edition)
                before = self.state(target)
                self.assert_pass(self.invoke(target, context, "-DryRun"))
                self.assertEqual(before, self.state(target))
                self.assertFalse((target / ".forsetti").exists())
                self.assert_pass(self.invoke(target, context))
                installed = self.state(target)
                self.assert_pass(self.invoke(target, context))
                self.assertEqual(installed, self.state(target))
                self.assertEqual(before["App.swift"], installed["App.swift"])
                self.assertTrue(installed["AGENTS.md"].startswith(before["AGENTS.md"]))
                native = json.loads(installed[".forsetti/project.json"])
                governed = json.loads(installed[".forsetti/project-context.json"])
                self.assertEqual(edition, native["edition"])
                self.assertEqual(native["edition"], governed["forsetti_edition"])
                self.assertEqual(native["frameworkVersion"], governed["framework_version"])
                self.assertEqual(native["targetPlatforms"], [governed["target_platform"]])
                self.assertEqual(native["deploymentPattern"], governed["deployment_pattern"])
                self.assertNotIn("$schema", governed)
                self.assertEqual(set(installed) - set(before), {".forsetti/project.json", ".forsetti/project-context.json", ".forsetti/modules.json",
                    ".forsetti/profile.lock.json", ".forsetti/policy.lock.json", ".forsetti/product.lock.json", ".forsetti/instructions/GOVERNANCE.md"})

    def test_module_inventory_and_unmanaged_agent_text_preserved(self):
        target, context = self.fixture()
        self.assert_pass(self.invoke(target, context))
        inventory = target / ".forsetti/modules.json"
        inventory.write_bytes(b'{"schemaVersion":"2.0","modules":[{"moduleID":"com.owner.existing"}]}\r\n')
        agents = target / "AGENTS.md"
        agents.write_bytes(agents.read_bytes() + b"\r\nExtra owner instruction.\r\n")
        before = self.state(target)
        self.assert_pass(self.invoke(target, context))
        self.assertEqual(before, self.state(target))

    def test_changed_context_locks_and_managed_instructions_block_without_writes(self):
        for relative in (".forsetti/project.json", ".forsetti/project-context.json", ".forsetti/policy.lock.json",
                         ".forsetti/profile.lock.json", ".forsetti/product.lock.json", ".forsetti/instructions/GOVERNANCE.md", "AGENTS.md"):
            with self.subTest(relative=relative):
                target, context = self.fixture()
                self.assert_pass(self.invoke(target, context))
                path = target / relative
                if path.suffix == ".json":
                    data = json.loads(path.read_text())
                    data["owner_changed"] = True
                    path.write_text(json.dumps(data), encoding="utf-8")
                else:
                    path.write_bytes(path.read_bytes().replace(b"## Forsetti Governance", b"## Changed owner governance"))
                before = self.state(target)
                self.assertNotEqual(0, self.invoke(target, context).returncode)
                self.assertEqual(before, self.state(target))

    def test_malformed_blocks_and_invalid_utf8_rejected_before_metadata_writes(self):
        begin = b"<!-- FORSETTI-GOVERNANCE:BEGIN -->"
        end = b"<!-- FORSETTI-GOVERNANCE:END -->"
        for content in (begin, end + b"\n" + begin, begin + end + begin + end, b"\xff\xfe"):
            with self.subTest(content=content):
                target, context = self.fixture()
                (target / "AGENTS.md").write_bytes(content)
                before = self.state(target)
                self.assertNotEqual(0, self.invoke(target, context).returncode)
                self.assertEqual(before, self.state(target))
                self.assertFalse((target / ".forsetti").exists())

    def test_symlink_installation_paths_preserve_external_files(self):
        for relative in ("AGENTS.md", ".forsetti"):
            with self.subTest(relative=relative):
                target, context = self.fixture()
                outside = target.parent / "external owner files"
                outside.mkdir()
                (outside / "owner.txt").write_text("owner data")
                path = target / relative
                if path.exists():
                    path.unlink()
                path.symlink_to(outside if relative == ".forsetti" else outside / "owner.txt")
                self.assertNotEqual(0, self.invoke(target, context).returncode)
                self.assertEqual("owner data", (outside / "owner.txt").read_text())
                self.assertEqual(["owner.txt"], [item.name for item in outside.iterdir()])
                self.assertTrue(path.is_symlink())

    def test_parent_alias_cannot_hide_current_or_previous_sdk_inside_target(self):
        for previous in (False, True):
            with self.subTest(previous=previous):
                target, context = self.fixture()
                nested = target / "nested SDK" / "toolkit"
                shutil.copytree(self.product, nested)
                alias = target.parent / "parent alias"
                alias.symlink_to(target.parent, target_is_directory=True)
                aliased_target = alias / target.name
                before = self.state(target)
                if previous:
                    result = self.invoke(aliased_target, context, "-DryRun", "-UpgradeFromSDKRoot", str(nested))
                    self.assertIn("previous SDK must also remain outside", result.stderr)
                else:
                    result = self.invoke(aliased_target, context, "-DryRun", product=nested)
                    self.assertIn("immutable SDK outside", result.stderr)
                self.assertNotEqual(0, result.returncode)
                self.assertEqual(before, self.state(target))
                self.assertFalse((target / ".forsetti").exists())

    def test_separate_external_sdk_accepts_ordinary_parent_alias(self):
        target, context = self.fixture()
        alias = target.parent / "parent alias"
        alias.symlink_to(target.parent, target_is_directory=True)
        aliased_target = alias / target.name
        before = self.state(target)
        self.assert_pass(self.invoke(aliased_target, context, "-DryRun"))
        self.assertEqual(before, self.state(target))
        self.assert_pass(self.invoke(aliased_target, context))
        self.assertTrue((target / ".forsetti/project-context.json").is_file())

    def test_unknown_version_cross_edition_capability_and_duplicate_context_keys_rejected(self):
        for change in ("version", "capability", "duplicate"):
            with self.subTest(change=change):
                target, context = self.fixture()
                data = json.loads(context.read_text())
                if change == "version":
                    data.update(framework_version="9.9.9", edition_profile="editions/apple/forsetti-apple-9.9.9.profile.json")
                elif change == "capability":
                    data["capabilities_requested"] = ["event_publishing"]
                context.write_text(json.dumps(data), encoding="utf-8")
                if change == "duplicate":
                    context.write_text(context.read_text()[:-1] + ', "framework_version":"0.1.3"}', encoding="utf-8")
                before = self.state(target)
                self.assertNotEqual(0, self.invoke(target, context).returncode)
                self.assertEqual(before, self.state(target))
                self.assertFalse((target / ".forsetti").exists())

    def test_tampered_sdk_rejected_before_installation(self):
        target, context = self.fixture()
        copied = target.parent / "altered external SDK"
        shutil.copytree(self.product, copied)
        policy = copied / "bundle/policies/compliance-rules.json"
        policy.write_bytes(policy.read_bytes() + b"\r\nchanged bytes\r\n")
        before = self.state(target)
        result = self.invoke(target, context, product=copied)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("Altered trusted file", result.stderr)
        self.assertEqual(before, self.state(target))

    def prior_sdk_fixture(self, target):
        prior = target.parent / "verified previous SDK fixture"
        shutil.copytree(self.product, prior)
        version = "1.0.99"
        (prior / "VERSION").write_text(version + "\n")
        (prior / "bundle/VERSION").write_text(version + "\n")
        bundle_path = prior / "bundle/product-manifest.json"
        bundle = json.loads(bundle_path.read_text())
        bundle.update(version=version, bundleID=f"ffae-{version}-source")
        for entry in bundle["files"]:
            entry["sha256"] = SDK.digest((prior / "bundle" / entry["path"]).read_bytes())
        material = b"".join((entry["path"] + "\0" + entry["sha256"] + "\0").encode() for entry in sorted(bundle["files"], key=lambda item: item["path"])
                            if entry["path"].split("/")[0] in {"policies", "schemas", "editions"})
        bundle["policyBundleHash"] = hashlib.sha256(material).hexdigest()
        bundle_path.write_bytes(SDK.json_bytes(bundle))
        manifest_path = prior / "sdk-manifest.json"
        manifest = json.loads(manifest_path.read_text())
        manifest.update(version=version, bundleManifestSHA256=SDK.digest(bundle_path.read_bytes()))
        for entry in manifest["files"]:
            entry["sha256"] = SDK.digest((prior / entry["path"]).read_bytes())
        manifest_path.write_bytes(SDK.json_bytes(manifest))
        SDK.verify_sdk(prior)
        return prior

    def test_explicit_upgrade_requires_previous_locks_preserves_context_and_app(self):
        target, context = self.fixture()
        prior = self.prior_sdk_fixture(target)
        self.assert_pass(self.invoke(target, context, product=prior))
        before = self.state(target)
        self.assertNotEqual(0, self.invoke(target, context).returncode)
        self.assertEqual(before, self.state(target))
        self.assert_pass(self.invoke(target, context, "-UpgradeFromSDKRoot", str(prior), "-DryRun"))
        self.assertEqual(before, self.state(target))
        self.assert_pass(self.invoke(target, context, "-UpgradeFromSDKRoot", str(prior)))
        after = self.state(target)
        for relative in ("App.swift", ".forsetti/project.json", ".forsetti/project-context.json", ".forsetti/modules.json"):
            self.assertEqual(before[relative], after[relative], relative)
        self.assertNotEqual(before[".forsetti/product.lock.json"], after[".forsetti/product.lock.json"])
        self.assert_pass(self.invoke(target, context))
        self.assertEqual(after, self.state(target))

    @unittest.skipIf(os.name == "nt", "POSIX permissions exercise macOS/portable rollback; native Windows remains separately unverified")
    def test_partial_write_error_rolls_back_owner_agents(self):
        target, context = self.fixture()
        governance = target / ".forsetti"
        governance.mkdir()
        for directory in ("instructions", "contracts", "tasks", "evidence", "validation"):
            (governance / directory).mkdir()
        before = self.state(target)
        governance.chmod(0o555)
        try:
            result = self.invoke(target, context)
        finally:
            governance.chmod(0o755)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("rolled back", result.stderr)
        self.assertEqual(before, self.state(target))

    def test_native_metadata_can_be_mapped_without_replacing_native_outputs(self):
        executable = os.environ.get("NATIVE_CLI")
        if not executable:
            self.skipTest("NATIVE_CLI required to test native initialization mapping")
        target, context = self.fixture()
        result = subprocess.run([executable, "init", "--repository-root", str(target), "--bundle-root", str(self.product / "bundle"),
                                 "--edition", "apple", "--platform", "iOS", "--framework-version", "0.1.5", "--deployment-pattern", "single_app_module"],
                                text=True, capture_output=True)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        before = self.state(target)
        self.assert_pass(self.invoke(target, context))
        after = self.state(target)
        for relative, data in before.items():
            self.assertEqual(data, after[relative], relative)
        self.assertEqual({".forsetti/project-context.json"}, set(after) - set(before))


if __name__ == "__main__":
    unittest.main()
