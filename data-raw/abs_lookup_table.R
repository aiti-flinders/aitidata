library(readabs)
library(daitir)
library(dplyr)
library(stringr)

abs_lookup_table <- readabs:::abs_lookup_table %>%
  rowwise() %>%
  mutate(
    data_name = str_replace_all(catalogue, "-", "_"),
    next_release = daitir::abs_next_release(catalogue)
  ) %>%
  ungroup()


usethis::use_data(abs_lookup_table, overwrite = TRUE, internal = TRUE)
