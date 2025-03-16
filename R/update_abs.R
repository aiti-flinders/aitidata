#' Run data generating scripts
#'
#' @return NULL
#' @export
#' 
update_abs <- function() {
  source_files <- list.files("data-raw")
  source_files <- paste0("data-raw/", source_files[grep(".R", source_files)])
  Map(source, source_files)
  devtools::document()
}
