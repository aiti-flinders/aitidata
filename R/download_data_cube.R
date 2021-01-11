#' The filepath is returned invisibly which enables piping to \code{unzip()} or \code{readxl::read_excel}.
#'
#' @importFrom dplyr %>%
#' @importFrom glue glue
#' @importFrom dplyr filter pull slice
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom httr GET
#'
#' @export
#'
#'
download_data_cube <- function(catalogue_string,
                                   cube,
                                   path = here::here("data-raw")) {
  
  # check if path is valid
  if (!dir.exists(path)) {
    stop("path does not exist. Please create a folder.")
  }
  
  available_cubes <- readabs::get_available_files(catalogue_string)
  
  file_download_url <- available_cubes %>%
    dplyr::filter(grepl(cube, label, ignore.case = TRUE)) %>%
    dplyr::slice(1) %>% # this gets the first result which is typically the .xlsx file rather than the zip
    dplyr::pull(url)
  
  
  # Check that there is a match
  
  if (length(file_download_url) == 0) {
    stop(glue("No matching cube. Please check against ABS website."))
  }
  
  
  # ==================download file======================
  download_object <- httr::GET(file_download_url)
  
  # save file path to disk
  
  filename <- basename(download_object$url)
  
  filepath <- file.path(path, filename)
  
  writeBin(httr::content(download_object, "raw"), filepath)
  
  message("File downloaded in ", filepath)
  
  return(invisible(filepath))
}