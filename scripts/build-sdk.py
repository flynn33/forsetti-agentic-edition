#!/usr/bin/env python3
"""Assemble the allowlisted governance product, never a repository snapshot."""
from __future__ import annotations

import argparse
import hashlib
import json
import platform
import shutil
import stat
import subprocess
import zipfile
from pathlib import Path


PRODUCT = "Forsetti Agentic Edition SDK"
GENERATED = [
    ".forsetti/project.json", ".forsetti/modules.json", ".forsetti/project-context.json",
    ".forsetti/profile.lock.json", ".forsetti/policy.lock.json", ".forsetti/product.lock.json",
    ".forsetti/instructions/GOVERNANCE.md", "AGENTS.md",
]
VARIANTS = {"portable": None, "macos-arm64": "bin/forsetti-governance"}
GENERATED_DIRECTORIES = [".forsetti", ".forsetti/instructions", ".forsetti/contracts",
                         ".forsetti/tasks", ".forsetti/evidence", ".forsetti/validation"]


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"Duplicate JSON property: {key}")
        result[key] = value
    return result


def read_json(data: bytes):
    return json.loads(data.decode("utf-8-sig"), object_pairs_hook=unique_object)


def json_bytes(value) -> bytes:
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def safe_path(value: str) -> str:
    if not isinstance(value, str) or not value or value.startswith("/") or "\\" in value or ":" in value or "\0" in value:
        raise ValueError(f"Unsafe payload path: {value!r}")
    parts = value.split("/")
    if any(part in {"", ".", ".."} or part.endswith((".", " ")) for part in parts):
        raise ValueError(f"Unsafe payload path: {value}")
    devices = {"con", "prn", "aux", "nul"} | {f"{p}{i}" for p in ("com", "lpt") for i in range(1, 10)}
    if any(part.split(".")[0].casefold() in devices for part in parts):
        raise ValueError(f"Reserved payload path: {value}")
    return value


def inventory(entries, path_key="path"):
    values = {}
    seen = set()
    for entry in entries:
        name = safe_path(entry[path_key])
        if name.casefold() in seen:
            raise ValueError(f"Duplicate or colliding inventory path: {name}")
        seen.add(name.casefold())
        values[name] = entry
    return values


def regular_files(root: Path):
    if root.is_symlink():
        raise ValueError(f"Symlink root: {root}")
    result = {}
    for path in root.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"Symlink payload: {path}")
        if path.is_file():
            result[safe_path(path.relative_to(root).as_posix())] = path
        elif not path.is_dir():
            raise ValueError(f"Special payload file: {path}")
    return result


def verify_bundle(root: Path):
    manifest = read_json((root / "product-manifest.json").read_bytes())
    if manifest.get("schemaVersion") != "2.0" or manifest.get("platform") != "source" or manifest.get("architecture") != "portable":
        raise ValueError("Unsupported or inaccurate source bundle identity.")
    files = inventory(manifest["files"])
    actual = regular_files(root)
    if set(actual) != set(files) | {"product-manifest.json"}:
        raise ValueError("Missing or unexpected trusted bundle files.")
    policy_hash = hashlib.sha256()
    for name in sorted(files):
        entry = files[name]
        if entry.get("required") is not True or digest(actual[name].read_bytes()) != entry["sha256"]:
            raise ValueError(f"Missing/altered required bundle file: {name}")
        if name.startswith(("policies/", "editions/", "schemas/")):
            policy_hash.update(name.encode() + b"\0" + entry["sha256"].encode("ascii") + b"\0")
    if policy_hash.hexdigest() != manifest.get("policyBundleHash"):
        raise ValueError("Policy bundle aggregate hash mismatch.")
    if (root / "VERSION").read_text().strip() != manifest["version"]:
        raise ValueError("Bundle version mismatch.")
    return manifest


def verify_sdk(root: Path):
    manifest = read_json((root / "sdk-manifest.json").read_bytes())
    if manifest.get("schemaVersion") != "1.0" or manifest.get("product") != PRODUCT or manifest.get("variant") not in VARIANTS:
        raise ValueError("Unsupported SDK delivery manifest.")
    mapping = read_json((root / "payload-map.json").read_bytes())
    if mapping.get("schemaVersion") != "1.0":
        raise ValueError("Unsupported payload allowlist.")
    mapped = inventory(mapping["entries"], "destination")
    expected = set(mapped) | {"payload-map.json"}
    executable = VARIANTS[manifest["variant"]]
    if executable:
        expected.add(executable)
    files = inventory(manifest["files"])
    actual = regular_files(root)
    if set(files) != expected or set(actual) != expected | {"sdk-manifest.json"}:
        raise ValueError("SDK payload differs from reviewed allowlist.")
    for name, entry in files.items():
        if digest(actual[name].read_bytes()) != entry["sha256"]:
            raise ValueError(f"SDK payload hash mismatch: {name}")
    bundle = verify_bundle(root / "bundle")
    if manifest["bundleManifestSHA256"] != digest((root / "bundle/product-manifest.json").read_bytes()):
        raise ValueError("Source bundle manifest mismatch.")
    if manifest["version"] != bundle["version"] or (root / "VERSION").read_text().strip() != manifest["version"]:
        raise ValueError("Product version mismatch.")
    policy = manifest["consumptionPolicy"]
    if policy["sourcePath"] != "CONSUMPTION_POLICY.md" or policy["sourceRevision"] != manifest["sourceRevision"] or policy["sha256"] != digest((root / "CONSUMPTION_POLICY.md").read_bytes()):
        raise ValueError("Consumption policy provenance mismatch.")
    return manifest


