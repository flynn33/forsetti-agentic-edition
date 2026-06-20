import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_json(relative_path):
    with (ROOT / relative_path).open(encoding="utf-8") as handle:
        return json.load(handle)


def load_json_no_duplicates(relative_path):
    def reject_duplicate_keys(pairs):
        seen = set()
        result = {}
        for key, value in pairs:
            if key in seen:
                raise ValueError(f"duplicate key: {key}")
            seen.add(key)
            result[key] = value
        return result

    with (ROOT / relative_path).open(encoding="utf-8") as handle:
        return json.load(handle, object_pairs_hook=reject_duplicate_keys)


class RemediationAcceptanceTests(unittest.TestCase):
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

    def test_profiles_define_required_versions_and_manifest_model(self):
        apple = load_json_no_duplicates("editions/apple/forsetti-apple-0.1.3.profile.json")
        windows = load_json_no_duplicates("editions/windows/forsetti-windows-0.2.0.profile.json")

        self.assertEqual("apple", apple["edition"])
        self.assertEqual("0.1.3", apple["frameworkVersion"])
        self.assertEqual("1.1", apple["manifest"]["currentSchemaVersion"])
        self.assertEqual("1.1", apple["manifest"]["currentTemplateVersion"])
        self.assertLessEqual({"iOS", "macOS"}, set(apple["supportedPlatforms"]))

        self.assertEqual("windows", windows["edition"])
        self.assertEqual("0.2.0", windows["frameworkVersion"])
        self.assertEqual("1.1", windows["manifest"]["currentSchemaVersion"])
        self.assertEqual("1.1", windows["manifest"]["currentTemplateVersion"])
        self.assertIn("Windows", windows["supportedPlatforms"])

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

    def test_manifest_schema_encodes_template_1_1_runtime_requirements(self):
        schema = load_json_no_duplicates("core/schemas/module-manifest-1.1.schema.json")
        required = set(schema["required"])
        self.assertLessEqual(
            {
                "schemaVersion",
                "manifestTemplateVersion",
                "moduleID",
                "moduleType",
                "supportedPlatforms",
                "capabilitiesRequested",
                "entryPoint",
                "runtimeRequirements",
            },
            required,
        )
        self.assertEqual("1.1", schema["properties"]["schemaVersion"]["const"])
        self.assertEqual("1.1", schema["properties"]["manifestTemplateVersion"]["const"])
        runtime = schema["properties"]["runtimeRequirements"]
        self.assertLessEqual({"io", "ui", "dataIsolation"}, set(runtime["required"]))
        self.assertIn("defaultModuleRole", schema["properties"])
        self.assertEqual(1, list(schema["properties"]).count("defaultModuleRole"))
        self.assertEqual(
            {"ui", "shared_database", "authentication", "diagnostics", "api", "security", None},
            set(schema["properties"]["defaultModuleRole"]["enum"]),
        )
        io_kinds = schema["$defs"]["ioRequirement"]["properties"]["kind"]["enum"]
        self.assertIn("shared_database", io_kinds)
        self.assertIn("crypto_utilities", io_kinds)
        self.assertIn("consume", schema["$defs"]["ioRequirement"]["properties"]["access"]["enum"])

    def test_validator_declares_required_modes_and_parameters(self):
        validator = (ROOT / "core/validator/forsetti_validate.ps1").read_text(encoding="utf-8")
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

        for parameter in [
            "$RepoRoot",
            "$Mode",
            "$ContractPath",
            "$ProjectContextPath",
            "$EditionProfilePath",
            "$ChangedFilesPath",
            "$ManifestPath",
            "$OutputJson",
            "$Strict",
            "module_id",
            "defaultModuleRole",
            "shared_database",
            "authentication",
            "diagnostics",
            "security",
        ]:
            self.assertIn(parameter, validator)
        self.assertNotIn('"none"', validator)
        self.assertNotIn('"app", "ui", "service", "none"', validator)

        for field in ["rule_id", "severity", "decision", "message", "evidence", "remediation"]:
            self.assertIn(field, validator)


if __name__ == "__main__":
    unittest.main()
