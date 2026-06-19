import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_json(relative_path):
    with (ROOT / relative_path).open(encoding="utf-8") as handle:
        return json.load(handle)


class RemediationAcceptanceTests(unittest.TestCase):
    def test_required_remediation_files_exist(self):
        required_paths = [
            "core/enforcement/authority-model.md",
            "core/schemas/forsetti-project-context.schema.json",
            "schemas/forsetti-project-context.schema.json",
            "core/schemas/edition-profile.schema.json",
            "core/schemas/module-manifest-1.1.schema.json",
            "core/contracts/forsetti-project-context-template.json",
            "core/policies/forsetti-enforcement-rules.json",
            "core/policies/manifest-rules.json",
            "core/policies/runtime-requirement-rules.json",
            "core/policies/module-isolation-rules.json",
            "core/policies/dependency-boundary-rules.json",
            "core/policies/public-api-rules.json",
            "core/policies/capability-rules.json",
            "core/policies/ui-contribution-rules.json",
            "core/policies/service-access-rules.json",
            "core/policies/mcp-provider-policy.json",
            "core/policies/mcp-resolution-order.json",
            "core/policies/accountability-rules.json",
            "core/policies/agent-enforcement-actions.json",
            "editions/shared/shared-forsetti-invariants.json",
            "editions/apple/forsetti-apple-0.1.3.profile.json",
            "editions/windows/forsetti-windows-0.2.0.profile.json",
            "editions/README.md",
            "standards/mcp-local-helper-standard.md",
            "ACCOUNTABILITY_POLICY.md",
            "core/validator/rules/forsetti_project_rules.ps1",
        ]

        missing = [path for path in required_paths if not (ROOT / path).exists()]
        self.assertEqual([], missing)

    def test_forsetti_project_context_is_required_by_task_contract_schema(self):
        schema = load_json("core/schemas/task-contract.schema.json")
        self.assertIn("forsetti_project_context", schema["required"])
        context = schema["properties"]["forsetti_project_context"]
        self.assertEqual("forsetti-project-context.schema.json", context["$ref"])

    def test_project_context_schema_requires_forsetti_profile_context(self):
        schema = load_json("core/schemas/forsetti-project-context.schema.json")
        root_schema = load_json("schemas/forsetti-project-context.schema.json")
        self.assertEqual(schema, root_schema)
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
        apple = load_json("editions/apple/forsetti-apple-0.1.3.profile.json")
        windows = load_json("editions/windows/forsetti-windows-0.2.0.profile.json")

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
        registry = load_json("core/policies/forsetti-enforcement-rules.json")
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
        schema = load_json("core/schemas/module-manifest-1.1.schema.json")
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
        self.assertEqual(
            {"app", "ui", "service", "none"},
            set(schema["properties"]["defaultModuleRole"]["enum"]),
        )

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
        ]:
            self.assertIn(parameter, validator)

        for field in ["rule_id", "severity", "decision", "message", "evidence", "remediation"]:
            self.assertIn(field, validator)


if __name__ == "__main__":
    unittest.main()
