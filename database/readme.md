This repository contains all FASTA input data and the bash scripts for Linux to create the input data for the algorithms benchmarked in the paper (Wild-AC, WuManber, FM-Index, ProteoMapper).

# Build the input data

1) extract uniprot_sprot.fasta.gz and uniprot_sprot_X5.fasta.gz (too large for GitHub otherwise)
```
gzip --decompress uniprot_sprot.fasta.gz   ## creates uniprot_sprot.fasta
gzip --decompress uniprot_sprot_X5.fasta.gz   ## creates uniprot_sprot_X5.fasta
```

2) run `make_shuffle_and_digest.sh`


Requirements:
  - to create the peptide input sets, OpenMS 3.5 or later needs to be installed (see https://openms.readthedocs.io/en/latest/about/installation/installation-on-gnu-linux.html) and on the PATH 
  