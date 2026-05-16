# RNA-Seq Quantification with Kallisto

Transcript-level quantification of RNA-seq data using Kallisto pseudo-alignment,
with per-sample outputs merged into a count matrix using R.
Developed as part of BINF6310 at Northeastern University.


## Tools Used

- **Kallisto**: pseudo-alignment and transcript quantification
- **R (readr, dplyr)**: merging per-sample outputs into a count matrix
- **Apptainer**: containerized execution on HPC


## Structure

```
rnaseq-quantification-kallisto/
├── Kallisto-bash.sh
└── Kallisto-output-join.R
```


## Dataset

RNA-seq data from NCBI GEO accession **GSE240196** (BioProject PRJNA1002789).
15 samples from mouse (*Mus musculus*) CD4 and CD8 T cells at Day 0 and Day 7
post-transfer, profiling gene expression changes related to GvHD.

Reference transcriptome: Ensembl GRCm39 cDNA (`Mus_musculus.GRCm39.cdna.all.fa.gz`)


## Workflow

**Step 1: Build Kallisto index**
```bash
kallisto index -i Mus_musculus.idx Mus_musculus.GRCm39.cdna.all.fa.gz
```

**Step 2: Quantify all samples (`Kallisto-bash.sh`)**

Loops over all FASTQ files, runs `kallisto quant` on each sample,
and organizes outputs into per-sample directories.

```bash
kallisto quant -i Mus_musculus.idx -l 200 -s 20 -o $OUTPUT_DIR --single $FILE
```

- `-l 200`: estimated average fragment length
- `-s 20`: standard deviation of fragment length
- `--single`: single-end sequencing mode

**Step 3: Merge outputs into count matrix (`Kallisto-output-join.R`)**

Reads each sample's `abundance.tsv`, extracts `est_counts`,
and combines all samples into a single count matrix (`count_matrix.csv`).


## Output

- `kallisto-output/<sample>/abundance.tsv` — per-sample quantification
- `kallisto-output/count_matrix.csv` — merged count matrix (transcripts × samples)


## Notes

**Kallisto vs STAR**
Kallisto uses k-mer based pseudo-alignment rather than full base-by-base alignment.
It is significantly faster while producing accurate TPM and count estimates,
making it practical for large cohorts on HPC.

**Why align to transcriptome, not genome?**
RNA-seq reads come from mature mRNA, which has introns removed.
Aligning to a transcriptome reference avoids complications from intronic regions
and directly gives transcript-level quantification.

**Single-end parameters (`-l`, `-s`)**
Kallisto requires fragment length distribution parameters for single-end data
since it cannot infer them from read pairs. `-l 200 -s 20` are standard estimates
for typical Illumina RNA-seq libraries.