def git(root: Path, *args) -> bytes:
    return subprocess.check_output(["git", "-C", str(root), *args], stderr=subprocess.PIPE)


def source_bytes(root: Path, name: str, revision: str, candidate: bool) -> bytes:
    safe_path(name)
    if candidate:
        path = root / name
        if any(p.is_symlink() for p in (path, *path.parents)):
            raise ValueError(f"Symlink source: {name}")
        return path.read_bytes()
    mode = git(root, "ls-tree", revision, "--", name).decode().split(" ", 1)[0]
    if mode not in {"100644", "100755"}:
        raise ValueError(f"Source is not a committed regular file: {name}")
    return git(root, "show", f"{revision}:{name}")


def verify_canonical_bundle(root: Path, source_root: Path, revision: str, candidate: bool):
    mapping = read_json(source_bytes(source_root, "scripts/bundle-source-map.json", revision, candidate))
    if mapping.get("schemaVersion") != "1.0":
        raise ValueError("Unsupported canonical bundle source map.")
    entries = inventory(mapping["entries"], "destination")
    if set(regular_files(root)) != set(entries) | {"product-manifest.json"}:
        raise ValueError("Bundle payload differs from reviewed canonical source map.")
    for name, entry in entries.items():
        expected = source_bytes(source_root, entry["source"], revision, candidate)
        if "schemaID" in entry:
            schema = read_json(expected)
            schema["$id"] = entry["schemaID"]
            expected = json_bytes(schema)
        if (root / name).read_bytes() != expected:
            raise ValueError(f"Canonical-to-bundle drift: {name}")


