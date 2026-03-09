#!/usr/bin/env bash

# Usage: ./make_single_line_fasta.sh input.fasta > output.fasta

awk '
    /^>/ {
        # If not the first record, print a newline before header
        if (seq) {
            print seq
            seq = ""
        }
        print   # print the header as-is
        next
    }
    {
        # Append sequence lines without spaces/newlines
        seq = seq $0
    }
    END {
        # Print the last sequence
        if (seq) print seq
    }
' "$1"
