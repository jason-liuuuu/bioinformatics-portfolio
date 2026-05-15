#!/bin/bash
# De novo genome assembly pipeline
# Tools: SPAdes + QUAST via Apptainer container
# Input: paired-end Illumina reads (S. aureus simulated strain)

set -euo pipefail

# Paths
WORKDIR="/scratch/${USER}/spades_quast_run"
SIF="/courses/BINF6310.202630/data/assembly/spades_quast.sif"
BIND="-B /scratch:/scratch,/courses:/courses"

# URLs
SEQ_URL_1="https://zenodo.org/record/582600/files/mutant_R1.fastq"
SEQ_URL_2="https://zenodo.org/record/582600/files/mutant_R2.fastq"

# Setup
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Download reads
wget -O seq_1.fq ${SEQ_URL_1}
wget -O seq_2.fq ${SEQ_URL_2}

# Run SPAdes
singularity exec ${BIND} ${SIF} \
    spades.py -o spades_output \
    --pe1-1 seq_1.fq \
    --pe1-2 seq_2.fq

# Run QUAST
singularity exec ${BIND} ${SIF} \
    quast.py -o quast_output \
    spades_output/contigs.fasta

echo "Assembly complete. Results in ${WORKDIR}/quast_output/report.txt"
