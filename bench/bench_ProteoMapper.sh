#!/bin/bash

# download tool (clips.pl and promast.pl) from http://tppms.org/pm/

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

PM_INDEX_exe=clips.pl
PM_SEARCH_exe=promast.pl

LOG_INDEX=log_fm_ProteoMapper_time_index.log
LOG_SEARCH=log_fm_ProteoMapper_time_search.log
LOG_RESULTSIZE=log_fm_ProteoMapper_resultsize.log


## otherwise only one thread will ever be launched
export NUMBER_OF_PROCESSORS=128

rm -rf $LOG_INDEX
rm -rf $LOG_SEARCH
rm -rf $LOG_RESULTSIZE

for threads in 1 16
do
  for prot_DB in $FASTA_FILES
  do
    prot_path="$work_dir/$prot_DB"
    prot_fastapath="$work_dir/${prot_DB}.fasta"
    echo "Using protein DB: $prot_fastapath"

    /usr/bin/time -f "%e;%M;$aa_count;$threads;${pep_fastapath_real};$prot_fastapath" -o $LOG_INDEX -a $PM_INDEX_exe -I -f "$prot_fastapath" 

    for pep_DB in ${PEP_DBs}
    do
      pep_fastapath="${prot_path}${pep_DB}.fasta"
      pep_fastapath_real="${prot_path}${pep_DB}.csv"   ## uses CSV, not FASTA!
      echo "  Using peptide DB: $pep_fastapath"

      for aa_count in {0..1}
      do
        # reset result file for this configuration
        : > results.csv

        ## restrict AAA to 1k ... otherwise the runtime gets crazy
        if [[ "$aa_count" -gt 0 && "$pep_DB" != "_trypsinated_1k" ]]; then
          continue
        fi

        if [[ "$aa_count" -eq 0 ]]; then
          # Single invocation (unchanged semantics)
          /usr/bin/time -f "%e;%M;$aa_count;$threads;${pep_fastapath_real};$prot_fastapath" \
            -o $LOG_SEARCH -a \
            $PM_SEARCH_exe -t $threads -f $aa_count -U "$prot_fastapath" "$pep_fastapath_real" \
            >> results.csv

        else
          # Aggregated timing for per-peptide execution
          total_time=0
          max_mem=0

          while IFS= read -r peptide
          do
            [[ -z "$peptide" ]] && continue

            # run per peptide and capture time output
            time_out=$(
              /usr/bin/time -f "%e %M" \
                $PM_SEARCH_exe -t $threads -f $aa_count -U "$prot_fastapath" "$peptide" \
                >> results.csv
            2>&1 )

            # parse time output
            elapsed=$(awk '{print $1}' <<< "$time_out")
            mem=$(awk '{print $2}' <<< "$time_out")

            # accumulate elapsed time
            total_time=$(awk -v a="$total_time" -v b="$elapsed" 'BEGIN{printf "%.6f", a+b}')

            # track maximum memory usage
            (( mem > max_mem )) && max_mem=$mem

          done < "$pep_fastapath_real"

          # write one aggregated timing entry
          printf "%s;%s;%s;%s;%s;%s\n" \
            "$total_time" \
            "$max_mem" \
            "$aa_count" \
            "$threads" \
            "$pep_fastapath_real" \
            "$prot_fastapath" >> "$LOG_SEARCH"
        fi

        # result size logging (unchanged)
        grep -oE '(sp|tr)\|' results.csv | wc -l >> "$LOG_RESULTSIZE"
      done

    done
  done
done