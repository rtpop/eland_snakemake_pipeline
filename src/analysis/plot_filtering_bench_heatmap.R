required_libraries <- c("data.table",
                        "ggplot2",
                        "ggrepel",
                        "ggpubr",
                        "dplyr",
                        "tidyr",
                        "purrr",
                        "RColorBrewer",
                        "stringr",
                        "magrittr",
                        "optparse",
                        "reshape2")
for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##
option_list <- list(
    optparse::make_option(c("-i", "--input"), type = "character", help = "Consolidated filtering benchmark dataframe file path"),
    optparse::make_option(c("-o", "--output"), type = "character", help = "Path to output file (pdf, png, etc)"),
    optparse::make_option(c("-m", "--metric"), type = "character", default = "Modularity",
                          help = "Filtering method to plot (default: Modularity). Options: 'Modularity', 'density', 'edges'"),
    optparse::make_option(c("-f", "--filtering"), type = "character", default = "all",
                          help = "Filtering method to plot (default: all). Options: 'HEDGEHOG filtered PANDA', 'Prior filtered', 'Unfiltered'"),
    optparse::make_option(c("-s", "--separate_files"), type = "logical", default = FALSE,
                          help = "Whether to save separate files for each filtering method (default: FALSE). Only used if filtering is set to 'all'.")
)

opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)

source('src/analysis/plot_filtering_bench_fn.R')

## --------- ##
## Variables ##
## --------- ##
FILE <- opt$input
OUT <- opt$output
METRIC <- opt$metric
FILTERING <- opt$filtering

if (FILTERING == "all" && opt$`separate_files`) {
  # Read the data to get available filtering methods
  df <- data.table::fread(FILE, header = TRUE)
  filtering_methods <- unique(df$Network)
  lapply(filtering_methods, function(filt) {
    p <- plot_heatmap(FILE, metric = METRIC, filtering = filt)
    out_file <- file.path(OUT, paste0("heatmap_", filt, ".pdf"))
    str(OUT)
    ggsave(filename = out_file, plot = p, width = 5, height = 5)
    
  })
} else {
  p <- plot_heatmap(FILE, metric = METRIC, filtering = FILTERING)
  out_file <- file.path(OUT, paste0("heatmap_", FILTERING, ".pdf"))
  ggsave(filename = out_file, plot = p, width = 5, height = 5)
}

