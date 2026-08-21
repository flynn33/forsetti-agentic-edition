import hashlib
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

APPLE_015_PROFILE = "editions/apple/forsetti-apple-0.1.5.profile.json"
APPLE_013_PROFILE = "editions/apple/forsetti-apple-0.1.3.profile.json"
WINDOWS_PROFILE = "editions/windows/forsetti-windows-0.2.0.profile.json"

EXPECTED_SOURCE_HASHES = {
    "version.txt": "800cf1c0392b24de7c0a1c6ea6778ecb433dec71c49a150bce96a98477527b2f",
    "Package.swift": "fe1a7e792e0721b197b235f2af6b38a6605ca6055ea2889e27fe5141444d4048",
    "framework-policy.json": "4c6e5a8085cafc7e29d57452e20bc10f3b05b6cf3f4f0e8590a2ef086bd3d0fe",
    "implementation-policy.json": "497142ae586513aaed91c440f0b6c3f236436d9c3478de175c228b223e8b3ba4",
    "REPOSITORY_RULES.md": "93a86c612168fdaa117d6a46609cc2e22cc431a1fb3050b9d787b5b74a2454e3",
    "MODULE_BOUNDARY_RULES.md": "6a4c04b03efdf3b3ccb709a6612a55730aa87a0359c32793ba4768bb719d5fa7",
    "developer-guide.md": "6ea23a441cc8d910c276c11dbb023aab2e29eb609a1e42f5f583b8001e395133",
    "xcode-template-guide.md": "d8dd9fccd323bb0acedf8076a65679516bc5e1a95f3764c60ec2dc5fc3dd68ea",
    ".forsetti/alignment/final-report.json": "3f41614d90e9dea55618a3acf90fec750d5361a62d997020864e2fe623952ede",
    "Sources/ForsettiCore/Model/SemVer.swift": "5d74b0a0dbf877c98128bf5f45906cf9f5e3f52e2767275ab4b3467f162a0843",
    "Sources/ForsettiCore/Model/ModuleModels.swift": "0df75b0b1f34d10847420d8f20b7e6edc66c14026bbc0c0003f08fbbe30da80d",
    "Sources/ForsettiCore/Protocols/ForsettiProtocols.swift": "d8411b2693b6076a007b55cdd6c0c8937b936c6b8e9179d8fe8cf60065cad2d2",
    "Sources/ForsettiCore/Runtime/CompatibilityChecker.swift": "31957a5645fe2f15a1311264ac95455a7654e99c97cf40886c63ebaf343fb206",
    "Sources/ForsettiCore/Runtime/ForsettiContext.swift": "ae971699b7fc4da43b9749dc2ae302064795aaadb8c1c2fe306eccaf7f52f457",
    "Sources/ForsettiCore/Runtime/ForsettiRuntime.swift": "ff8a60932b83ff6b2d4e00d056cdc22f81301ba35732655a71cdc1a8e137f565",
    "Sources/ForsettiCore/Runtime/ManifestLoader.swift": "ecb45b44864f4d8eb1793438540c0f99813978e49e2430daf3dd904603e440b9",
    "Sources/ForsettiCore/Runtime/ModuleManager.swift": "f0a063058343b14a0726d1909baca8893c136cb2dc02587dc1570c1ab95ede0c",
    "Sources/ForsettiCore/Runtime/ModuleManager+UIValidation.swift": "09338f3c943954971ce3c6839e0ae69882ad59c63e0b64d3444e7a4cae5381ad",
    "Sources/ForsettiCore/Runtime/ModuleRegistrationStore.swift": "c58fecfcfaa057716d6f0bce212b5d3001fa462400ec8c3c34381497a4f5dc85",
    "Sources/ForsettiCore/Runtime/ModuleRegistry.swift": "68926805f8a23c027956b390a1da08fed097229d318d0081cd4c16f5a20dbc0d",
    "Sources/ForsettiCore/Services/ForsettiServices.swift": "29104723672f6c9e4f68e402b0601a4cd6959d27678238d3203cb48d68e4f2db",
    "Sources/ForsettiCore/UI/UISurfaceManager.swift": "d75be686940f9031c860f9eb8757c17c971343a948ebe74db2dd245f82fb04cf",
    "Sources/ForsettiHostTemplate/Controller/ForsettiHostController.swift": "20e03f98598567aeba10e15b66e31a72e40e59c63c8d3ce3b30a09ba8984a8e7",
    "Sources/ForsettiHostTemplate/Controller/ForsettiHostTemplateBootstrap.swift": "11a3d86fe5cc0109283b0f3d48c2b0380b028f6e863fa3ba9cc1f76faf31b08b",
    "Tests/ForsettiArchitectureTests/ArchitectureEnforcementTests.swift": "533d05b0a0fc9c5cd913962cda9da24e197aa10a179ec44c111dd371472c9688",
    "XcodeTemplates/Project Templates/Forsetti/Forsetti App.xctemplate/AppModuleManifest.json": "c26225a4c6f69a5e9134ecfd0326893f67b1f9a2cf54a7e893d9014fd9f2a769",
    "XcodeTemplates/Project Templates/Forsetti/Forsetti App.xctemplate/ForsettiBootstrap.swift": "9d1e6d07a66fd1b7a46123480ace0b0fc73f43239f008c7ad5a30046db42f94a",
    "XcodeTemplates/Project Templates/Forsetti/Forsetti Service Module.xctemplate/ServiceModuleManifest.json": "ed4a28a351092a6d40753d2f5e4f4984e3bc02f5e70a23d812229bbda84dae2e",
    "XcodeTemplates/Project Templates/Forsetti/Forsetti UI Module.xctemplate/UIModuleManifest.json": "559712e2f6fbc9fd425c8f95b7a65c04c0a6b31d15a08011107f4ab74ceaf00f"
}

