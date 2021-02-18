#' Download a file from the internet
#' @importFrom httr GET content
#' @param file_download_url url of file to download
#' @param path path to download the file to
#'
#' @return Returns (silently) the path where the file has been downloaded
#' @export download_file
#'
download_file <- function(file_download_url,  path = here::here("data-raw")) {
  download_object <- httr::GET(file_download_url)
  
  filename <- basename(download_object$url)
  
  filepath <- file.path(path, filename)
  
  writeBin(httr::content(download_object, "raw"), filepath)
  
  message("File downloaded in ", filepath)
  
  return(invisible(filepath))
}