/*
 * Nextflow DSL2 pipeline for Bowtie2 alignment
 * Task III
 */

params.reference_index = "reference_index"
params.reads           = "./*.fastq"

process ALIGN {

    input:
    path fastq
    path index_files

    output:
    path "${fastq.baseName}.sam"

    script:
    """
    bowtie2 -x ${params.reference_index} -U ${fastq} -S ${fastq.baseName}.sam
    """
}

workflow {
    reads_ch = Channel.fromPath(params.reads)
    index_ch = Channel.fromPath("${params.reference_index}*.bt2").collect()
    ALIGN(reads_ch, index_ch)
}
