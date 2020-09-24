## code to prepare `update_abs` dataset goes here
library(dplyr)
library(purrr)
library(lubridate)

to_update <- daitir:::abs_lookup_table %>%
  dplyr::filter(next_release == lubridate::today(tzone = "Australia/Adelaide")) %>%
  dplyr::pull(catalogue)

if (length(to_update) == 0) {
  message("everything is up to date!")
} else {
  file_paths <- purrr::map(to_update, ~here::here("data-raw", paste0(., ".R")))
  message(paste("updating", paste(sep = ",", collapse = " ", to_update)))
  purrr::map(file_paths, source)
}
