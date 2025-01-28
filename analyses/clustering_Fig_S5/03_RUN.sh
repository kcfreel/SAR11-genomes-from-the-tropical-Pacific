#!/bin/bash

set -e

anvi-self-test -v

export NCLUST=30
export DIST=euclidean

rm -rf RESULTS/*
./00_REFORMAT_FILES.R
./01_GET_SAMPLE_CLUSTERS.R
./02_VISUALIZE_THINGS.sh
