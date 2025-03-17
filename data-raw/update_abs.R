source_files <- list.files("data-raw")
source_files <- paste0("data-raw/", source_files[grep(".R", source_files)])
#Exclude THIS file from being sourced - or else get stuck in a loop
source_files <- source_files[!grepl("data-raw/update_abs.R", source_files)]
Map(source, source_files)
devtools::document()

