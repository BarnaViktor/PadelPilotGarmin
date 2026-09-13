#!/usr/bin/env python3
"""Build and verify Padel Pilot with the locally installed Connect IQ SDK."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]


def run(command, log, timeout=180, accepted_codes=(0,)):
    """Keep compiler/test evidence even when a command fails or times out."""
    try:
        result = subprocess.run(
            [str(arg) for arg in command], cwd=ROOT, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, timeout=timeout,
        )
    except subprocess.TimeoutExpired as error:
        log.write_bytes(error.stdout or b"")
        raise RuntimeError(f"Command timed out; see {log}") from error
    log.write_bytes(result.stdout)
    output = result.stdout.decode(errors="replace")
    print(output, end="", flush=True)
    if result.returncode not in accepted_codes:
        raise RuntimeError(f"Command failed ({result.returncode}); see {log}")
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("build", "test", "beta", "release"))
    parser.add_argument("--device", help="Build/test target (default: fr265); unlisted models use an experimental manifest")
    parser.add_argument("--min-api", help="Override the minimum API only for an experimental device build/test")
    parser.add_argument("--sdk", default=os.environ.get("CIQ_SDK_DIR"))
    parser.add_argument("--key", default=os.environ.get(
        "CIQ_DEVELOPER_KEY", str(ROOT / "docs/developer_key")))
    args = parser.parse_args()
    if args.device and args.action in ("beta", "release"):
        parser.error("--device is only for build/test; exports use their release manifest")
    device = args.device or "fr265"
    if not re.fullmatch(r"[a-z0-9]+", device):
        parser.error("--device must be a Garmin device ID, for example epix2")
    if args.min_api and not re.fullmatch(r"\d+\.\d+\.\d+", args.min_api):
        parser.error("--min-api must be a numeric major.minor.patch version")

    if args.sdk:
        sdk = Path(args.sdk).expanduser().resolve()
    else:
        config = Path.home() / ".Garmin/ConnectIQ/current-sdk.cfg"
        if not config.is_file():
            raise RuntimeError("SDK not found. Set CIQ_SDK_DIR or use --sdk.")
        sdk = Path(config.read_text().strip()).expanduser().resolve()
    compiler = sdk / "bin/monkeyc"
    key = Path(args.key).expanduser().resolve()
    if not compiler.is_file():
        raise RuntimeError(f"Compiler not found: {compiler}")
    if not key.is_file():
        raise RuntimeError("Signing key not found. Set CIQ_DEVELOPER_KEY or use --key.")

    version = (ROOT / "VERSION").read_text().strip()
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise RuntimeError("VERSION must contain a numeric major.minor.patch version.")
    is_export = args.action in ("beta", "release")
    archiver = shutil.which("7zz") or shutil.which("7z")
    if is_export and not archiver:
        raise RuntimeError("Install 7z/7zz to verify exported IQ archives.")

    manifest = "manifest-beta.xml" if args.action == "beta" else "manifest.xml"
    manifest_tree = ET.parse(ROOT / manifest)
    application = manifest_tree.find("{*}application")
    products = application.findall("{*}products/{*}product")
    release_devices = [product.attrib["id"] for product in products]
    experimental = not is_export and device not in release_devices
    if args.min_api and not experimental:
        parser.error("--min-api is only allowed for an experimental device build/test")

    # Every invocation gets its own directory, so failed builds cannot be
    # confused with an older successful artifact and previous exports survive.
    output_root = ROOT / "build"
    output_root.mkdir(exist_ok=True)
    target_label = "export" if is_export else device
    output_dir = Path(tempfile.mkdtemp(prefix=f"{args.action}-{version}-{target_label}-", dir=output_root))
    print(f"Output: {output_dir}", flush=True)
    suffix = "-beta" if args.action == "beta" else ""
    if args.action == "test":
        suffix = "-tests"
    if not is_export:
        suffix += f"-{device}"
    artifact = output_dir / f"padel-pilot-{version}{suffix}.{'iq' if is_export else 'prg'}"
    jungle = "beta.jungle" if args.action == "beta" else "monkey.jungle"
    if experimental:
        # Candidate builds use the existing test app identity and a local
        # manifest. Device investigation never advertises Store support.
        manifest_tree = ET.parse(ROOT / "manifest-beta.xml")
        application = manifest_tree.find("{*}application")
        if args.min_api:
            application.set("minApiLevel", args.min_api)
        products_element = application.find("{*}products")
        for product in list(products_element):
            products_element.remove(product)
        ET.SubElement(products_element, "{http://www.garmin.com/xml/connectiq}product", {"id": device})
        ET.register_namespace("iq", "http://www.garmin.com/xml/connectiq")
        experimental_manifest = output_dir / "manifest.xml"
        manifest_tree.write(experimental_manifest, encoding="utf-8", xml_declaration=True)
        override = output_dir / "device.jungle"
        jungle_text = (ROOT / "monkey.jungle").read_text()
        jungle_text = re.sub(r"(?m)^project\.manifest\s*=.*$",
                            lambda _: f"project.manifest = {experimental_manifest}", jungle_text)
        # Jungle source/resource paths are relative to the jungle file.
        jungle_text = re.sub(
            r"(?m)^(base\.(?:sourcePath|resourcePath)\s*=\s*)(.+)$",
            lambda match: match[1] + ";".join(
                str((ROOT / path.strip()).resolve()) for path in match[2].split(";")),
            jungle_text)
        override.write_text(jungle_text)
        jungle = str(override)
        print(f"Experimental device: {device} (test application ID)", flush=True)
    command = [compiler, "-f", jungle,
               "-o", artifact, "-y", key, "-w"]
    if is_export:
        command += ["-e", "-r", "-O", "3"]
    else:
        command += ["-d", device]
        command += ["-t"] if args.action == "test" else ["-r", "-O", "3"]
    run(command, output_dir / "build.log")
    if not artifact.is_file() or artifact.stat().st_size == 0:
        raise RuntimeError("Compiler produced no artifact.")

    checks = {"build": "passed"}
    if is_export:
        run([archiver, "t", artifact], output_dir / "archive.log")
        checks["archive_integrity"] = "passed"
    if args.action == "test":
        print("Running tests in the Connect IQ simulator (must already be open).", flush=True)
        output = run([sdk / "bin/monkeydo", artifact, device, "-t"],
                     output_dir / "tests.log", timeout=120, accepted_codes=(0, 1))
        # SDK 9.2.0's Linux runner returns 1 even for a passing suite.
        # Never accept the exit code alone: require the final PASSED summary.
        summary = re.search(
            r"^PASSED \(passed=(\d+), failed=(\d+), errors=(\d+)\)\s*\Z",
            output, re.MULTILINE)
        if not summary or int(summary[1]) == 0 or int(summary[2]) or int(summary[3]):
            raise RuntimeError(f"Tests did not all pass; see {output_dir / 'tests.log'}")
        checks["tests_passed"] = int(summary[1])

    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    dirty = bool(subprocess.check_output(
        ["git", "status", "--porcelain", "--untracked-files=normal"], cwd=ROOT))
    compiler_version = subprocess.check_output([compiler, "-v"], cwd=ROOT, text=True).strip()
    metadata = {
        "version": version, "action": args.action,
        "device": None if is_export else device,
        "devices": release_devices if is_export else [device],
        "experimental": experimental,
        "min_api_level": application.attrib["minApiLevel"],
        "application_id": application.attrib["id"],
        "built_at_utc": datetime.now(timezone.utc).isoformat(),
        "git_revision": revision, "working_tree_dirty": dirty,
        "compiler": compiler_version, "artifact": artifact.name,
        "size_bytes": artifact.stat().st_size,
        "sha256": hashlib.sha256(artifact.read_bytes()).hexdigest(),
        "checks": checks,
    }
    (output_dir / "build-info.json").write_text(json.dumps(metadata, indent=2) + "\n")
    print(f"Verified: {artifact}\nBuild details: {output_dir / 'build-info.json'}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError, ET.ParseError, subprocess.SubprocessError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
