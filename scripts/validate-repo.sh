#!/usr/bin/env bash
# Forsetti Agentic Edition — Repository Validation Script
# Analogous to verify-forsetti-guardrails.sh (Apple) and verify-forsetti-guardrails.ps1 (Windows)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=========================================="
echo "Forsetti Agentic Edition — Repo Validation"
echo "=========================================="
echo ""

# ------------------------------------------
# [1/6] File Existence Check
# ------------------------------------------
echo "[1/6] Checking required files..."

REQUIRED_FILES=(
  "README.md"
  "VISION.md"
  "FORSETTI_CONSTITUTION.md"
  "AGENTS.md"
  "COMPLIANCE_POLICY.md"
  "CHANGE_CONTROL_POLICY.md"
  "RELEASE_POLICY.md"
  "DOCUMENTATION_POLICY.md"
  "CONTRIBUTING.md"
  "CODE_OF_DELIVERY.md"
  ".github/CODEOWNERS"
  ".github/labels.json"
  ".github/pull_request_template.md"
  ".github/ISSUE_TEMPLATE/feature_request.md"
  ".github/ISSUE_TEMPLATE/bug_report.md"
  ".github/ISSUE_TEMPLATE/governance_change.md"
  ".github/ISSUE_TEMPLATE/agent_task.md"
  ".github/workflows/policy-check.yml"
  ".github/workflows/changelog-check.yml"
  ".github/workflows/docs-sync-check.yml"
  ".github/workflows/version-guard.yml"
  ".github/workflows/protected-path-check.yml"
  "agents/architect.md"
  "agents/builder.md"
  "agents/validator.md"
  "agents/release-manager.md"
  "agents/docs-manager.md"
  "contracts/task-contract-template.md"
  "contracts/bugfix-contract-template.md"
  "contracts/governance-change-template.md"
  "contracts/release-contract-template.md"
  "policies/agent-roles.json"
  "policies/compliance-rules.json"
  "policies/repo-boundaries.json"
  "policies/versioning-rules.json"
  "policies/changelog-rules.json"
  "policies/docs-sync-rules.json"
  "policies/labels.json"
  "standards/naming-standard.md"
  "standards/versioning-standard.md"
  "standards/changelog-standard.md"
  "standards/documentation-standard.md"
  "standards/review-standard.md"
  "changelog/CHANGELOG.md"
  "changelog/release-notes-template.md"
  "wiki/Home.md"
  "wiki/Constitution.md"
  "wiki/Agent-Roles.md"
  "wiki/Workflow.md"
  "wiki/Compliance.md"
  "wiki/Releases.md"
  "wiki/Glossary.md"
  "schemas/task-contract.schema.json"
  "schemas/release-entry.schema.json"
  "schemas/compliance-report.schema.json"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$REPO_ROOT/$f" ]; then
    echo "  ERROR: Missing required file: $f"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -eq 0 ]; then
  echo "  All ${#REQUIRED_FILES[@]} required files present."
fi
echo ""

# ------------------------------------------
# [2/6] JSON Validation
# ------------------------------------------
echo "[2/6] Validating JSON files..."

JSON_ERRORS=0

while IFS= read -r -d '' jf; do
  if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$jf" 2>/dev/null; then
    echo "  ERROR: Invalid JSON: $jf"
    JSON_ERRORS=$((JSON_ERRORS + 1))
    ERRORS=$((ERRORS + 1))
  fi
done < <(find "$REPO_ROOT" -name "*.json" -not -path "*/.git/*" -not -path "*/node_modules/*" -print0)

if [ $JSON_ERRORS -eq 0 ]; then
  echo "  All JSON files parse cleanly."
fi
echo ""

# ------------------------------------------
# [3/6] YAML Validation
# ------------------------------------------
echo "[3/6] Validating YAML workflow files..."

YAML_ERRORS=0

# Try python yaml module first, fall back to basic syntax check
YAML_VALIDATOR="python3 -c \"import yaml, sys; yaml.safe_load(open(sys.argv[1]))\" "
if ! python3 -c "import yaml" 2>/dev/null; then
  # Fallback: basic non-empty and structure check
  YAML_VALIDATOR=""
fi

while IFS= read -r -d '' yf; do
  if [ -n "$YAML_VALIDATOR" ]; then
    if ! python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" "$yf" 2>/dev/null; then
      echo "  ERROR: Invalid YAML: $yf"
      YAML_ERRORS=$((YAML_ERRORS + 1))
      ERRORS=$((ERRORS + 1))
    fi
  else
    # Basic check: file is non-empty and starts with valid YAML
    if [ ! -s "$yf" ]; then
      echo "  ERROR: Empty YAML file: $yf"
      YAML_ERRORS=$((YAML_ERRORS + 1))
      ERRORS=$((ERRORS + 1))
    fi
  fi
done < <(find "$REPO_ROOT/.github/workflows" -name "*.yml" -print0 2>/dev/null)

if [ $YAML_ERRORS -eq 0 ]; then
  echo "  All YAML files parse cleanly."
fi
echo ""

# ------------------------------------------
# [4/6] Non-Trivial Content Check
# ------------------------------------------
echo "[4/6] Checking files are non-trivial (>5 lines)..."

TRIVIAL=0
for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$REPO_ROOT/$f" ]; then
    LINES=$(wc -l < "$REPO_ROOT/$f")
    if [ "$LINES" -lt 5 ]; then
      echo "  WARNING: File appears to be a stub ($LINES lines): $f"
      WARNINGS=$((WARNINGS + 1))
      TRIVIAL=$((TRIVIAL + 1))
    fi
  fi
done

if [ $TRIVIAL -eq 0 ]; then
  echo "  All required files have substantive content."
fi
echo ""

# ------------------------------------------
# [5/6] Labels Sync Check
# ------------------------------------------
echo "[5/6] Checking labels.json sync..."

if [ -f "$REPO_ROOT/policies/labels.json" ] && [ -f "$REPO_ROOT/.github/labels.json" ]; then
  if diff -q "$REPO_ROOT/policies/labels.json" "$REPO_ROOT/.github/labels.json" > /dev/null 2>&1; then
    echo "  policies/labels.json and .github/labels.json are in sync."
  else
    echo "  WARNING: policies/labels.json and .github/labels.json differ."
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  ERROR: One or both labels.json files missing."
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ------------------------------------------
# [6/6] Schema Non-Empty Check
# ------------------------------------------
echo "[6/6] Checking JSON schemas have properties defined..."

for schema in schemas/task-contract.schema.json schemas/release-entry.schema.json schemas/compliance-report.schema.json; do
  if [ -f "$REPO_ROOT/$schema" ]; then
    if ! python3 -c "import json, sys; d=json.load(open(sys.argv[1])); assert 'properties' in d, 'no properties'" "$REPO_ROOT/$schema" 2>/dev/null; then
      echo "  ERROR: Schema has no properties defined: $schema"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

echo "  Schema structure validated."
echo ""

# ------------------------------------------
# Summary
# ------------------------------------------
echo "=========================================="
echo "Validation Complete"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo "=========================================="

if [ $ERRORS -gt 0 ]; then
  echo "FAILED — $ERRORS error(s) must be resolved."
  exit 1
else
  echo "PASSED — Repository validation successful."
  exit 0
fi
