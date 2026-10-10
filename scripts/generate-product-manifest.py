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
SOURCE_MAP = Path(__file__).with_name("bundle-source-map.json")


def source_map_entries(source_map: Path) -> list[dict[str, str]]:
    data = json.loads(source_map.read_text(encoding="utf-8"))
    if data.get("schemaVersion") != "1.0":
        raise ValueError("Unsupported bundle source-map version.")
    seen: set[str] = set()
    for entry in data["entries"]:
        for field in ("source", "destination"):
            value = entry[field]
            if (not value or value.startswith("/") or "\\" in value or ":" in value
                    or any(part in {"", ".", ".."} for part in value.split("/"))):
                raise ValueError(f"Unsafe source-map {field}: {value}")
        key = entry["destination"].casefold()
        if key in seen:
            raise ValueError("Duplicate bundle source-map destination.")
        seen.add(key)
    return data["entries"]


def approved_source_bytes(source_root: Path, entry: dict[str, str]) -> bytes:
    path = source_root / entry["source"]
    if any(parent.is_symlink() for parent in [path, *path.parents] if parent != source_root.parent):
        raise ValueError(f"Symlink source is forbidden: {entry['source']}")
    data = path.read_bytes()
    if "schemaID" in entry:
        schema = json.loads(data)
        schema["$id"] = entry["schemaID"]
        data = (json.dumps(schema, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
    return data


def check_source_map(bundle_root: Path, source_root: Path, entries: list[dict[str, str]],
                     entry_point: str | None, synchronize: bool) -> None:
    allowed = {entry["destination"] for entry in entries} | EXCLUDED_NAMES
    if entry_point:
        if (entry_point.startswith("/") or "\\" in entry_point or ":" in entry_point
                or any(p in {"", ".", ".."} for p in entry_point.split("/"))):
            raise ValueError("Unsafe explicitly declared executable path.")
        allowed.add(entry_point)
    for path in bundle_root.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"Symlink bundle input is forbidden: {path}")
        if path.is_file() and path.relative_to(bundle_root).as_posix() not in allowed:
            raise ValueError(f"Unapproved bundle input: {path.relative_to(bundle_root)}")
    for entry in entries:
        expected = approved_source_bytes(source_root, entry)
        destination = bundle_root / entry["destination"]
        if synchronize:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(expected)
        if not destination.is_file() or destination.read_bytes() != expected:
            raise ValueError(f"Canonical-to-bundle drift: {entry['destination']}")


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
        if relative_path in EXCLUDED_NAMES:
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
    unresolved_root = Path(args.bundle_root).absolute()
    if any(path.is_symlink() for path in (unresolved_root, *unresolved_root.parents)):
        raise ValueError("Symlink bundle root or ancestor is forbidden; provide a canonical path.")
    bundle_root = Path(args.bundle_root).resolve()
    if not bundle_root.is_dir():
        raise ValueError(f"Bundle root does not exist: {bundle_root}")
    entries_map = source_map_entries(Path(args.source_map))
    check_source_map(bundle_root, Path(args.source_root).resolve(), entries_map,
                     args.entry_point, args.synchronize)
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
    parser.add_argument("--source-map", default=str(SOURCE_MAP))
    parser.add_argument("--source-root", default=str(Path(__file__).resolve().parents[1]))
    parser.add_argument("--synchronize", action="store_true", help="Copy only approved canonical inputs before hashing")
    args = parser.parse_args()

    bundle_root = Path(args.bundle_root).resolve()
    output = Path(args.output).resolve() if args.output else bundle_root / "product-manifest.json"
    manifest = build_manifest(args)
    output.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
