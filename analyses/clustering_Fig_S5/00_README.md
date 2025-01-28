If you just would like to run everything from scratch,
use the following command in an anvi'o dev environment:

    ./03_RUN.sh

Once you have run it, and if you wish to go back to
where you left things off rather than starting from
scratch, please run this:

    cd RESULTS/
    anvi-interactive -p profile.db \
                     -d DETECTION.txt \
                     -A sample_clusters.txt \
                     --manual \
                     --title "SAR11: Phylogenomics + Detection Across Metagenomes" \
                     -t detection_for_items.tree

That's it :)

Once you have some collections you would like to summarize,
run the following command in the main directory with a
collection name, such as `mtg_42723_kf`:

    python 04_SUMMARIZE_COLLECTION.py [COLLECTION_NAME]

Once the collection is summarized, you should find a new
directory called `ZZ_SUMMARY_FOR_[COLLECTION_NAME]/` with
a file that includes the anvi-interactive command to
visualize this summary. You can run it as many collections
as you like and each of them will create their own
directories for easy comparisons.


Note on what files to have ready:
To run from scratch you will want in a directory:

1) all of these files with code 
2) A directory called "DATA" that has files following those found in SAR11-genomes-from-the-tropical-Pacific/data/clustering_analyses
