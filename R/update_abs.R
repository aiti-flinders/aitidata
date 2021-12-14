#' Run data generating scripts
#'
#' @return NULL
#' 
#' @export
update_abs <- function() {
    file_paths <- purrr::map_chr(unique(aitidata::aitidata_catalogues$data_name), ~here::here("data-raw", paste0(., ".R")))
    purrr::map(file_paths, source)
}
