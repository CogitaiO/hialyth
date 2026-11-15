import base64
import hashlib
from pathlib import Path
import stat
import tempfile
import unittest

from android_release import ABIS, package_apks, prepare_signing, read_version


class AndroidReleaseTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)

    def test_tag_matches_pubspec_version(self):
        pubspec = self.root / "pubspec.yaml"
        pubspec.write_text("name: example\nversion: 0.2.0+2\n")
        self.assertEqual(read_version(pubspec, "v0.2.0"), "0.2.0")
        with self.assertRaises(ValueError):
            read_version(pubspec, "v0.3.0")

    def test_prerelease_version_is_supported(self):
        pubspec = self.root / "pubspec.yaml"
        pubspec.write_text("version: 0.2.0-beta.1+2\n")
        self.assertEqual(read_version(pubspec, "v0.2.0-beta.1"), "0.2.0-beta.1")

    def test_missing_or_zero_build_number_is_rejected(self):
        pubspec = self.root / "pubspec.yaml"
        for version in ("0.2.0", "0.2.0+0", "not-a-version"):
            with self.subTest(version=version):
                pubspec.write_text(f"version: {version}\n")
                with self.assertRaises(ValueError):
                    read_version(pubspec)

    def test_signing_requires_every_setting(self):
        with self.assertRaisesRegex(ValueError, "Missing Android signing secrets"):
            prepare_signing({}, self.root)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_signing_key_is_private_and_unique(self):
        settings = {
            "ANDROID_KEYSTORE_BASE64": base64.b64encode(b"test-keystore").decode(),
            "ANDROID_KEYSTORE_PASSWORD": "test-only",
            "ANDROID_KEY_ALIAS": "test",
            "ANDROID_KEY_PASSWORD": "test-only",
        }
        first = prepare_signing(settings, self.root)
        second = prepare_signing(settings, self.root)
        self.assertNotEqual(first, second)
        self.assertEqual(first.read_bytes(), b"test-keystore")
        self.assertEqual(stat.S_IMODE(first.stat().st_mode), 0o600)
        settings["ANDROID_KEYSTORE_BASE64"] = "not-base64!"
        with self.assertRaisesRegex(ValueError, "valid base64"):
            prepare_signing(settings, self.root)

    def test_packaging_needs_all_architectures(self):
        source = self.root / "source"
        source.mkdir()
        (source / "app-arm64-v8a-release.apk").write_bytes(b"test-apk")
        destination = self.root / "dist"
        with self.assertRaises(ValueError):
            package_apks(source, destination, "0.2.0")
        self.assertFalse(destination.exists())

    def test_packaging_preserves_apks_and_writes_verifiable_checksums(self):
        source = self.root / "source"
        source.mkdir()
        for abi in ABIS:
            (source / f"app-{abi}-release.apk").write_bytes(abi.encode())
        destination = self.root / "dist"
        package_apks(source, destination, "0.2.0")
        checksums = (destination / "SHA256SUMS").read_text().splitlines()
        self.assertEqual(len(checksums), 3)
        for row in checksums:
            digest, name = row.split("  ")
            self.assertEqual(
                hashlib.sha256((destination / name).read_bytes()).hexdigest(), digest
            )
        self.assertEqual(len(list(destination.glob("*.apk"))), 3)


if __name__ == "__main__":
    unittest.main()
