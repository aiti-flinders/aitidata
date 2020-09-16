## code to prepare `update_abs` dataset goes here
to_update <- unique(daitir:::abs_cats[daitir:::abs_cats$next_release == lubridate::today(tzone = "Australia/Adelaide"), ]$data_name)

if (length(to_update) == 0) {
  message("everything is up to date!")
} else {
  file_paths <- purrr::map(to_update, ~here::here("data-raw", paste0(., ".R")))
  message(paste("updating", paste(sep = ",", collapse = " ", to_update)))
  purrr::map(file_paths, source)
}
