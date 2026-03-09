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

work_dir="../databases"

FM_exe=fm
# e.g. $FM_exe -r uniprot-SPTR_humanIso+crap_FWBW.fasta -i QC_20140323_1_xtandem_noMod.fasta -t 16 --count-only -k 0 --aaa 1

rm -rf log_fm_wBuild.txt
rm -rf log_fm_loadIndex.txt
rm -rf log_fm_loadIndex_backtracking.txt

for index_type in wt fb64 fb ib
do
  for threads in 1 16
  do

    for prot_DB in $FASTA_FILES
    do
      prot_path="$work_dir/$prot_DB"
      prot_fastapath="$work_dir/${prot_DB}.fasta"
      echo "Using protein DB: $prot_fastapath"


      for pep_DB in ${PEP_DBs}
      do
        pep_fastapath="${prot_path}${pep_DB}.fasta"
        echo "  Using peptide DB: $pep_fastapath"


        for aa_count in {0..5}
        do
          $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa $aa_count -k 0 --always-build-index --index_type $index_type  2>>log_fm_wBuild.txt
          $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa $aa_count -k 0                      --index_type $index_type  2>>log_fm_loadIndex.txt
          $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa $aa_count -k 0 --backtracking        --index_type $index_type  2>>log_fm_loadIndex_backtracking.txt
        done

        #for mm_count in {0..1}
        #do
        #  $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa 0 -k $mm_count --always-build-index  --index_type $index_type  2>>log_fm_wBuild.txt
        #  $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa 0 -k $mm_count                       --index_type $index_type  2>>log_fm_loadIndex.txt
        #  $FM_exe -r "$prot_fastapath" -i "$pep_fastapath" --count-only -t $threads --aaa 0 -k $mm_count --backtracking         --index_type $index_type  2>>log_fm_loadIndex_backtracking.txt
        #done
      done
    done

  done
done