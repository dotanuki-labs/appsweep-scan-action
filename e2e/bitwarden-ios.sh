#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -euo pipefail

readonly repo="bitwarden/ios"
readonly version="v2024.9.1"

readonly ipa_asset="Bitwarden.iOS.2024.9.1.1092.ipa"
readonly ipa_download_url="https://github.com/$repo/releases/download/$version/$ipa_asset"
readonly ipa="bitwarden-ios.ipa"

readonly dsyms_asset="Bitwarden.iOS.2024.9.1.1092.dSYMs.zip"
readonly dsyms_download_url="https://github.com/$repo/releases/download/$version/$dsyms_asset"
readonly dsyms_zip="dsyms.zip"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${script_dir%/*}"
actual_dir=$(pwd)

rm -rf "$actual_dir/.tmp" && mkdir "$actual_dir/.tmp"
curl -fsSL -o "$actual_dir/.tmp/$ipa" -C - "$ipa_download_url"
curl -fsSL -o "$actual_dir/.tmp/$dsyms_zip" -C - "$dsyms_download_url"
unzip -d "$actual_dir/.tmp/dsyms" "$actual_dir/.tmp/$dsyms_zip" >/dev/null 2>&1

src/main.sh --archive "$actual_dir/.tmp/$ipa" --extras "$actual_dir/.tmp/dsyms"
