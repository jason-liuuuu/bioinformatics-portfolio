#!/bin/bash
#SBATCH --job-name=minimap2_alignment
#SBATCH --partition=courses
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=%j_minimap2.out
#SBATCH --error=%j_minimap2.err

module load miniconda3
source activate binf6310

REF="/courses/BINF6310.202630/data/alignment/GRCh38/GRCh38.mmi"
READ1="/courses/BINF6310.202630/data/alignment/ERR4277894_1.fastq.gz"
READ2="/courses/BINF6310.202630/data/alignment/ERR4277894_2.fastq.gz"
OUTDIR="/scratch/${USER}/module07"
mkdir -p ${OUTDIR}

minimap2 -ax sr -t ${SLURM_CPUS_PER_TASK} \
    ${REF} ${READ1} ${READ2} | \
    samtools sort -o ${OUTDIR}/ERR4277894.bam

samtools index ${OUTDIR}/ERR4277894.bam
samtools flagstat ${OUTDIR}/ERR4277894.bam > ${OUTDIR}/ERR4277894_flagstat.txt
samtools idxstats ${OUTDIR}/ERR4277894.bam > ${OUTDIR}/ERR4277894_idxstats.txt
