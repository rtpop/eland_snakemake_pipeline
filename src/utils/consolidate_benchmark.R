required_libraries <- c("data.table", "optparse")

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##

option_list <- list(
    optparse::make_option(c("-f", "--files"), type = "character", help = "Comma-separated list of paths to the filtering benchmark result files."),
    optparse::make_option(c("-o", "--output"), type = "character", help = "Path to output file")
)

opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)

# parse the input files
input_files <- strsplit(opt$files, ",")[[1]]

## --------- ##
## Variables ##
## --------- ##
OUT <- opt$output

## source functions
source(file.path("src", "utils", "consolidate_benchmark_fn.R"))

## Consolidate data
consolidated_data <- consolidate_data(input_files, OUT)

# End of the script