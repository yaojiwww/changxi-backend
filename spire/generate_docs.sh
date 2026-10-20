#!/usr/bin/env bash

# This script generates documentation for all modules in the current directory using cjdoc.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
OUTPUT_ROOT="$ROOT_DIR/docs"
CJDOC_BIN="${CJDOC_BIN:-cjdoc}"

if ! command -v "$CJDOC_BIN" >/dev/null 2>&1; then
    echo "error: cjdoc command not found: $CJDOC_BIN" >&2
    exit 1
fi

mkdir -p "$OUTPUT_ROOT"

generated_count=0

for module_dir in "$ROOT_DIR"/*; do
    if [[ ! -d "$module_dir" ]]; then
        continue
    fi

    module_name="$(basename "$module_dir")"
    manifest_path="$module_dir/cjpm.toml"
    source_dir="$module_dir/src"

    if [[ ! -f "$manifest_path" || ! -d "$source_dir" ]]; then
        continue
    fi

    output_dir="$OUTPUT_ROOT/$module_name"

    echo "==> Generating $module_name"
    rm -rf "$output_dir"
    mkdir -p "$output_dir"
    "$CJDOC_BIN" "$source_dir" -o "$output_dir" -f markdown

    generated_count=$((generated_count + 1))
done

echo
echo "Generated docs for $generated_count module(s) into $OUTPUT_ROOT"
