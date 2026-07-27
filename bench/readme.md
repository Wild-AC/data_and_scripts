# Bechmarks

Set up all required tools (see Requirements below)
Run `bench_all.sh` (in a bash-like shell) to create the benchmark results for all tools.

Make sure your system is idle before running the benchmark.


# Requirements

Download (and compile) all dependent programs (see below) and make their executables available in the PATH environment variable before running `bench_all.sh`.


### Wild-AC

We provide a standalone C++ implementation of Wild-AC (v1.0) at https://github.com/Wild-AC/Wild-AC.

### Wu-Manber

Our C++ implementation of WuManber (v1.0) is heavily based on code by [Ray Burkholder](https://blog.raymond.burkholder.net/index.php?/archives/362-C++-Implementation-of-Wu-Manbers-Multi-Pattern-Search-Algorithm.html) and available at https://github.com/Wild-AC/WuManber.

### FM-Index

A C++ implementation of the FM-Index by Gottlieb, which was used in our benchmarks is available at https://github.com/Wild-AC/FM-Index.

### ProteoMapper

ProteoMapper (v1.6), last updated 3/3/2023, was downloaded from http://tppms.org/pm/.

### PeptideMapper

PeptideMapper (v5.1.9) was obtained from the Compomics suite at http://genesis.ugent.be/maven2/com/compomics/utilities/5.1.9/utilities-5.1.9.zip.