def assemble(source_root: Path, output: Path, variant: str, executable: Path | None, candidate: bool):
    source_root = source_root.resolve()
    revision = git(source_root, "rev-parse", "HEAD").decode().strip()
    if not candidate:
        if git(source_root, "status", "--porcelain", "--untracked-files=no").strip():
            raise ValueError("Release assembly requires a clean recorded source revision; use --candidate for working-tree tests.")
    mapping_data = source_bytes(source_root, "sdk/payload-map.json", revision, candidate)
    mapping = read_json(mapping_data)
    if mapping.get("schemaVersion") != "1.0":
        raise ValueError("Unsupported source allowlist.")
    mapped = inventory(mapping["entries"], "destination")
    for entry in mapping["entries"]:
        safe_path(entry["source"])
    version = source_bytes(source_root, "VERSION", revision, candidate).decode().strip()
    name = f"Forsetti-Agentic-SDK-{version}-{variant}"
    output.mkdir(parents=True, exist_ok=True)
    root = output / name
    archive = output / (name + ".zip")
    checksum_path = output / f"{name}.zip.sha256"
    if root.exists() or archive.exists() or checksum_path.exists():
        raise ValueError("Refusing to overwrite an existing assembly.")
    root.mkdir()
    try:
        for destination, entry in sorted(mapped.items()):
            path = root / destination
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(source_bytes(source_root, entry["source"], revision, candidate))
            path.chmod(0o644)
        (root / "payload-map.json").write_bytes(mapping_data)
        verify_canonical_bundle(root / "bundle", source_root, revision, candidate)
        bundle = verify_bundle(root / "bundle")
        host_build = None
        native_path = VARIANTS[variant]
        if native_path:
            if platform.system() != "Darwin" or platform.machine() != "arm64" or executable is None:
                raise ValueError("macos-arm64 requires an actual macOS arm64 host and built executable.")
            if executable.is_symlink() or not executable.is_file():
                raise ValueError("Native executable must be a regular built file.")
            file_type = subprocess.check_output(["file", "-b", str(executable)], text=True).strip()
            if "Mach-O 64-bit executable arm64" not in file_type:
                raise ValueError("Native executable architecture does not match variant.")
            reported = subprocess.check_output([str(executable), "version"], text=True).strip()
            if reported != f"forsetti-governance {version}":
                raise ValueError("Built executable version differs from source release.")
            path = root / native_path
            path.parent.mkdir()
            shutil.copyfile(executable, path)
            path.chmod(0o755)
            host_build = {"hostOS": "macOS", "architecture": "arm64", "fileType": file_type,
                          "compiler": subprocess.check_output(["swift", "--version"], text=True).strip(),
                          "minimumOS": "13.0", "distributionSignature": "not asserted",
                          "nativeWindowsVerification": "not performed"}
        elif executable is not None:
            raise ValueError("Portable kit must not contain a native executable.")
        files = [{"path": path, "sha256": digest(file.read_bytes())} for path, file in sorted(regular_files(root).items())]
        manifest = {"schemaVersion": "1.0", "product": PRODUCT, "version": version,
                    "sourceRepository": "https://github.com/flynn33/forsetti-agentic-edition",
                    "sourceRevision": revision, "assemblyStatus": "candidate" if candidate else "recorded-revision",
                    "variant": variant, "bundleManifestSHA256": digest((root / "bundle/product-manifest.json").read_bytes()),
                    "consumptionPolicy": {"sourcePath": "CONSUMPTION_POLICY.md", "sourceRevision": revision,
                                          "sha256": digest((root / "CONSUMPTION_POLICY.md").read_bytes())},
                    "prerequisites": {"PowerShell": "7.4 or later", "Git": "2.30 or later for setup"},
                    "hostBuild": host_build, "generatedDestinations": GENERATED,
                    "generatedDirectories": GENERATED_DIRECTORIES,
                    "managedInstructionBlock": {"path": "AGENTS.md", "begin": "<!-- FORSETTI-GOVERNANCE:BEGIN -->",
                                                "end": "<!-- FORSETTI-GOVERNANCE:END -->"},
                    "advertisedCapabilities": {"nativeCommands": ["version", "bundle verify", "init", "doctor", "discover"] if native_path else [],
                                                "toolkitCommands": ["Initialize-Consumer.ps1", "Validate-Consumer.ps1"],
                                                "frameworkProfiles": ["apple/0.1.5", "apple/0.1.3", "windows/0.2.0"],
                                                "validation": "static governance checks plus required independent evidence; no application runtime approval"},
                    "files": files}
        (root / "sdk-manifest.json").write_bytes(json_bytes(manifest))
        verify_sdk(root)
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zipped:
            for relative, path in sorted(regular_files(root).items()):
                info = zipfile.ZipInfo(f"{name}/{relative}", (1980, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = (stat.S_IFREG | (0o755 if relative == native_path else 0o644)) << 16
                zipped.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
        checksum = digest(archive.read_bytes())
        checksum_path.write_text(f"{checksum}  {archive.name}\n")
        return root, archive, checksum
    except Exception:
        # Retain failed candidate files for diagnosis; never silently publish them.
        raise


def extract_verified_archive(archive: Path, destination: Path):
    if destination.exists():
        raise ValueError("Extraction destination must be new.")
    with zipfile.ZipFile(archive) as zipped:
        names = set()
        roots = set()
        for info in zipped.infolist():
            name = safe_path(info.filename.rstrip("/"))
            if name.casefold() in names:
                raise ValueError("Duplicate archive path.")
            names.add(name.casefold())
            roots.add(name.split("/")[0])
            mode = info.external_attr >> 16
            if stat.S_ISLNK(mode) or (stat.S_IFMT(mode) not in {0, stat.S_IFREG, stat.S_IFDIR}):
                raise ValueError("Links and special archive entries are forbidden.")
        if len(roots) != 1:
            raise ValueError("SDK archive must have exactly one product root.")
        destination.mkdir(parents=True)
        for info in zipped.infolist():
            path = destination / info.filename
            if info.is_dir():
                path.mkdir(parents=True, exist_ok=True)
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(zipped.read(info))
                path.chmod(0o755 if (info.external_attr >> 16) & 0o111 else 0o644)
    root = destination / roots.pop()
    verify_sdk(root)
    return root


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--variant", choices=list(VARIANTS), default="portable")
    parser.add_argument("--executable", type=Path)
    parser.add_argument("--candidate", action="store_true")
    parser.add_argument("--verify", type=Path)
    parser.add_argument("--extract", type=Path)
    parser.add_argument("--extract-to", type=Path)
    args = parser.parse_args()
    if args.verify:
        verify_sdk(args.verify)
        print("SDK inventory and bundle verified.")
    elif args.extract:
        if args.extract_to is None:
            parser.error("--extract requires --extract-to")
        print(extract_verified_archive(args.extract, args.extract_to))
    else:
        if args.output_dir is None:
            parser.error("--output-dir is required for assembly")
        root, archive, checksum = assemble(args.source_root, args.output_dir, args.variant, args.executable, args.candidate)
        print(json.dumps({"sdkRoot": str(root), "archive": str(archive), "sha256": checksum}))


if __name__ == "__main__":
    main()
