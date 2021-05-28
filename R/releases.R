#' Find the release date of the most recent ABS Catalogue
#' @param cat_string string
#' @param url string
#'
#' @return date
#' @export abs_current_release
#'
#' @examples \dontrun{abs_current_release("6202.0")}
#' @importFrom dplyr "%>%" filter pull
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text
#' @importFrom rlang .data
abs_current_release <- function(cat_string = NULL, url = NULL) {
  
  if (!is.null(cat_string) & is.null(url)) {
    release_url <- aitidata_catalogues %>%
      dplyr::filter(.data$catalogue_string == cat_string) %>%
      dplyr::pull(url) %>%
      unique()
    
  } else if (is.null(cat_string) & !is.null(url)) {
    release_url <- url
  }
  release_page <- xml2::read_html(release_url)
  
  current_release <- release_page %>%
    rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[1]/div[2]') %>%
    rvest::html_text() %>%
    trimws()
  
  current_release <- as.Date(current_release, format = "%d/%m/%Y")
  
  return(current_release)
}


#' Find the date of the next release of an ABS dataset
#'
#'
#' @param cat_string string
#' @param url string
#'
#' @return date
#' @export abs_next_release
#'
#' @examples \dontrun{abs_next_release("6202.0")}
#' @importFrom dplyr "%>%"
#' @importFrom rlang .data
abs_next_release <- function(cat_string = NULL, url = NULL) {
  
  if(!is.null(cat_string) & is.null(url)) {
    release_url <- aitidata_catalogues %>%
      dplyr::filter(.data$catalogue_string == cat_string) %>%
      dplyr::pull(.data$url) %>%
      unique()
    
  } else if (is.null(cat_string) & !is.null(url)) {
    release_url <- url
  } else if (!is.null(cat_string) & !is.null(url)) {
    warning("Both URL and catalogue_string were specified. Using URL")
    release_url <- aitidata_catalogues %>%
      dplyr::filter(.data$catalogue_string == cat_string) %>%
      dplyr::pull(.data$url) %>%
      unique()
  }  else if (is.null(cat_string) & is.null(url)) {
    stop("One of URL and catalogue_string must be specified")
  }
    
  release_page <- xml2::read_html(release_url)
    
    next_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/div/ul/li[1]/span/text()') %>%
      rvest::html_text() 
      
    next_release <- next_release %>%
      gsub(x = next_release, pattern = "([A-Z])\\w+", replacement = "") %>%
      trimws()
    
    next_release <- as.Date(next_release, format = "%d/%m/%Y")
 
  
  if(length(next_release) == 0) {
    next_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/text()') %>%
      rvest::html_text() %>%
      .data[2] %>%
      trimws()
    
    next_release <- as.Date(next_release, format = "%d/%m/%Y")
  } 
  
  if(length(next_release) == 0) {
    next_release <- NA
  } 
  
  return(next_release)
}
