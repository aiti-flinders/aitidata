#' Checks that installed version of daitir has
#' up to date data
#'
#' @return A message describing the up-to-date-ness of the installed package.
#' @export check_data_up_to_date
#'
check_data_up_to_date <- function() {
  up_to_dateness <- build_daitir() %>%
    dplyr::filter(mtime < current_release)
  
  if (nrow(up_to_dateness) == 0) {
    message("All data appears to be up to date! Get to work!")
  } else {
    message("The following data appears to be out of date. Please download the latest version of daitir using:\n\ndevtools::install_github('hamgamb/daitir')")
  }
}

#' Find the release date of the most recent ABS Catalogue
#'
#'
#' @param catalogue string
#'
#' @return date
#' @export abs_current_release
#'
#' @examples
#' abs_current_release("6202.0")
#' @importFrom dplyr "%>%"
abs_current_release <- function(cat_string = NULL, url = NULL) {
  
  if(!is.null(cat_string) & is.null(url)) {
  current_release <- build_daitir() %>%
    dplyr::filter(catalogue_string == cat_string) %>%
    dplyr::pull(current_release) %>%
    unique()
  
  } else if (is.null(cat_string) & !is.null(url)) {
    release_url <- url
    release_page <- xml2::read_html(release_url)
    
    current_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[1]/div[2]') %>%
      rvest::html_text() %>%
      trimws()
    
    current_release <- as.Date(current_release, format = "%d/%m/%Y")
  }
  return(current_release)
}


#' Find the date of the next release of an ABS dataset
#'
#'
#' @param catalogue_string
#'
#' @return date
#' @export abs_next_release
#'
#' @examples
#' abs_next_release("6202.0")
#' @importFrom dplyr "%>%"
abs_next_release <- function(cat_string = NULL, url = NULL) {
  
  if(!is.null(cat_string) & is.null(url)) {
    next_release <- build_daitir() %>%
      dplyr::filter(catalogue_string == cat_string) %>%
      dplyr::pull(next_release) %>%
      unique()
    
  } else if (is.null(cat_string) & !is.null(url)) {
    release_url <- url
    release_page <- xml2::read_html(release_url)
    
    next_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/div/ul/li[1]/span/text()') %>%
      rvest::html_text() %>%
      gsub(x = ., pattern = "([A-Z])\\w+", replacement = "") %>%
      trimws()
    
    next_release <- as.Date(next_release, format = "%d/%m/%Y")
  } else if (!is.null(cat_string) & !is.null(url)) {
    warning("Both URL and catalogue_string were specified. Using URL")
    next_release <- build_daitir() %>%
      dplyr::filter(catalogue_string == cat_string) %>%
      dplyr::pull(next_release) %>%
      unique()
  } else if (is.null(cat_string) & is.null(url)) {
    stop("One of URL and catalogue_string must be specified")
  }
  
  if(length(next_release) == 0) {
    next_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/text()') %>%
      rvest::html_text() %>%
      .[2] %>%
      trimws()
    
    next_release <- as.Date(next_release, format = "%d/%m/%Y")
  } 
  
  if(length(next_release) == 0) {
    next_release <- NA
  } 

  return(next_release)
}