EXPECTED_APPLE_CAPABILITIES = {
    "networking",
    "storage",
    "secure_storage",
    "file_export",
    "crypto_utilities",
    "telemetry",
    "routing_overlay",
    "ui_theme_mask",
    "toolbar_items",
    "view_injection",
    "shared_database",
    "authentication",
    "diagnostics",
    "api",
    "security",
}

EXPECTED_APPLE_IO_KINDS = {
    "networking",
    "storage",
    "secure_storage",
    "file_export",
    "telemetry",
    "shared_database",
    "authentication",
    "diagnostics",
    "api",
    "security",
}


def reject_duplicate_keys(pairs):
    seen = set()
    result = {}
    for key, value in pairs:
        if key in seen:
            raise ValueError(f"duplicate key: {key}")
        seen.add(key)
        result[key] = value
    return result


def load_json(relative_path):
    with (ROOT / relative_path).open(encoding="utf-8") as handle:
        return json.load(handle)


def load_json_no_duplicates(relative_path):
    with (ROOT / relative_path).open(encoding="utf-8") as handle:
        return json.load(handle, object_pairs_hook=reject_duplicate_keys)


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


class RemediationAcceptanceTests(unittest.TestCase):
    def test_every_repository_json_file_parses_without_duplicate_keys(self):
        json_files = sorted(
            path
            for path in ROOT.rglob("*.json")
            if ".git" not in path.parts and ".build" not in path.parts
        )
        self.assertGreater(len(json_files), 0)
        for path in json_files:
            relative = path.relative_to(ROOT)
            with self.subTest(path=str(relative)):
                load_json_no_duplicates(str(relative))

    def test_policy_and_schema_mirrors_match(self):
        mirrored_paths = [
            "forsetti-project-context.schema.json",
            "task-contract.schema.json",
            "module-manifest-1.1.schema.json",
        ]
        for path in mirrored_paths:
            self.assertEqual(
                load_json_no_duplicates(f"core/schemas/{path}"),
                load_json_no_duplicates(f"schemas/{path}"),
                path,
            )

        canonical_manifest_schema = load_json_no_duplicates(
            "core/schemas/module-manifest-1.1.schema.json"
        )
        bundled_manifest_schema = load_json_no_duplicates(
            "bundle/schemas/forsetti-module-manifest-1.1.schema.json"
        )
        canonical_manifest_schema.pop("$id", None)
        bundled_manifest_schema.pop("$id", None)
        self.assertEqual(canonical_manifest_schema, bundled_manifest_schema)

        mirrored_policies = [
            "forsetti-enforcement-rules.json",
            "manifest-rules.json",
            "runtime-requirement-rules.json",
            "module-isolation-rules.json",
            "dependency-boundary-rules.json",
            "public-api-rules.json",
            "capability-rules.json",
            "ui-contribution-rules.json",
            "service-access-rules.json",
            "mcp-provider-policy.json",
            "mcp-resolution-order.json",
            "accountability-rules.json",
        ]
        for path in mirrored_policies:
            self.assertEqual(
                load_json_no_duplicates(f"core/policies/{path}"),
                load_json_no_duplicates(f"policies/{path}"),
                path,
            )

    def test_forsetti_project_context_is_required_by_task_contract_schema(self):
        schema = load_json("core/schemas/task-contract.schema.json")
        self.assertIn("forsetti_project_context", schema["required"])
        context = schema["properties"]["forsetti_project_context"]
        self.assertEqual("forsetti-project-context.schema.json", context["$ref"])

    def test_project_context_schema_requires_forsetti_profile_context(self):
        schema = load_json_no_duplicates("core/schemas/forsetti-project-context.schema.json")
        required = set(schema["required"])
        expected = {
            "repository_mode",
            "forsetti_edition",
            "target_platform",
            "framework_version",
            "edition_profile",
            "manifest_schema_version",
            "manifest_template_version",
            "deployment_pattern",
            "module_type",
            "module_id",
            "capabilities_requested",
            "runtime_requirements_declared",
            "uses_public_api_only",
            "touches_framework_internals",
        }
        self.assertLessEqual(expected, required)

    def test_current_apple_profile_matches_supplied_0_1_5_contract(self):
        apple = load_json_no_duplicates(APPLE_015_PROFILE)

        self.assertEqual("apple", apple["edition"])
        self.assertEqual("0.1.5", apple["frameworkVersion"])
        self.assertEqual("supported", apple["supportStatus"])
        self.assertEqual({"iOS", "macOS"}, set(apple["supportedPlatforms"]))
        self.assertEqual("Swift", apple["nativeLanguage"])
        self.assertEqual("5.10", apple["swiftToolsVersion"])
        self.assertEqual({"iOS": "17.0", "macOS": "14.0"}, apple["minimumDeploymentTargets"])
        self.assertEqual(
            {"ForsettiCore", "ForsettiPlatform", "ForsettiHostTemplate"},
            set(apple["publicProducts"]),
        )
        self.assertEqual({"ForsettiModulesExample"}, set(apple["internalTargets"]))
        self.assertEqual(EXPECTED_APPLE_CAPABILITIES, set(apple["capabilities"]))
        self.assertEqual(EXPECTED_APPLE_IO_KINDS, set(apple["manifest"]["ioKinds"]))
        self.assertNotIn("event_publishing", apple["capabilities"])
        self.assertNotIn("crypto_utilities", apple["manifest"]["ioKinds"])
        self.assertEqual("1.1", apple["manifest"]["currentSchemaVersion"])
        self.assertEqual("1.1", apple["manifest"]["currentTemplateVersion"])
        self.assertEqual("object", apple["manifest"]["semanticVersionEncoding"])
        self.assertEqual(
            {"restoreOnly", "activateAllEligibleForDevelopment", "activate(moduleIDs:)"},
            set(apple["launchActivationStrategies"]),
        )

        self.assertEqual("modularity-first_object-oriented", apple["frameworkIdentity"]["architectureStyle"])
        self.assertEqual("Apple-native", apple["frameworkIdentity"]["platformStrategy"])
        self.assertEqual("sealed_public_contracts_only", apple["frameworkIdentity"]["consumerRuntimeBoundary"])
        self.assertFalse(apple["frameworkIdentity"]["allowsThirdPartyRuntimeDependencies"])
        expected_dependency_rules = {
            "ForsettiCore": {
                "depends_on:nothing_in_repository",
                "must_not_import:ForsettiPlatform",
                "must_not_import:ForsettiModulesExample",
                "must_not_import:ForsettiHostTemplate",
                "must_not_import:SwiftUI",
                "must_not_import:UIKit",
                "must_not_import:AppKit",
                "must_not_import:StoreKit",
                "must_not_import:Combine",
            },
            "ForsettiPlatform": {
                "depends_on:ForsettiCore",
                "must_not_import:ForsettiModulesExample",
                "must_not_import:ForsettiHostTemplate",
                "must_not_import:SwiftUI",
                "must_not_import:UIKit",
                "must_not_import:AppKit",
            },
            "ForsettiModulesExample": {
                "depends_on:ForsettiCore",
                "must_not_import:ForsettiPlatform",
                "must_not_import:ForsettiHostTemplate",
                "must_not_import:SwiftUI",
                "must_not_import:UIKit",
                "must_not_import:AppKit",
                "must_not_import:StoreKit",
            },
            "ForsettiHostTemplate": {
                "depends_on:ForsettiCore",
                "depends_on:ForsettiPlatform",
                "must_not_import:ForsettiModulesExample",
            },
            "ConsumerModules": {
                "may_depend_on:public_products_only",
                "must_not_reference_other_modules_directly",
            },
        }
        self.assertEqual(
            expected_dependency_rules,
            {key: set(value) for key, value in apple["dependencyRules"].items()},
        )
        self.assertEqual({"A", "B", "C", "D"}, {item["id"] for item in apple["deploymentPatterns"]})
        self.assertEqual(
            {
                "objectOrientedDesign",
                "consumerIntegration",
                "moduleBoundaries",
                "runtimeSafety",
                "errorAndConcurrency",
            },
            set(apple["implementationRules"]),
        )
        self.assertTrue(all(apple["implementationRules"].values()))
        self.assertEqual("pass", apple["upstreamValidationEvidence"]["status"])
        self.assertEqual(13, apple["upstreamValidationEvidence"]["acceptanceGateCount"])
        self.assertEqual(81, apple["upstreamValidationEvidence"]["packageTestCount"])
        report_entry = next(
            item
            for item in apple["sourceContract"]["files"]
            if item["path"] == ".forsetti/alignment/final-report.json"
        )
        self.assertEqual(
            report_entry["sha256"],
            apple["upstreamValidationEvidence"]["reportSHA256"],
        )

        legacy = apple["manifest"]["legacyDefaults"]
        self.assertEqual("1.0", legacy["schemaVersion"])
        self.assertEqual("1.0", legacy["manifestTemplateVersionWhenAbsent"])
        self.assertIsNone(legacy["defaultModuleRole"])
        self.assertEqual([], legacy["runtimeRequirements"]["io"])
        self.assertIsNone(legacy["runtimeRequirements"]["ui"])
        self.assertEqual(
            {"mode": "private_to_module", "ownedStoreIDs": [], "requiredDefaultRoles": []},
            legacy["runtimeRequirements"]["dataIsolation"],
        )

    def test_current_apple_profile_source_contract_hashes_are_pinned(self):
        apple = load_json_no_duplicates(APPLE_015_PROFILE)
        contract = apple["sourceContract"]
        self.assertEqual("Forsetti-Framework-Mac-iOS", contract["repository"])
        self.assertEqual("version.txt", contract["versionFile"])
        self.assertEqual("0.1.5", contract["version"])
        actual = {item["path"]: item["sha256"] for item in contract["files"]}
        self.assertEqual(EXPECTED_SOURCE_HASHES, actual)

    def test_current_profile_is_bundled_and_compatibility_profile_is_retained(self):
        self.assertEqual(
            load_json_no_duplicates(APPLE_015_PROFILE),
            load_json_no_duplicates("bundle/editions/apple/forsetti-apple-0.1.5.profile.json"),
        )

        compatibility = load_json_no_duplicates(APPLE_013_PROFILE)
        bundled_compatibility = load_json_no_duplicates(
            "bundle/editions/apple/forsetti-apple-0.1.3.profile.json"
        )
        self.assertEqual(compatibility, bundled_compatibility)
        self.assertEqual("0.1.3", compatibility["frameworkVersion"])

        windows = load_json_no_duplicates(WINDOWS_PROFILE)
        self.assertEqual("windows", windows["edition"])
        self.assertEqual("0.2.0", windows["frameworkVersion"])
        self.assertIn("event_publishing", windows["capabilities"])

    def test_edition_profile_schema_requires_full_current_apple_contract(self):
        schema = load_json_no_duplicates("core/schemas/edition-profile.schema.json")
        apple_condition = schema["allOf"][0]
        self.assertEqual("apple", apple_condition["if"]["properties"]["edition"]["const"])
        self.assertEqual(
            "0.1.5",
            apple_condition["if"]["properties"]["frameworkVersion"]["const"],
        )
        required = set(apple_condition["then"]["required"])
        self.assertLessEqual(
            {
                "sourceContract",
                "swiftToolsVersion",
                "minimumDeploymentTargets",
                "internalTargets",
                "ioCapabilityMappings",
                "serviceCapabilityMappings",
                "uiCapabilityMappings",
                "defaultModuleRoleRules",
                "runtimeInvariants",
                "launchActivationStrategies",
                "xcodeTemplates",
                "consumerVerificationCommands",
                "frameworkIdentity",
                "implementationRules",
                "deploymentPatterns",
                "upstreamValidationEvidence",
            },
            required,
        )

    def test_manifest_schema_encodes_apple_0_1_5_manifest_contract(self):
        schema = load_json_no_duplicates("core/schemas/module-manifest-1.1.schema.json")
        required = set(schema["required"])
        self.assertLessEqual(
            {
                "schemaVersion",
                "manifestTemplateVersion",
                "moduleID",
                "displayName",
                "moduleVersion",
                "moduleType",
                "supportedPlatforms",
                "minForsettiVersion",
                "capabilitiesRequested",
                "entryPoint",
                "runtimeRequirements",
            },
            required,
        )
        self.assertEqual("1.1", schema["properties"]["schemaVersion"]["const"])
        self.assertEqual("1.1", schema["properties"]["manifestTemplateVersion"]["const"])
        self.assertEqual(
            "^[A-Za-z][A-Za-z0-9]*(\\.[A-Za-z][A-Za-z0-9-]*)+$",
            schema["properties"]["moduleID"]["pattern"],
        )
        self.assertEqual("^forsetti\\.", schema["properties"]["moduleID"]["not"]["pattern"])
        self.assertEqual(
            "^[A-Za-z_][A-Za-z0-9_.]*$",
            schema["properties"]["entryPoint"]["pattern"],
        )

        semantic_version = schema["$defs"]["semanticVersionObject"]
        self.assertEqual("object", semantic_version["type"])
        self.assertEqual({"major", "minor", "patch"}, set(semantic_version["required"]))

        runtime = schema["properties"]["runtimeRequirements"]
        self.assertEqual({"io", "ui", "dataIsolation"}, set(runtime["required"]))
        io_kinds = set(schema["$defs"]["ioRequirement"]["properties"]["kind"]["enum"])
        self.assertEqual(EXPECTED_APPLE_IO_KINDS, io_kinds)
        self.assertNotIn("crypto_utilities", io_kinds)
        self.assertIn(
            "consume",
            schema["$defs"]["ioRequirement"]["properties"]["access"]["enum"],
        )

    def test_current_apple_profile_contains_exact_capability_mappings(self):
        apple = load_json_no_duplicates(APPLE_015_PROFILE)
        self.assertEqual(
            {kind: kind for kind in EXPECTED_APPLE_IO_KINDS},
            apple["ioCapabilityMappings"],
        )
        self.assertEqual(
            {
                "NetworkingService": "networking",
                "StorageService": "storage",
                "SecureStorageService": "secure_storage",
                "FileExportService": "file_export",
                "TelemetryService": "telemetry",
                "SharedDatabaseService": "shared_database",
                "AuthenticationService": "authentication",
                "DiagnosticsService": "diagnostics",
                "APIService": "api",
                "SecurityService": "security",
            },
            apple["serviceCapabilityMappings"],
        )
        self.assertEqual(
            {
                "themeIDs": "ui_theme_mask",
                "viewIDs": "view_injection",
                "slotIDs": "view_injection",
                "toolbarItemIDs": "toolbar_items",
                "routeIDs": "routing_overlay",
                "pointerIDs": "routing_overlay",
            },
            apple["uiCapabilityMappings"],
        )

    def test_active_templates_default_to_current_apple_profile(self):
        context_template = load_json_no_duplicates(
            "core/contracts/forsetti-project-context-template.json"
        )
        task_template = load_json_no_duplicates("core/contracts/task-contract-template.json")
        for context in [context_template, task_template["forsetti_project_context"]]:
            self.assertEqual("apple", context["forsetti_edition"])
            self.assertEqual("0.1.5", context["framework_version"])
            self.assertEqual(APPLE_015_PROFILE, context["edition_profile"])

        markdown_template = (ROOT / "contracts/task-contract-template.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("**Framework Version:** 0.1.5", markdown_template)
        self.assertIn(APPLE_015_PROFILE, markdown_template)

    def test_bootstrap_defaults_current_and_preserves_explicit_compatibility(self):
        source = (
            ROOT
            / "products/apple/Sources/GovernanceApple/RepositoryBootstrapService.swift"
        ).read_text(encoding="utf-8")
        tests = (
            ROOT
            / "products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift"
        ).read_text(encoding="utf-8")

        self.assertIn('edition == "windows" ? "0.2.0" : "0.1.5"', source)
        self.assertIn("forsetti-\\(edition)-\\(selectedVersion).profile.json", source)
        self.assertIn("testInitDefaultsToCurrentAppleProfile", tests)
        self.assertIn("testInitCanSelectRetainedAppleCompatibilityProfile", tests)
        self.assertIn("testInitBlocksUnknownAppleFrameworkVersion", tests)
        self.assertIn('frameworkVersion: "0.1.3"', tests)

    def test_validator_is_current_profile_aware_and_edition_aware(self):
        validator = (ROOT / "core/validator/forsetti_validate.ps1").read_text(encoding="utf-8")
        rules = (ROOT / "core/validator/rules/forsetti_project_rules.ps1").read_text(
            encoding="utf-8"
        )

        for mode in [
            "repo",
            "contract",
            "project-context",
            "edition-profile",
            "manifest",
            "dependencies",
            "capabilities",
            "module-isolation",
            "evidence",
            "all",
        ]:
            self.assertIn(f'"{mode}"', validator)

        self.assertIn(APPLE_015_PROFILE, validator)
        self.assertIn(APPLE_013_PROFILE, validator)
        self.assertIn('version = "0.4.0"', validator)
        self.assertIn("crypto_utilities is a capability", validator)
        self.assertIn("defines no event_publishing capability", validator)
        self.assertIn("Get-ForsettiCapabilityUseMap -Edition $selectedEdition", validator)
        self.assertIn("must_not_import:Combine", validator)
        self.assertIn("StoreKit|Combine", validator)
        self.assertIn("Test-ForsettiStringMap", validator)
        self.assertIn("manifest.legacyDefaults", validator)
        self.assertIn("upstreamValidationEvidence", validator)
        self.assertIn('if ($Edition -eq "windows")', rules)
        self.assertIn("$map.event_publishing", rules)
        self.assertNotIn("event_publishing = @", rules.split('if ($Edition -eq "windows")')[0])

        for field in ["rule_id", "severity", "decision", "message", "evidence", "remediation"]:
            self.assertIn(field, validator)

    def test_bundle_manifest_tracks_current_and_compatibility_profiles(self):
        manifest = load_json_no_duplicates("bundle/product-manifest.json")
        files = {entry["path"]: entry for entry in manifest["files"]}
        for path in [
            "editions/apple/forsetti-apple-0.1.5.profile.json",
            "editions/apple/forsetti-apple-0.1.3.profile.json",
        ]:
            self.assertIn(path, files)
            self.assertEqual(
                sha256(ROOT / "bundle" / path),
                files[path]["sha256"],
            )

    def test_enforcement_rules_f001_through_f020_are_complete(self):
        registry = load_json_no_duplicates("core/policies/forsetti-enforcement-rules.json")
        rules = {rule["rule_id"]: rule for rule in registry["rules"]}
        expected = [f"FAE-F{number:03d}" for number in range(1, 21)]
        self.assertEqual(expected, list(rules))

        for rule_id in expected:
            rule = rules[rule_id]
            for field in (
                "rule_id",
                "title",
                "severity",
                "decision",
                "applies_to_modes",
                "required_evidence",
                "validation",
                "remediation",
            ):
                self.assertIn(field, rule, rule_id)

    def test_alignment_does_not_introduce_bifrost_ash_or_aeostara_runtime_dependencies(self):
        implementation_files = [
            ROOT / "core/validator/forsetti_validate.ps1",
            ROOT / "core/validator/rules/forsetti_project_rules.ps1",
            ROOT / "products/apple/Sources/GovernanceApple/RepositoryBootstrapService.swift",
        ]
        for path in implementation_files:
            text = path.read_text(encoding="utf-8").lower()
            with self.subTest(path=str(path.relative_to(ROOT))):
                self.assertNotIn("import ash", text)
                self.assertNotIn("import aeostara", text)
                self.assertNotIn("import bifrost", text)


if __name__ == "__main__":
    unittest.main()
