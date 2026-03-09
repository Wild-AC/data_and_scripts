#!/usr/bin/env bash

set -euo pipefail

shopt -s nullglob

for csv in *k.csv; do
    echo "Processing $csv"
    awk '
       !seen[$0]++ {
           printf ">a_%d\n%s\n", ++n, $0
       }
    ' "$csv" > "${csv%.csv}_unique.fasta"
done
