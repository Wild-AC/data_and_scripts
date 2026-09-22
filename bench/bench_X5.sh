#!/bin/bash

# Benchmark on the 5%-X-masked protein DBs 
#
# Compares three searchers on the same DB / peptide set:
#   WildAC   - Wild-AC (Aho-Corasick with wildcards)
#   FM(SS)   - aho_fm, optimum search schemes,  prebuilt index
#   FM(BT)   - aho_fm, backtracking,            prebuilt index
#
# Note: the DB is the _X5 (masked) FASTA, while the peptides are the ones
# digested from the *unmasked* DB 

set -uo pipefail

# base names; the DB gets "_X5.fasta", the peptides "<PEP_DB>.fasta"
FASTA_FILES="uniprotkb_proteome_UP000002311_2025_07_15_saccCerev_yeast_SPTR
uniprotkb_proteome_UP000005640_2025_07_15_human_SPTR
uniprot_sprot
"

PEP_DBs="_trypsinated_1k
_trypsinated_10k
_trypsinated_100k
_trypsinated_500k"

work_dir="../databases"

INDEX_TYPE=wt

AC_exe=WildAC
FM_exe=fm

for e in "$AC_exe" "$FM_exe"; do
  [ -f "$e" ] || { echo "missing executable: $e" >&2; exit 1; }
  # 126 == found but cannot be executed (no +x, or wrong architecture);
  # without this the runs below would just fill the logs with shell errors.
  "$e" --version >/dev/null 2>&1
  [ $? -eq 126 ] && { echo "cannot execute: $e (not +x, or wrong architecture)" >&2; exit 1; }
done

# check every input up front 
missing=0
for prot_DB in $FASTA_FILES; do
  [ -r "$work_dir/${prot_DB}_X5.fasta" ] || { echo "missing DB: $work_dir/${prot_DB}_X5.fasta" >&2; missing=1; }
  for pep_DB in $PEP_DBs; do
    [ -r "$work_dir/${prot_DB}${pep_DB}.fasta" ] || { echo "missing peptides: $work_dir/${prot_DB}${pep_DB}.fasta" >&2; missing=1; }
  done
done
[ $missing -eq 0 ] || exit 1

rm -f log_ac_X5.txt log_fm_X5_SS.txt log_fm_X5_BT.txt

# Build the FM index once per DB up front, so the timed runs below all measure
# search on a loaded index (and not whoever went first paying for it).
for prot_DB in $FASTA_FILES
do
  prot_fastapath="$work_dir/${prot_DB}_X5.fasta"
  if [ ! -s "${prot_fastapath}.${INDEX_TYPE}.idx" ]; then
    echo "building ${INDEX_TYPE} index for ${prot_DB}_X5.fasta ..."
    $FM_exe -r "$prot_fastapath" -i "$work_dir/${prot_DB}_trypsinated_1k.fasta" \
            --count-only -t 16 --aaa 0 -k 0 \
            --always-build-index --index_type $INDEX_TYPE >/dev/null 2>&1
  fi
done

for threads in 1 16
do
  for prot_DB in $FASTA_FILES
  do
    prot_fastapath="$work_dir/${prot_DB}_X5.fasta"
    echo "Using protein DB: $prot_fastapath"

    for pep_DB in ${PEP_DBs}
    do
      pep_fastapath="$work_dir/${prot_DB}${pep_DB}.fasta"
      echo "  Using peptide DB: $pep_fastapath  (threads=$threads)"

      for aa_count in {0..5}
      do
        $AC_exe "$prot_fastapath" "$pep_fastapath" $threads "$aa_count" 0            2>>log_ac_X5.txt
        $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa $aa_count -k 0                 --index_type $INDEX_TYPE 2>>log_fm_X5_SS.txt
        $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa $aa_count -k 0 --backtracking  --index_type $INDEX_TYPE 2>>log_fm_X5_BT.txt
      done
    done
  done
done

echo "done -> log_ac_X5.txt, log_fm_X5_SS.txt, log_fm_X5_BT.txt"
