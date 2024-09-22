#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -euo pipefail

readonly repo="uazo/cromite"
readonly version="v129.0.6668.59-bbcb812cffa4e2815760cd7fc3e34b00b4e39ea1"

readonly apk_asset="arm64_ChromePublic.apk"
readonly apk_download_url="https://github.com/$repo/releases/download/$version/$apk_asset"
readonly apk="cromite-android.apk"

readonly mappings_asset="arm64_ChromePublic.apk.mapping"
readonly mappings_download_url="https://github.com/$repo/releases/download/$version/$mappings_asset"
readonly mappings="mappings.txt"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir%/*}"
actual_dir=$(pwd)

rm -rf "$actual_dir/.tmp" && mkdir "$actual_dir/.tmp"
curl -fsSL -o "$actual_dir/.tmp/$apk" -C - "$apk_download_url"
curl -fsSL -o "$actual_dir/.tmp/$mappings" -C - "$mappings_download_url"

src/main.sh "$actual_dir/.tmp/$apk" "$actual_dir/.tmp/$mappings"
