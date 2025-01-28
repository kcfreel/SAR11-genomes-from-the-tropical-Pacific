#!/usr/bin/env Rscript
# Visualize the squared mean error per number of k-means clusters given a distance matrix

library(stringr)

# set number of clusters and distance
vars <- Sys.getenv(c("NCLUST", "DIST"))

if (vars["NCLUST"] == "") {
  num_clusters <- 30
} else {
  num_clusters <- as.numeric(vars["NCLUST"])
}

if (vars["DIST"] == "") {
  distance_metric <- 'euclidean'
} else {
  distance_metric <- as.character(vars["DIST"])
}

# set the work directory
setwd('~/Dropbox/KELLE_SAR11/')

# read in the detection data
detection <- read.table("RESULTS/DETECTION.txt", header=TRUE, row.names=1)

# calculate a distance matrix between samples
distance_matrix <- dist(detection, method = distance_metric)

# get k-means for 5
k <- kmeans(distance_matrix, centers=num_clusters)
x <- data.frame(factor(k$cluster))
x <- cbind(rownames(x), data.frame(x, row.names=NULL))
names(x) <- c('sample', 'cluster')

# make names look better
x$cluster <- paste("cluster", str_pad(x$cluster, 3, pad = "0"), sep="_")

write.table(x, "RESULTS/sample_clusters.txt", sep="\t", row.names=FALSE, quote = FALSE)
