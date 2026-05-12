/*
 * Nextflow DSL2 pipeline for FASTQ quality trimming
 * Module 08 - Task I
 */

// Define the trimming process
process TRIM_AND_FILTER {

    input:
    path fastq

    output:
    path "trimmed_${fastq.baseName}.fastq"

    script:
    """
    cutadapt -q 20 -o trimmed_${fastq.baseName}.fastq ${fastq}
    """
}

// Define the workflow
workflow {
    // Create a channel from all .fastq files in the current directory
    fastq_ch = Channel.fromPath('./*.fastq')

    // Pass the channel into the trimming process
    TRIM_AND_FILTER(fastq_ch)
}
