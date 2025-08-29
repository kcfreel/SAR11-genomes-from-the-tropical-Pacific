#!/bin/bash

set -e

cd ~/Dropbox/KELLE_SAR11/RESULTS

rm -rf detection.tree profile.db layers_order.txt collection.txt

# run fake interactive
anvi-interactive -p profile.db -d DETECTION.txt -A sample_clusters.txt --manual --dry-run

# matrix to newick for samples
anvi-matrix-to-newick DETECTION.txt --transpose -o detection_for_samples.tree

# matrix to newick for items
anvi-matrix-to-newick DETECTION.txt -o detection_for_items.tree

# import collection
tail -n +2 sample_clusters.txt > collection.txt
anvi-import-collection collection.txt -p profile.db -C k_means_clusters

# generate a layers order file and add the tree for detection
echo -e "item_name\tdata_type\tdata_value" > layers_order.txt
echo -n -e "detection\tnewick\t" >> layers_order.txt

# also add the tree for SAR11 phylogeny from Kelle
cat detection_for_samples.tree >> layers_order.txt
echo -n -e "phylogeny\tnewick\t" >> layers_order.txt
cat ../DATA/PHYLOGENY.txt >> layers_order.txt

# add layer orders
anvi-import-misc-data layers_order.txt -p profile.db --target-data-table layer_orders

# add layer data about the genomes
anvi-import-misc-data ../DATA/SAR11-INFO.txt -p profile.db --target-data-table layers

# add state
anvi-import-state -p profile.db -n default -s ../DATA/default.json

# run interactive
anvi-interactive -p profile.db -d DETECTION.txt -A sample_clusters.txt --manual --title "SAR11: Phylogenomics + Detection Across Metagenomes" -t detection_for_items.tree
