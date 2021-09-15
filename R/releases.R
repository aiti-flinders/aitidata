#' Find the release date of a dataset from the ABS.
#' @param cat_string string
#' @param url string
#'
#' @examples \dontrun{current_release(cat_string = "labour-force-australia")}
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


#' Current release date from data.gov
#' 
#' @param url string
#'
#' @return Date
#' @importFrom rlang .data
gov_current_release <- function(url = url) {
  
  release_table <- xml2::read_html(url) %>%
    rvest::html_table() %>%
    .[[1]] 
  
  current_release <- release_table %>%
    dplyr::filter(Field == "Date Updated") %>%
    dplyr::pull(Value) 
  
  as.Date(current_release, format = "%Y-%m-%d")
  
}


#' Find the date of the next release of an ABS dataset
#'
#'
#' @param cat_string string
#' @param url string
#'
#' @return date

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

#' a URL, or catalogue number from the ABS. 
#' Can also look up release dates of data on data.gov.au via the `source` parameter.
#'
#' @param cat_string string (optional)
#' @param url string (optional)
#' @param source string 
#'
#' @return a date
#' @export
#'
#' @examples \dontrun{current_release(cat_string = "labour-force-australia")}
current_release <- function(cat_string = NULL, url = NULL, source = "abs") {
  
  match.arg(source, choices = c("abs", "data.gov"))
  
  if (source == "abs") {
    
    abs_current_release(cat_string = cat_string, url = url)
    
  } else if (source == "data.gov") {
    
    gov_current_release(url = url)
  }
  
  
}
