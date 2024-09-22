#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -e

readonly repo="Automattic/pocket-casts-ios"
readonly version="7.72"
readonly asset="PocketCasts.xcarchive.zip"
readonly download_url="https://github.com/$repo/releases/download/$version/$asset"
readonly package="pocket-casts-ios.xcarchive"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir%/*}"
actual_dir=$(pwd)

rm -rf "$actual_dir/.tmp" && mkdir "$actual_dir/.tmp"
curl -fsSL -o "$actual_dir/.tmp/$package" -C - "$download_url"

"$actual_dir"/scan/main.sh --archive "$actual_dir/.tmp/$package" --summary "true"
