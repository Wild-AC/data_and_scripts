#!/bin/bash


FASTA_FILES="uniprotkb_proteome_UP000005640_2025_07_15_human_SPTR
uniprotkb_proteome_UP000000589_2025_07_23_musMusculus_SPTR
uniprot_sprot
uniprotkb_proteome_UP000002311_2025_07_15_saccCerev_yeast_SPTR
"

#################
## print AA stats (requires OpenMS 3.5pre )
rm -f FileInfo_stats.txt
for f in $FASTA_FILES
do
  echo $'\n--' >> FileInfo_stats.txt
  echo "Processing $f" >> FileInfo_stats.txt
  FileInfo -in "${f}.fasta" | grep -E "B:|Z:|X:|J:|B/Z/X|Total am|Number of sequen" >> FileInfo_stats.txt
done

#########################
## randomize sequences (AAAs are not uniformly distributed)

for f in $FASTA_FILES
do
  echo "Randomize $f"
  ./make_single_line_fasta.sh "${f}.fasta" > "${f}_singleLine.fasta"
  ./make_shuffe_fasta.sh "${f}_singleLine.fasta" > "${f}_shuffled.fasta"
done



###################################
## sample from the foward databases

for f in $FASTA_FILES
do
	echo "Digesting $f"
  Digestor -in "${f}_shuffled.fasta" -out "${f}_trypsinated.fasta"  -missed_cleavages 2 -replace_ambiguous
  Digestor -in "${f}_shuffled.fasta" -out "${f}_trypsinated_withAAA.fasta"  -missed_cleavages 2
  echo $'\n--' >> FileInfo_stats.txt
  echo "Processing ${f}_trypsinated_withAAA.fasta"
  FileInfo -in "${f}_trypsinated.fasta" | grep -E "B:|Z:|X:|J:|B/Z/X|Total am|Number of sequen"
done


###################################
## sample 1k, 10k, 100k and 500k peptides

for f in $FASTA_FILES
do
	echo "Sampling $f"
  ## use 2x number of lines due to FASTA headers!
  cat "${f}_trypsinated.fasta" | head -n 2000 > "${f}_trypsinated_1k.fasta"
  cat "${f}_trypsinated.fasta" | head -n 20000 > "${f}_trypsinated_10k.fasta"
  cat "${f}_trypsinated.fasta" | head -n 200000 > "${f}_trypsinated_100k.fasta"
  cat "${f}_trypsinated.fasta" | head -n 1000000 > "${f}_trypsinated_500k.fasta"
  
  cat "${f}_trypsinated_withAAA.fasta" | head -n 2000    > "${f}_trypsinated_withAAA_1k.fasta"
  cat "${f}_trypsinated_withAAA.fasta" | head -n 20000   > "${f}_trypsinated_withAAA_10k.fasta"
  cat "${f}_trypsinated_withAAA.fasta" | head -n 200000  > "${f}_trypsinated_withAAA_100k.fasta"
  cat "${f}_trypsinated_withAAA.fasta" | head -n 1000000 > "${f}_trypsinated_withAAA_500k.fasta"
  
  cat "${f}_trypsinated.fasta" | head -n 2000 | grep ">" -v > "${f}_trypsinated_1k.csv"
  cat "${f}_trypsinated.fasta" | head -n 20000 | grep ">" -v > "${f}_trypsinated_10k.csv"
  cat "${f}_trypsinated.fasta" | head -n 200000 | grep ">" -v > "${f}_trypsinated_100k.csv"
  cat "${f}_trypsinated.fasta" | head -n 1000000 | grep ">" -v > "${f}_trypsinated_500k.csv"
done

