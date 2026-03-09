#!/bin/bash

## require single-line FASTAs!

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 input.fasta" >&2
  exit 1
fi

awk '
  NR % 2 == 1 { printf "%s\t", $0; next }
  NR % 2 == 0 { print $0 }
' "$1" \
| shuf \
| awk -F'\t' '{ print $1 "\n" $2 }'
