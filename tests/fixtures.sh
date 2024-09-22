#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -euo pipefail

readonly android_fixture="https://github.com/Automattic/pocket-casts-android/releases/download/7.72/app-7.72.apk"
readonly android_package="pocket-casts-android.apk"
readonly ios_fixture="https://github.com/Automattic/pocket-casts-ios/releases/download/7.72/PocketCasts.xcarchive.zip"
readonly ios_package="pocket-casts-ios.xcarchive"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir%/*}"
actual_dir=$(pwd)
rm -rf "$actual_dir/.tmp" && mkdir "$actual_dir/.tmp"

echo
echo "Downloading fixtures to $HOME/.tmp"
echo
curl -fsSL -o "$actual_dir/.tmp/$android_package" -C - "$android_fixture"
curl -fsSL -o "$actual_dir/.tmp/$ios_package" -C - "$ios_fixture"
