#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATOR="$REPO_ROOT/core/validator/forsetti_validate.ps1"

if [[ ! -f "$VALIDATOR" ]]; then
  echo "Unable to locate Forsetti local validator: $VALIDATOR" >&2
  exit 1
fi

POWERSHELL_BIN=""
for candidate in pwsh powershell powershell.exe; do
  if command -v "$candidate" >/dev/null 2>&1; then
    POWERSHELL_BIN="$candidate"
    break
  fi
done

if [[ -z "$POWERSHELL_BIN" ]]; then
  echo "PowerShell host not found. Run scripts/validate-repo.ps1 from Windows PowerShell or PowerShell 7." >&2
  exit 1
fi

if command -v cygpath >/dev/null 2>&1; then
  REPO_ROOT_ARG="$(cygpath -w "$REPO_ROOT")"
  VALIDATOR_ARG="$(cygpath -w "$VALIDATOR")"
else
  REPO_ROOT_ARG="$REPO_ROOT"
  VALIDATOR_ARG="$VALIDATOR"
fi

if [[ "$#" -eq 0 ]]; then
  set -- -Mode all
fi

exec "$POWERSHELL_BIN" -NoProfile -ExecutionPolicy Bypass -File "$VALIDATOR_ARG" -RepoRoot "$REPO_ROOT_ARG" "$@"
