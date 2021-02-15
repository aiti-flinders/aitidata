#' Download a file from the internet
#' @importFrom httr GET content
#' @param download_url 
#' @param path 
#'
#' @return Returns the path where the file has been downloaded
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