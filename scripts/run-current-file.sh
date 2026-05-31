#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <file>" >&2
  exit 2
fi

file=$1

if [ ! -f "$file" ]; then
  echo "file not found: $file" >&2
  exit 1
fi

ext=${file##*.}
base=$(basename "$file")
name=${base%.*}
tmpdir=${TMPDIR:-/tmp}
out="$tmpdir/nvim-run-$name-$$"

cleanup() {
  rm -f "$out"
}
trap cleanup EXIT

case "$ext" in
  c)
    cc "$file" -o "$out"
    "$out"
    ;;
  cc|cpp|cxx|C)
    c++ "$file" -std=c++17 -Wall -Wextra -o "$out"
    "$out"
    ;;
  go)
    go run "$file"
    ;;
  rs)
    rustc "$file" -o "$out"
    "$out"
    ;;
  sql)
    uv run "$(dirname "$0")/sql-runner.py" "$file"
    ;;
  py)
    python3 "$file"
    ;;
  lua)
    lua "$file"
    ;;
  sh|bash)
    bash "$file"
    ;;
  js|mjs)
    node "$file"
    ;;
  ts)
    if command -v tsx >/dev/null 2>&1; then
      tsx "$file"
    elif command -v ts-node >/dev/null 2>&1; then
      ts-node "$file"
    else
      echo "tsx or ts-node is required to run TypeScript files" >&2
      exit 127
    fi
    ;;
  *)
    echo "unsupported file type: .$ext" >&2
    exit 1
    ;;
esac
