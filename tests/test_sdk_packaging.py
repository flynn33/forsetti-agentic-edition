import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("sdk_packaging", ROOT / "scripts/build-sdk.py")
SDK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SDK)


class SDKPackagingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory(prefix="Forsetti SDK packaging ")
        cls.base = Path(cls.temporary.name)
        cls.product, cls.archive, cls.checksum = SDK.assemble(ROOT, cls.base / "one", "portable", None, True)

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def copy_product(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        product = Path(temp.name).resolve() / "SDK with spaces"
        shutil.copytree(self.product, product)
        return product

    def test_repeatable_archive_and_complete_consumption_policy(self):
        product, archive, checksum = SDK.assemble(ROOT, self.base / "two", "portable", None, True)
        self.assertEqual(self.checksum, checksum)
        self.assertEqual(self.archive.read_bytes(), archive.read_bytes())
        self.assertEqual((ROOT / "CONSUMPTION_POLICY.md").read_bytes(), (product / "CONSUMPTION_POLICY.md").read_bytes())
        manifest = SDK.verify_sdk(product)
        self.assertEqual(SDK.digest((ROOT / "CONSUMPTION_POLICY.md").read_bytes()), manifest["consumptionPolicy"]["sha256"])
        self.assertEqual("source", SDK.verify_bundle(product / "bundle")["platform"])

    def test_explicit_payload_excludes_developer_sources_and_history(self):
        manifest = SDK.verify_sdk(self.product)
        files = {entry["path"] for entry in manifest["files"]}
        for name in files:
            self.assertFalse(any(part in {".git", ".github", ".build", "products", "Sources", "src", "tests", "wiki", "VISION.md"} for part in name.split("/")), name)
            self.assertFalse(name.startswith(".forsetti/"), name)
        self.assertIn("bundle/policies/mcp-provider-policy.json", files)
        self.assertNotIn("bin/forsetti-governance", files)
        for entry in json.loads((ROOT / "sdk/payload-map.json").read_text())["entries"]:
            self.assertEqual((ROOT / entry["source"]).read_bytes(), (self.product / entry["destination"]).read_bytes(), entry)

    def test_extracted_sdk_integrity_from_separate_directory(self):
        extracted = SDK.extract_verified_archive(self.archive, self.base / "extracted outside checkout")
        self.assertEqual(SDK.verify_sdk(extracted)["version"], (ROOT / "VERSION").read_text().strip())
        pwsh = os.environ.get("PWSH") or shutil.which("pwsh")
        self.assertIsNotNone(pwsh, "PowerShell is required for extracted-product acceptance")
        script = self.base / "verify-extracted.ps1"
        script.write_text("param([string]$SDKRoot)\n. (Join-Path $SDKRoot 'Tools/SDK-Integrity.ps1')\n$result = Test-ForsettiSDKIntegrity -SDKRoot $SDKRoot\n$result.SDKManifest.version\n")
        result = subprocess.run([pwsh, "-NoProfile", "-File", str(script), "-SDKRoot", str(extracted)], cwd=self.base, text=True, capture_output=True)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_missing_extra_tampered_and_links_are_rejected(self):
        for action in ("missing", "extra", "tamper", "link"):
            with self.subTest(action=action):
                product = self.copy_product()
                policy = product / "CONSUMPTION_POLICY.md"
                if action == "missing":
                    policy.unlink()
                elif action == "extra":
                    (product / "unapproved.txt").write_text("not allowlisted")
                elif action == "tamper":
                    policy.write_bytes(policy.read_bytes() + b"\r\nchanged\r\n")
                else:
                    policy.unlink()
                    policy.symlink_to(ROOT / "CONSUMPTION_POLICY.md")
                with self.assertRaises((ValueError, FileNotFoundError)):
                    SDK.verify_sdk(product)

    def test_duplicate_traversal_and_unsupported_manifest_rejected(self):
        for action in ("duplicate", "traversal", "unsupported"):
            with self.subTest(action=action):
                product = self.copy_product()
                path = product / "sdk-manifest.json"
                manifest = json.loads(path.read_text())
                if action == "duplicate":
                    manifest["files"].append(manifest["files"][0])
                elif action == "traversal":
                    manifest["files"][0]["path"] = "../outside.txt"
                else:
                    manifest["schemaVersion"] = "future"
                path.write_bytes(SDK.json_bytes(manifest))
                with self.assertRaises(ValueError):
                    SDK.verify_sdk(product)

    def test_zip_traversal_and_duplicate_entries_rejected_before_extraction(self):
        for action in ("traversal", "duplicate", "symlink"):
            archive = self.base / f"bad-{action}.zip"
            with zipfile.ZipFile(archive, "w") as zipped:
                if action == "traversal":
                    zipped.writestr("SDK/../../escape.txt", "bad")
                elif action == "duplicate":
                    zipped.writestr("SDK/README.md", "first")
                    zipped.writestr("SDK/readme.md", "second")
                else:
                    info = zipfile.ZipInfo("SDK/link")
                    info.create_system = 3
                    info.external_attr = 0o120777 << 16
                    zipped.writestr(info, "../../outside")
            destination = self.base / f"rejected-{action}"
            with self.assertRaises(ValueError):
                SDK.extract_verified_archive(archive, destination)
            self.assertFalse(destination.exists())

    def test_bundle_generator_rejects_unreviewed_inputs(self):
        product = self.copy_product()
        (product / "bundle/policies/unreviewed.json").write_text("{}")
        result = subprocess.run(["python3", str(ROOT / "scripts/generate-product-manifest.py"), "--bundle-root", str(product / "bundle"), "--source-root", str(ROOT)], text=True, capture_output=True)
        self.assertNotEqual(0, result.returncode)
        self.assertIn("Unapproved bundle input", result.stderr)

    def test_existing_assembly_is_not_silently_overwritten(self):
        with self.assertRaisesRegex(ValueError, "overwrite"):
            SDK.assemble(ROOT, self.base / "one", "portable", None, True)
        output = self.base / "checksum exists"
        output.mkdir()
        checksum = output / self.archive.with_suffix(".zip.sha256").name
        checksum.write_text("preserve existing checksum\n")
        with self.assertRaisesRegex(ValueError, "overwrite"):
            SDK.assemble(ROOT, output, "portable", None, True)
        self.assertEqual("preserve existing checksum\n", checksum.read_text())

    def test_internally_consistent_bundle_cannot_hide_canonical_drift(self):
        product = self.copy_product()
        source = product.parent / "canonical source"
        source.mkdir()
        mapping = json.loads((ROOT / "scripts/bundle-source-map.json").read_text())
        (source / "scripts").mkdir()
        (source / "scripts/bundle-source-map.json").write_bytes(SDK.json_bytes(mapping))
        for entry in mapping["entries"]:
            path = source / entry["source"]
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes((ROOT / entry["source"]).read_bytes())
        policy = source / "core/policies/compliance-rules.json"
        policy.write_bytes(policy.read_bytes() + b"\n")
        SDK.verify_bundle(product / "bundle")
        with self.assertRaisesRegex(ValueError, "Canonical-to-bundle drift"):
            SDK.verify_canonical_bundle(product / "bundle", source, "unused-candidate-revision", True)

    def test_bundle_generator_rejects_symlink_root_and_ancestor_before_writes(self):
        product = self.copy_product()
        for ancestor in (False, True):
            link = product.parent / ("parent-link" if ancestor else "bundle-link")
            link.symlink_to(product if ancestor else product / "bundle", target_is_directory=True)
            root = link / "bundle" if ancestor else link
            before = (product / "bundle/product-manifest.json").read_bytes()
            result = subprocess.run(["python3", str(ROOT / "scripts/generate-product-manifest.py"), "--bundle-root", str(root), "--synchronize"], text=True, capture_output=True)
            self.assertNotEqual(0, result.returncode)
            self.assertIn("Symlink bundle root or ancestor", result.stderr)
            self.assertEqual(before, (product / "bundle/product-manifest.json").read_bytes())


if __name__ == "__main__":
    unittest.main()
