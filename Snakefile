## ------------------------------------------------------------------------------------------- ##
## HOW TO RUN                                                                                  ##
## Run from directory containing Snakefile                                                     ##
## ------------------------------------------------------------------------------------------- ##
## For dry run                                                                                 ##
## snakemake --cores 1 -np                                                                     ##
## ------------------------------------------------------------------------------------------- ##
## For local run                                                                               ##
## snakemake --cores 1                                                                         ##
## ------------------------------------------------------------------------------------------- ##
## For running with singularity container                                                      ##
## snakemake --cores 1 --use-singularity --singularity-args '\-e' --cores 1                    ##
## ------------------------------------------------------------------------------------------- ## ------------------------------ ##
## For running in the background                                                                                                 ##
## nohup snakemake --cores 1 --use-singularity --singularity-args '\-e' 2>&1 > logs/snakemake_$(date +'%Y-%m-%d_%H-%M-%S').log & ##
## ----------------------------------------------------------------------------------------------------------------------------- ##

##-----------##
## Libraries ##
##-----------##

import os 
import sys
import glob
from pathlib import Path
import time

## ----------------- ##
## Global parameters ##
## ----------------- ##

configfile: "config.yaml"

# Containers
PYTHON_CONTAINER = config["python_container"]
R_CONTAINER = config["r_container"]

# Directories
DATA_DIR = config["data_dir"]
OUTPUT_DIR = config["output_dir"]
SRC = config["src_dir"]
HEDGEHOG_DIR = os.path.join(OUTPUT_DIR, "{tissue_type}", "hedgehog_bug_fix_q_score")
GO_DIR = os.path.join(OUTPUT_DIR, "{tissue_type}", "go_enrichment")

# Other params
DELIMITER = config["delimiter"]
TISSUE = config["tissue"]

## ------------------------------ ##
## Download and process GTEx data ##
## ------------------------------ ##
GTEX_DATA_FILE = os.path.join(DATA_DIR, config["gtex_data_file"])
PROCESSING_LOG = os.path.join(DATA_DIR, config["processing_log"])
MOTIF_PRIOR = os.path.join(DATA_DIR, config["motif_prior"])

##-------##
## RULES ##
##-------##

rule all:
    input:

## ---------------------------- ##
## Download & process GTEX data ##
## ---------------------------- ##

rule downaload_gtex:
       output:
        GTEX_DATA_FILE
    params:
        out_dir = os.path.join(DATA_DIR, "download"), \
        log_file = os.path.join(DATA_DIR, "download", "download_gtex.log")
    container:
        PYTHON_CONTAINER
    message:
        "; Downloading GTEx data."
    shell:
        """
        mkdir -p {params.out_dir}
        curl --output {output} https://zenodo.org/records/838734/files/GTEx_PANDA_tissues.RData?download=1 > {params.log_file} 2>&1
        """

rule process_gtex:
    input:
        gtex_data = GTEX_DATA_FILE
    output:
        output_log = PROCESSING_LOG,
        prior = MOTIF_PRIOR
    params:
        out_dir = DATA_DIR,
        script = os.path.join(SRC, "process_gtex.R")
    container:
        R_CONTAINER
    message:
        "; Processing GTEx data."
    script:
        {params.script}