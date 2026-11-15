"""Validate, sign-configure and package Android releases using only the stdlib."""

import argparse
import base64
import binascii
import hashlib
import os
from pathlib import Path
import re
import shutil
import tempfile


ABIS = ("armeabi-v7a", "arm64-v8a", "x86_64")
SIGNING_SETTINGS = (
    "ANDROID_KEYSTORE_BASE64",
    "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS",
    "ANDROID_KEY_PASSWORD",
)


def read_version(pubspec, tag=""):
    match = re.search(
        r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?)\+([1-9][0-9]*)\s*$",
        pubspec.read_text(),
        re.MULTILINE,
    )
    if not match:
        raise ValueError("pubspec.yaml needs a semantic version and positive build number")
    version = match[1]
    if tag and tag != f"v{version}":
        raise ValueError("Release tag must match the version in pubspec.yaml")
    return version


def prepare_signing(settings, directory):
    missing = [key for key in SIGNING_SETTINGS if not settings.get(key, "").strip()]
    if missing:
        raise ValueError("Missing Android signing secrets: " + ", ".join(missing))
    try:
        key = base64.b64decode(settings["ANDROID_KEYSTORE_BASE64"], validate=True)
    except (ValueError, binascii.Error) as error:
        raise ValueError("ANDROID_KEYSTORE_BASE64 must contain valid base64") from error
    if not key:
        raise ValueError("Android signing keystore is empty")
    # NamedTemporaryFile creates a private (0600), uniquely named key file.
    with tempfile.NamedTemporaryFile(
        prefix="hialyth-release-", suffix=".jks", dir=directory, delete=False
    ) as output:
        output.write(key)
        return Path(output.name)


def package_apks(source, destination, version):
    sources = [source / f"app-{abi}-release.apk" for abi in ABIS]
    if any(not path.is_file() or not path.stat().st_size for path in sources):
        raise ValueError("All three nonempty split release APKs must exist before packaging")
    destination.mkdir(parents=True, exist_ok=True)
    checksums = []
    for abi, apk in zip(ABIS, sources):
        name = f"Hialyth-{version}-android-{abi}.apk"
        target = destination / name
        shutil.copyfile(apk, target)
        with target.open("rb") as data:
            digest = hashlib.file_digest(data, "sha256").hexdigest()
        checksums.append(f"{digest}  {name}\n")
    (destination / "SHA256SUMS").write_text("".join(checksums))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("version", "signing", "package"))
    command = parser.parse_args().command
    if command == "version":
        version = read_version(Path("pubspec.yaml"), os.environ.get("RELEASE_TAG", ""))
        outputs = f"version={version}\nprerelease={str('-' in version).lower()}\n"
        if os.environ.get("GITHUB_OUTPUT"):
            with open(os.environ["GITHUB_OUTPUT"], "a") as output:
                output.write(outputs)
        print(outputs, end="")
    elif command == "signing":
        key = prepare_signing(os.environ, Path(os.environ["RUNNER_TEMP"]))
        with open(os.environ["GITHUB_ENV"], "a") as output:
            output.write(f"ANDROID_KEYSTORE_PATH={key}\n")
        print("Temporary Android signing key prepared")
    else:
        version = read_version(Path("pubspec.yaml"), os.environ.get("RELEASE_TAG", ""))
        package_apks(
            Path("build/app/outputs/flutter-apk"), Path("dist/android"), version
        )
        print(f"Packaged Android {version} APKs and SHA256SUMS")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError) as error:
        raise SystemExit(str(error)) from None
