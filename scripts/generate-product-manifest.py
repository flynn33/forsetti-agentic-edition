#!/usr/bin/env python3
"""Generate a deterministic product-manifest.json for a release bundle."""

from __future__ import annotations

import argparse
import hashlib
import json
import stat
from collections import OrderedDict
from pathlib import Path


PRODUCT_NAME = "Forsetti Agentic Edition"
SCHEMA_VERSION = "2.0"
DEFAULT_CREATED_AT = "1970-01-01T00:00:00Z"
EXCLUDED_NAMES = {"product-manifest.json", "product-lock.json"}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def version_from_bundle(bundle_root: Path) -> str:
    version_file = bundle_root / "VERSION"
    return version_file.read_text(encoding="utf-8").strip()


def relative_bundle_path(path: Path, bundle_root: Path) -> str:
    relative = path.relative_to(bundle_root).as_posix()
    parts = relative.split("/")
    if relative.startswith("/") or any(part in {"", ".", ".."} for part in parts):
        raise ValueError(f"Unsafe bundle path: {relative}")
    return relative


def is_executable(path: Path, relative_path: str, entry_point: str | None) -> bool:
    if entry_point is not None and relative_path == entry_point:
        return True
    return bool(path.stat().st_mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH))


def bundle_files(bundle_root: Path, entry_point: str | None) -> list[OrderedDict[str, object]]:
    entries: list[OrderedDict[str, object]] = []
    for path in sorted(bundle_root.rglob("*")):
        if not path.is_file():
            continue
        relative_path = relative_bundle_path(path, bundle_root)
        if path.name in EXCLUDED_NAMES:
            continue
        entry: OrderedDict[str, object] = OrderedDict()
        entry["path"] = relative_path
        entry["sha256"] = sha256_file(path)
        entry["required"] = True
        if is_executable(path, relative_path, entry_point):
            entry["executable"] = True
        entries.append(entry)
    if not entries:
        raise ValueError("Bundle contains no manifest entries.")
    return entries


def policy_bundle_hash(entries: list[OrderedDict[str, object]]) -> str:
    digest = hashlib.sha256()
    for entry in entries:
        path = str(entry["path"])
        if not path.startswith(("policies/", "editions/", "schemas/")):
            continue
        digest.update(path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(str(entry["sha256"]).encode("ascii"))
        digest.update(b"\0")
    return digest.hexdigest()


def build_manifest(args: argparse.Namespace) -> OrderedDict[str, object]:
    bundle_root = Path(args.bundle_root).resolve()
    if not bundle_root.is_dir():
        raise ValueError(f"Bundle root does not exist: {bundle_root}")
    version = version_from_bundle(bundle_root)
    entries = bundle_files(bundle_root, args.entry_point)
    manifest: OrderedDict[str, object] = OrderedDict()
    manifest["schemaVersion"] = SCHEMA_VERSION
    manifest["product"] = PRODUCT_NAME
    manifest["version"] = version
    manifest["bundleID"] = args.bundle_id or f"ffae-{version}-{args.platform}"
    manifest["platform"] = args.platform
    manifest["architecture"] = args.architecture
    manifest["entryPoint"] = args.entry_point
    manifest["policyBundleHash"] = policy_bundle_hash(entries)
    manifest["files"] = entries
    manifest["createdAtUTC"] = args.created_at
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate product-manifest.json")
    parser.add_argument("--bundle-root", default="bundle")
    parser.add_argument("--platform", choices=["apple-host", "windows-host", "source"], default="source")
    parser.add_argument("--architecture", default="portable")
    parser.add_argument("--entry-point", default=None)
    parser.add_argument("--bundle-id", default=None)
    parser.add_argument("--created-at", default=DEFAULT_CREATED_AT)
    parser.add_argument("--output", default=None)
    args = parser.parse_args()

    bundle_root = Path(args.bundle_root).resolve()
    output = Path(args.output).resolve() if args.output else bundle_root / "product-manifest.json"
    manifest = build_manifest(args)
    output.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
