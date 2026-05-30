#!/usr/bin/env python3
"""Validate that the Android release workflow is building one new app version.

The Flutter Android Gradle project derives Android versionName/versionCode from
pubspec.yaml. This script verifies that the manual release input matches the
committed pubspec version, that Android still consumes Flutter's version values,
and (when a previous version is provided) that the requested version increased.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

VERSION_RE = re.compile(
    r"^(?:v)?(?P<major>0|[1-9]\d*)"
    r"\.(?P<minor>0|[1-9]\d*)"
    r"\.(?P<patch>0|[1-9]\d*)"
    r"\+(?P<build>0|[1-9]\d*)$"
)
PUBSPEC_VERSION_RE = re.compile(r"^version:\s*(?P<version>\S+)\s*$", re.MULTILINE)


@dataclass(frozen=True, order=True)
class ReleaseVersion:
    major: int
    minor: int
    patch: int
    build: int

    @classmethod
    def parse(cls, value: str, label: str) -> "ReleaseVersion":
        match = VERSION_RE.match(value.strip())
        if match is None:
            raise ValueError(
                f"{label} must use Flutter's full release format '<major>.<minor>.<patch>+<build>', "
                f"for example '0.2.0+2'. Got: {value!r}"
            )

        return cls(
            major=int(match.group("major")),
            minor=int(match.group("minor")),
            patch=int(match.group("patch")),
            build=int(match.group("build")),
        )

    def __str__(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}+{self.build}"


def read_pubspec_version(pubspec_path: Path) -> str:
    text = pubspec_path.read_text(encoding="utf-8")
    match = PUBSPEC_VERSION_RE.search(text)
    if match is None:
        raise ValueError(f"No top-level 'version:' entry found in {pubspec_path}")
    return match.group("version")


def verify_android_uses_flutter_version(gradle_path: Path) -> None:
    text = gradle_path.read_text(encoding="utf-8")
    required_lines = {
        "versionCode = flutter.versionCode": (
            "Android versionCode must be derived from pubspec.yaml via Flutter."
        ),
        "versionName = flutter.versionName": (
            "Android versionName must be derived from pubspec.yaml via Flutter."
        ),
    }

    missing_messages = [
        message for line, message in required_lines.items() if line not in text
    ]
    if missing_messages:
        raise ValueError("\n".join(missing_messages))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify release version consistency before publishing an Android APK."
    )
    parser.add_argument(
        "--release-version", required=True, help="Manual workflow input, e.g. 0.2.0+2"
    )
    parser.add_argument(
        "--previous-version",
        default="",
        help="Optional previous tag/release version, e.g. v0.1.0+1",
    )
    parser.add_argument("--pubspec", default="pubspec.yaml", type=Path)
    parser.add_argument("--android-gradle", default="android/app/build.gradle.kts", type=Path)
    args = parser.parse_args()

    try:
        requested_version = ReleaseVersion.parse(args.release_version, "release-version")
        pubspec_text_version = read_pubspec_version(args.pubspec)
        pubspec_version = ReleaseVersion.parse(pubspec_text_version, "pubspec.yaml version")

        if requested_version != pubspec_version:
            raise ValueError(
                "Release version input does not match pubspec.yaml. "
                f"Input: {requested_version}; pubspec.yaml: {pubspec_version}."
            )

        verify_android_uses_flutter_version(args.android_gradle)

        if args.previous_version.strip():
            previous_version = ReleaseVersion.parse(args.previous_version, "previous-version")
            if requested_version <= previous_version:
                raise ValueError(
                    "Release version must be newer than the latest existing release/tag. "
                    f"Requested: {requested_version}; latest existing: {previous_version}."
                )
            print(f"Release version {requested_version} is newer than {previous_version}.")
        else:
            print(f"Release version {requested_version} verified. No previous release tag was found.")

        print("pubspec.yaml and Android Gradle version wiring are consistent.")
        return 0
    except ValueError as error:
        print(f"Version verification failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
