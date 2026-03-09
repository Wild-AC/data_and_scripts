#!/bin/bash

# Define protein DBs and their corresponding peptide DBs
FASTA_FILES="uniprotkb_proteome_UP000005640_2025_07_15_human_SPTR
uniprotkb_proteome_UP000000589_2025_07_23_musMusculus_SPTR
uniprot_sprot
uniprotkb_proteome_UP000002311_2025_07_15_saccCerev_yeast_SPTR
"


PEP_DBs="_trypsinated_1k
_trypsinated_10k
_trypsinated_100k
_trypsinated_500k"

work_dir="../database"

AC_exe=WildAC 

rm -rf log_ac_unique.txt

for threads in 1
do
  for prot_DB in $FASTA_FILES
  do
    prot_path="$work_dir/$prot_DB"
    prot_fastapath="$work_dir/${prot_DB}.fasta"
    echo "Using protein DB: $prot_fastapath"

    for pep_DB in ${PEP_DBs}
    do
      #pep_fastapath="${prot_path}${pep_DB}.fasta"
      pep_fastapath="${prot_path}${pep_DB}_unique.fasta"
      echo "  Using peptide DB: $pep_fastapath"

      for aa_count in {0}
      do
        $AC_exe "$prot_fastapath" "$pep_fastapath" $threads "$aa_count" 0   2>>log_ac_unique.txt
      done

      #do
       #  $AC_exe "$prot_fastapath" "$pep_fastapath" $threads 0 "$mm_count"   2>>log_ac_unique.txt
      #done
    done
  done
done