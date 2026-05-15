# De Novo Genome Assembly

De novo assembly of paired-end Illumina reads from a simulated
*Staphylococcus aureus* strain, with assembly quality evaluation using QUAST.
Developed as part of BINF6310 at Northeastern University.


## Tools Used

- **SPAdes**: de novo genome assembler optimized for small genomes
- **QUAST**: assembly quality assessment
- **Apptainer/Singularity**: containerized execution on HPC
- **Slurm/srun**: HPC interactive session


## Structure

```
de-novo-genome-assembly/
├── run_assembly.sh
└── results/
    └── quast_report.txt
```


## Workflow

Input: paired-end FASTQ reads from a simulated *S. aureus* strain
(expected genome size ≈ 197,394 bp), downloaded from Zenodo.

```bash
# Download reads
wget -O seq_1.fq https://zenodo.org/record/582600/files/mutant_R1.fastq
wget -O seq_2.fq https://zenodo.org/record/582600/files/mutant_R2.fastq

# Run SPAdes inside Apptainer container
singularity exec -B "/scratch:/scratch,/courses:/courses" \
    spades_quast.sif \
    spades.py -o spades_output --pe1-1 seq_1.fq --pe1-2 seq_2.fq

# Run QUAST
singularity exec -B "/scratch:/scratch,/courses:/courses" \
    spades_quast.sif \
    quast.py -o quast_output spades_output/contigs.fasta
```


## Results

| Metric | Value |
|--------|-------|
| Total length | 179,288 bp |
| Expected genome size | 197,394 bp |
| N50 | 132,140 bp |
| GC (%) | 33.59% |
| L50 | 1 |
| L90 | 2 |
| # contigs | 6 |
| Largest contig | 132,140 bp |

Assembly recovered 179,288 bp out of an expected 197,394 bp (~91%).
The missing ~9% is typical for repetitive regions that are hard to assemble.
N50 of 132,140 bp with L50=1 means a single contig covers more than half
the assembly — indicating high contiguity with minimal fragmentation.

Full QUAST report: `results/quast_report.txt`


## Notes

**What is de novo assembly?**
Unlike reference-based alignment, de novo assembly reconstructs a genome
from scratch using only the reads themselves, without a reference.
SPAdes builds a de Bruijn graph from k-mers extracted from the reads,
then resolves the graph into contigs.

**What is N50?**
Sort all contigs longest to shortest and sum their lengths until you
reach 50% of the total assembly. N50 is the length of the contig at
that point. Higher N50 = fewer, longer contigs = more contiguous assembly.

**Why use a container?**
Apptainer (.sif) packages SPAdes and QUAST with all dependencies into a
portable image. Running tools inside a container ensures reproducible
results regardless of what software versions are installed on the host cluster.
