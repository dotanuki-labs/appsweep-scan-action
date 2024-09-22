#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -euo pipefail

readonly repo="Automattic/pocket-casts-android"
readonly version="7.72"
readonly asset="app-7.72.apk"
readonly download_url="https://github.com/$repo/releases/download/$version/$asset"
readonly package="pocket-casts-android.apk"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir%/*}"
actual_dir=$(pwd)

rm -rf "$actual_dir/.tmp" && mkdir "$actual_dir/.tmp"
curl -fsSL -o "$actual_dir/.tmp/$package" -C - "$download_url"
src/main.sh --archive "$actual_dir/.tmp/$package" --summary
