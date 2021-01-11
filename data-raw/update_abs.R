## code to prepare `update_abs` dataset goes here
library(dplyr)
library(purrr)
library(lubridate)

to_update <- build_daitir() %>% 
  dplyr::filter(mtime < current_release) %>%
  dplyr::pull(data_name) %>%
  unique()


if (length(to_update) == 0) {
  message("everything is up to date!")
} else {
  file_paths <- purrr::map(to_update, ~here::here("data-raw", paste0(., ".R")))
  message(paste("Found out of date datasets: ", paste(collapse = ", ", to_update)))
  purrr::map(file_paths, source)
}
