#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -e

readonly install_location="$HOME/bin"
readonly guardsquare="$install_location/guardsquare"
readonly installer_url="https://platform.guardsquare.com/cli/install.sh"

require_archive() {
    if [[ -z "$archive" ]]; then
        echo "✗ ERROR : expecting an 'archive' input"
        exit 1
    fi

    if [[ ! -f "$archive" ]]; then
        echo "✗ ERROR : '$archive' not found"
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

report_scan() {
    local scan_output="$1"
    local more_details="$2"

    if [[ -z "$more_details" ]]; then
        local url
        url=$(echo "$scan_output" | jq '.url')
        echo "Check scan details at : $url"
    else
        local id
        id=$(echo "$scan_output" | jq '.id')
        "$guardsquare" scan summary --wait-for static "$id"
    fi
}

execute_android_scan() {
    local archive="$1"
    local extras="$2"
    local summary="$3"
    local scan=

    if [[ -z "$extras" ]]; then
        echo "Scanning standalone archive : $archive"
        install_guardsquare_cli
        scan=$("$guardsquare" scan "$archive" --commit-hash "$GITHUB_SHA" --format "json")
    else
        require_r8_or_proguard_mappings
        echo "Scanning archive     : $archive"
        echo "R8/Proguard mappings  : $extras"
        install_guardsquare_cli
        scan=$("$guardsquare" scan "$archive" --mapping-file "$extras" --commit-hash "$GITHUB_SHA" --format "json")
    fi

    report_scan "$scan" "$summary"
}

execute_ios_scan() {
    local archive="$1"
    local extras="$2"
    local scan=

    if [[ -z "$extras" ]]; then
        echo "Scanning standalone archive : $archive"
        install_guardsquare_cli
        scan=$("$guardsquare" scan "$archive" --commit-hash "$GITHUB_SHA" --format "json")
    else
        require_dsyms_folder
        echo "Scanning archive : $archive"
        echo "dsyms location : $extras"
        install_guardsquare_cli
        scan=$("$guardsquare" scan "$archive" --dsym "$extras" --commit-hash "$GITHUB_SHA" --format "json")
    fi

    report_scan "$scan" "$summary"
}

archive=
extras=
summary=

while [ "$#" -gt 0 ]; do
    case "$1" in
    --archive)
        archive="$2"
        shift 2
        ;;
    --extras)
        extras="$2"
        shift 2
        ;;
    --summary)
        summary=1
        shift 1
        ;;
    *)
        error "Unknown argument: $1"
        exit 1
        ;;
    esac
done

require_archive

case "$archive" in
*.apk | *.aab)
    execute_android_scan "$archive" "$extras" "$summary"
    ;;
*.xcarchive | *.ipa)
    execute_ios_scan "$archive" "$extras" "$summary"
    ;;
*)
    echo "Error: unsupported archive → $archive"
    echo
    echo "Supported archives :"
    echo
    echo "- Android : .aab, .apk"
    echo "- iOS     : .ipa, .xcarchive"
    echo
    exit 1
    ;;
esac
