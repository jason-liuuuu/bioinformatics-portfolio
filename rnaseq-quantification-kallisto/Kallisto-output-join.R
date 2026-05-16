library(readr)
library(dplyr)

DIRECTORY <- "kallisto-output"

dirs <- list.dirs(path = DIRECTORY, full.names = TRUE, recursive = FALSE)

files <- sapply(dirs, function(d) {
  file.path(d, paste0(basename(d), ".tsv"))
})

read_kallisto <- function(file) {
  data <- read_tsv(file)
  counts <- data$est_counts
  names(counts) <- data$target_id
  return(counts)
}

data_list <- lapply(files, read_kallisto)

sample_names <- sapply(dirs, function(d) {
  basename(d)
})

count_matrix <- do.call(cbind, data_list)
colnames(count_matrix) <- sample_names

write.csv(count_matrix, file = paste0(DIRECTORY, "/count_matrix.csv"), row.names = TRUE)
