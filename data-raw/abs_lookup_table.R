library(readabs)
library(daitir)
library(dplyr)
library(stringr)

abs_lookup_table <- daitir::update_abs_lookup_table()

usethis::use_data(abs_lookup_table, overwrite = TRUE, internal = TRUE)
