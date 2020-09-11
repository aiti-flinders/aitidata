## code to prepare `update_abs` dataset goes here
to_update <- unique(abs_cats[abs_cats$next_release == Sys.Date(), ]$data_name)

if (length(to_update)) {
  message("everything is up to date!")
} else {
  file_paths <- purrr::map(to_update, ~here::here("data-raw", paste0(., ".R")))
  message(paste("updating", paste(sep = ",", collapse = " ", to_update)))
  purrr::map(file_paths, source)
}
