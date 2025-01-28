import os
import sys
import subprocess
from statistics import median

import anvio.utils as utils
import anvio.terminal as terminal
import anvio.filesnpaths as filesnpaths
import anvio.ccollections as ccollections

collection_name = sys.argv[1]

run = terminal.Run()
progress = terminal.Progress()

# Get collections
c = ccollections.Collections(r = run, p = progress)
c.populate_collections_dict("RESULTS/profile.db")

if collection_name not in c.collections_dict:
    raise ConfigError(f"Collection '{collection_name}' is not in this database :/.")

collection_info = c.collections_dict[collection_name]
run.info('Collection found', '"%s" (%d items in %d bins)' % (collection_name, collection_info['num_splits'], collection_info['num_bins']))

# Get collection data
collection_data = c.get_collection_dict(collection_name)

# learn genome names
genome_names = utils.get_columns_of_TAB_delim_file("RESULTS/DETECTION.txt")

# read in detection and coverage
detection = utils.get_TAB_delimited_file_as_dictionary("RESULTS/DETECTION.txt")
coverage = utils.get_TAB_delimited_file_as_dictionary("RESULTS/COVERAGE_Q2Q3.txt")

# collapse detection and coverage data based on decisions made during
# binning
D, C = {}, {}
for bin_name, metagenomes in collection_data.items():
    D[bin_name], C[bin_name] = {}, {}
    for genome_name in genome_names:
        detection_values = [float(detection[metagenome][genome_name]) for metagenome in metagenomes]
        coverage_values = [float(coverage[metagenome][genome_name]) for metagenome in metagenomes]

        D[bin_name][genome_name] = median(detection_values)
        C[bin_name][genome_name] = median(coverage_values)

# create an output directory to report results
output_directory_path = f"ZZ_SUMMARY_FOR_{collection_name}"
filesnpaths.gen_output_directory(output_directory_path, delete_if_exists=True, dont_warn=True)

# store new detection and coverage files into the output directory
utils.store_dict_as_TAB_delimited_file(D, f"{output_directory_path}/DETECTION.txt", headers=['metagenome'] + genome_names)
utils.store_dict_as_TAB_delimited_file(C, f"{output_directory_path}/COVERAGE_Q2Q3.txt", headers=['metagenome'] + genome_names)

# horrible bash commands below becuase meren is lazy:
os.chdir(output_directory_path)

def RUN(command, print_output=False):
    process = subprocess.Popen(command.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    output, error = process.communicate()

    if print_output:
        print(output)

# run fake interactive
RUN("anvi-interactive -p profile.db -d DETECTION.txt --manual --dry-run")

# add the tree for SAR11 phylogeny from Kelle
with open('layers_order.txt', 'w') as layers_order:
    phylogeny = open("../DATA/PHYLOGENY.txt").read()
    layers_order.write("item_name\tdata_type\tdata_value\n")
    layers_order.write(f"phylogeny\tnewick\t{phylogeny}")

# add layer orders
RUN("""anvi-import-misc-data layers_order.txt -p profile.db --target-data-table layer_orders""")

# add layer data about the genomes
RUN("""anvi-import-misc-data ../DATA/SAR11-INFO.txt -p profile.db --target-data-table layers""")

RUN("""anvi-matrix-to-newick DETECTION.txt -o detection_for_items.tree""")

# add default state
RUN("""anvi-import-state -p profile.db -n default -s ../DATA/default_summary.json""")

# add a run file for simplicity
with open('00_VISUALIZE.sh', 'w') as script:
    script.write("#!/bin/bash\n\n")
    script.write(f"""anvi-interactive -p profile.db -d DETECTION.txt --manual --title "Detection values for collection '{collection_name}'" -t detection_for_items.tree\n""")

RUN("""chmod +x 00_VISUALIZE.sh""")

run.info_single(f"Oi! Your summary for the collection '{collection_name}' is ready. Please run "
                f"the following command in your terminal to view your results now (at other times, "
                f"these results can be viewed without running this program but running the 00_VISUALIZE "
                f"script in that directory):", nl_after=1, nl_before=1)
run.info_single(f"    cd ZZ_SUMMARY_FOR_mtg_42723_kf/ && ./00_VISUALIZE.sh", level=0, nl_after=1)
