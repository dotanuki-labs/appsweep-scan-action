#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -e

readonly install_location="$HOME/bin"
readonly guardsquare="$install_location/guardsquare"
readonly installer_url="https://platform.guardsquare.com/cli/install.sh"

readonly artifact="$1"
readonly extras="$2"

require_artifact() {
    if [[ -z "$artifact" ]]; then
        echo "✗ ERROR : expecting an 'artifact' input"
        exit 1
    fi

    if [[ ! -f "$artifact" ]]; then
        echo "✗ ERROR : '$artifact' not found"
        exit 1
    fi
}

require_r8_or_proguard_mappings() {
    if [[ ! -f "$extras" ]]; then
        echo "✗ ERROR : '$extras' R8/proguard mapping file not found"
        exit 1
    fi
}

require_dsyms_folder() {
    if [[ ! -d "$extras" ]]; then
        echo "✗ ERROR : '$extras' folder not found"
        exit 1
    fi
}

install_guardsquare_cli() {
    mkdir -p "$install_location"
    curl -sSL "$installer_url" | sh -s -- -y --bin-dir "$install_location"
}

execute_android_scan() {
    local scan_id

    if [[ -z "$extras" ]]; then
        echo "Scanning standalone artifact : $artifact"
        install_guardsquare_cli
        scan_id=$("$guardsquare" scan "$artifact" --commit-hash "$GITHUB_SHA" --format "{{.ID}}")
    else
        require_r8_or_proguard_mappings
        echo "Scanning artifact     : $artifact"
        echo "R8/Proguard mappings  : $extras"
        install_guardsquare_cli
        scan_id=$("$guardsquare" scan "$artifact" --mapping-file "$extras" --commit-hash "$GITHUB_SHA" --format "{{.ID}}")
    fi

    "$guardsquare" scan summary --wait-for static "$scan_id" --format json | jq
}

execute_ios_scan() {
    local scan_id

    if [[ -z "$extras" ]]; then
        echo "Scanning standalone artifact : $artifact"
        install_guardsquare_cli
        scan_id=$("$guardsquare" scan "$artifact" --commit-hash "$GITHUB_SHA" --format "{{.ID}}")
    else
        require_dsyms_folder
        echo "Scanning artifact : $artifact"
        echo "dsyms location    : $extras"
        install_guardsquare_cli
        scan_id=$("$guardsquare" scan "$artifact" --dsym "$extras" --commit-hash "$GITHUB_SHA" --format "{{.ID}}")
    fi

    "$guardsquare" scan summary --wait-for static "$scan_id" --format json | jq
}

require_artifact

case "$artifact" in
*.apk | *.aab)
    execute_android_scan
    ;;
*.xcarchive | *.ipa)
    execute_ios_scan
    ;;
*)
    echo "Error: unsupported artifact → $artifact"
    exit 1
    ;;
esac
