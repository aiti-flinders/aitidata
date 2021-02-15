#' The filepath is returned invisibly which enables piping to \code{unzip()} or \code{readxl::read_excel}.
#'
#' @importFrom magrittr %>%
#' @importFrom glue glue
#' @importFrom dplyr filter pull slice
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom here here
#' @importFrom readabs get_available_files
#' 
#' @param catalogue_string string
#' @param cube string
#' @param path string
#'
#' @export 
#'
#'
download_data_cube <- function(catalogue_string, cube, path = here::here("data-raw")) {
  
  # check if path is valid
  if (!dir.exists(path)) {
    stop("path does not exist. Please create a folder.")
  }
  
  available_cubes <- readabs::get_available_files(catalogue_string)
  
  file_download_url <- available_cubes %>%
    dplyr::filter(grepl(cube, label, ignore.case = TRUE)) %>%
    dplyr::slice(1) %>% # this gets the first result which is typically the .xlsx file rather than the zip
    dplyr::pull(url)
  
  if (length(file_download_url) == 0) {
    file_download_url <- available_cubes %>%
      dplyr::filter(grepl(cube, file, ignore.case = TRUE)) %>%
      dplyr::slice(1) %>%
      dplyr::pull(url)
  }
  
  
  # Check that there is a match
  
  if (length(file_download_url) == 0) {
    stop(glue("No matching cube. Please check against ABS website."))
  }
  
  
  # ==================download file======================
  
  download_file(file_download_url = file_download_url, path = path)
  
}