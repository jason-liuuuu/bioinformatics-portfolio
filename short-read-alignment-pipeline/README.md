# Short-Read Alignment Pipeline

Aligning paired-end Illumina reads to the human reference genome (GRCh38),
covering FASTQ quality trimming, short-read alignment, and alignment QC.
Developed as part of BINF6310 at Northeastern University.

## Tools Used

- **minimap2**: alignment with short-read preset (`-ax sr`)
- **Bowtie2**: BWT-indexed alignment for short reads
- **cutadapt**: quality trimming (Phred Q < 20)
- **Nextflow DSL2**: pipeline automation
- **samtools**: alignment QC (flagstat, idxstats)
- **Slurm/sbatch**: HPC job submission

## Structure

```
short-read-alignment-pipeline/
├── minimap2-slurm/
│   ├── minimap2_job.sbatch
│   └── ERR4277894_flagstat.txt
└── bowtie2-nextflow/
    ├── fastq_processing.nf
    ├── alignment.nf
    └── sample_output/
        ├── alignment_task2.sam
        └── alignment_task3.sam
```

## Part 1: Paired-End Alignment to GRCh38 (minimap2 + Slurm)

Aligned 64.5M paired-end reads from sample ERR4277894 to GRCh38
using minimap2 (`-ax sr` preset) on an HPC cluster via sbatch.

**Results (ERR4277894_flagstat.txt):**
- Total reads: 64,505,011
- Mapping rate: 99.33%
- Properly paired: 97.24%

`samtools flagstat` reports summary statistics from a BAM file —
total reads, mapped reads, paired reads, and singleton counts.

`samtools idxstats` reports per-chromosome alignment stats in four columns:
chromosome name, sequence length, mapped reads, and unmapped reads.

## Part 2:  Short-Read Alignment Pipeline (Bowtie2 + Nextflow DSL2)

### Task I:  FASTQ trimming (`fastq_processing.nf`)

Trims bases below Phred Q20 using cutadapt. Q20 corresponds to a 1% error rate;
removing these improves downstream alignment accuracy.

```bash
nextflow run fastq_processing.nf
```

### Task II: Manual Bowtie2 alignment

```bash
bowtie2-build reference_genome.fa reference_index
bowtie2 -x reference_index -U input.fastq -S output.sam
```

`-x` specifies the index prefix from `bowtie2-build`.
`-U` is a single-end FASTQ input. `-S` is the output SAM file.

### Task III: Bowtie2 pipeline (`alignment.nf`)

Wraps Task II into a Nextflow DSL2 pipeline.
Nextflow stages files into an isolated work directory per task,
handles parallelism, and supports `resume` to skip completed steps.

```bash
nextflow run alignment.nf
```
---
## Notes

**Why build an index first?**
Both Bowtie2 and minimap2 need a pre-built index to efficiently locate
candidate alignment positions without scanning the full genome per read.

**SAM FLAG field**
FLAG=0 means the read is mapped to the forward strand; FLAG=16 means the read is reverse strand.
CIGAR `29M` means 29 consecutive matches. `NM:i:0` means zero mismatches.

**minimap2 vs Bowtie2**
Bowtie2 uses a BWT-FM index optimized specifically for short Illumina reads.
minimap2 is more general — it supports long reads, splice-aware alignment,
and assembly-to-assembly mapping using a minimizer-based index.

