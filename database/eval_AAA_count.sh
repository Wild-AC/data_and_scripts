#!/usr/bin/env bash

# Usage: ./eval_AAA_count.sh proteins.fasta

if [ $# -ne 1 ]; then
  echo "Usage: $0 <fasta_file>" >&2
  exit 1
fi

FASTA="$1"

awk '
BEGIN {
  # Ambiguous amino acids (IUPAC)
  amb = "[BXZJ]"
  seq = ""
}

# When we hit a header, process the previous sequence
/^>/ {
  if (seq != "") {
    process_sequence(seq)
    seq = ""
  }
  next
}

# Accumulate multiline sequence
{
  gsub(/[ \t\r\n]/, "", $0)
  seq = seq $0
}

# Process last sequence at EOF
END {
  if (seq != "") {
    process_sequence(seq)
  }

  # Print sorted statistics
  n = asorti(count, keys, "@ind_num_asc")
  for (i = 1; i <= n; i++) {
    k = keys[i]
    printf "%d-mer: %d\n", k, count[k]
  }
}

# Function to count ambiguous runs
function process_sequence(s,   i, aa, run) {
  run = 0
  for (i = 1; i <= length(s); i++) {
    aa = substr(s, i, 1)
    if (aa ~ amb) {
      run++
    } else {
      if (run > 0) {
        count[run]++
        run = 0
      }
    }
  }
  if (run > 0) {
    count[run]++
  }
}
' "$FASTA"
