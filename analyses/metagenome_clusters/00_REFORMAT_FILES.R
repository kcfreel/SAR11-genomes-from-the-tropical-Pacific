#!/usr/bin/env Rscript
# Visualize the squared mean error per number of k-means clusters given a distance matrix

# set the work directory
setwd('~/Dropbox/KELLE_SAR11')

# reformat detection and coverage files
detection <- read.table("DATA/DETECTION.csv", sep=",", header=TRUE, row.names=1)
detection <- cbind(rownames(detection), data.frame(detection, row.names=NULL))
names(detection)[names(detection) == 'rownames(detection)'] <- 'sample'

coverage <- read.table("DATA/Q2Q3.csv", sep=",", header=TRUE, row.names=1)
coverage <- cbind(rownames(coverage), data.frame(coverage, row.names=NULL))
names(coverage)[names(coverage) == 'rownames(coverage)'] <- 'sample'

# some values for filtration
detection_cutoff <- 0.5
min_num_samples_detected <- 5
sample_names_to_remove <- c()

for(sample_name in detection$sample){
  sample_detection <- as.numeric(detection[detection$sample == sample_name, -1])
  num_samples_with_good_detection <- length(sample_detection[sample_detection > detection_cutoff])

  if(!num_samples_with_good_detection >= min_num_samples_detected){
    sample_names_to_remove <- append(sample_names_to_remove, sample_name)
  }
}

detection_filtered <- detection[!detection$sample %in% sample_names_to_remove, ]
coverage_filtered <- coverage[!coverage$sample %in% sample_names_to_remove, ]

write.table(detection_filtered, "RESULTS/DETECTION.txt", sep="\t", row.names=FALSE, quote = FALSE)
write.table(coverage_filtered, "RESULTS/COVERAGE_Q2Q3.txt", sep="\t", row.names=FALSE, quote = FALSE)
