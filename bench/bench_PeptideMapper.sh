#!/bin/bash

# wget http://genesis.ugent.be/maven2/com/compomics/utilities/5.1.9/utilities-5.1.9.zip
#	unzip utilities-5.1.9.zip
#	cd utilities-5.1.9/
#Invocation:
#java -cp utilities-5.1.9.jar 
#com.compomics.cli.peptide_mapper.PeptideMapperCLI -p exampleFiles/PeptideMapping/yeast.fasta 
#exampleFiles/PeptideMapping/yeast-pep-1k.csv results.csv



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

work_dir="/group/ag_bsc/Projects/AhoCorasick/databases"

FM_jar=utilities-5.1.9.jar

# write param file:
#java -cp "SearchGUI-4.3.17.jar"  eu.isas.searchgui.cmd.IdentificationParametersCLI -out params_PeptideMapper.par

rm -rf log_fm_PeptideMapper_resultsize.log
rm -rf log_fm_PeptideMapper_time.log

for threads in 1 16
do

  for prot_DB in $FASTA_FILES
  do
    prot_path="$work_dir/$prot_DB"
    prot_fastapath="$work_dir/${prot_DB}.fasta"
    echo "Using protein DB: $prot_fastapath"


    for pep_DB in ${PEP_DBs}
    do
      pep_fastapath="${prot_path}${pep_DB}.csv"
      pep_fastapath_real="${prot_path}${pep_DB}.fasta"
      echo "  Using peptide DB: $pep_fastapath"


      for aa_count in {0..0}
      do
        # elapsed time; max mem in KB; command
        /usr/bin/time -f "%e;%M;$aa_count;$threads;${pep_fastapath_real};$prot_fastapath" -o log_fm_PeptideMapper_time.log -a  java -cp $FM_jar com.compomics.cli.peptide_mapper.PeptideMapperCLI  -p "$prot_fastapath" "$pep_fastapath" tmp_results.csv -c $threads -u params_PeptideMapper.par
        cat tmp_results.csv | wc -l >> log_fm_PeptideMapper_resultsize.log
      done

      for mm_count in {0..1}
      do
        echo ""
      done
    done
  done
done