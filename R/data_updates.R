#' Check if an ABS data source is up to date
#'
#' @param cat_no string. include the ".0"
#' @param data_name optional
#'
#' @return logical
#' @export abs_data_up_to_date
#'
#'
#'

abs_data_up_to_date <- function(cat_no, data_name = NULL) {
  current_release <- abs_current_release(cat_no)
  next_release <- lubridate::as_datetime(paste(abs_next_release(cat_no), "11:00:00"), tz = "Australia/Adelaide")

  if (is.null(data_name)) {
    cat_to_file <- unique(abs_cats[abs_cats$cat_no == cat_no, ]$data_name)
  } else {
    cat_to_file <- data_name
  }

  now <- lubridate::now()

  if (length(cat_to_file) > 1) {
    stop(paste0("ABS catalogue number ", cat_no, " returned multiple datasets - specify data"))
  }

  if (!file.exists(paste0("data/", cat_to_file, ".rda"))) {
    latest <- FALSE
  } else {
    file_created <- file.info(paste0("data/", cat_to_file, ".rda"))$mtime
    latest <- (current_release <= file_created) & (now < next_release)
  }

  return(latest)
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
abs_current_release <- function(catalogue_string = NULL, url = NULL) {
  
  if(!is.null(catalogue_string) & is.null(url)) {
  release_url <- abs_cats %>%
    dplyr::filter(catalogue == catalogue_string) %>%
    dplyr::pull(url)
  
  } else if (is.null(catalogue_string) & !is.null(url)) {
    release_url <- url
  }

  release_page <- xml2::read_html(release_url)

  cur_release <- release_page %>%
    rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[1]/div[2]') %>%
    rvest::html_text() %>%
    trimws()

  cur_release <- as.Date(cur_release, format = "%d/%m/%y")


  return(cur_release)
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
abs_next_release <- function(catalogue_string = NULL, url = NULL) {
  
  if(!is.null(catalogue_string) & is.null(url)) {
    release_url <- abs_lookup_table %>%
      dplyr::filter(catalogue == catalogue_string) %>%
      dplyr::pull(url)
    
  } else if (is.null(catalogue_string) & !is.null(url)) {
    release_url <- url
  }
  
  release_page <- xml2::read_html(release_url)
  
  next_release <- release_page %>%
    rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/div/ul/li[1]/span/text()') %>%
    rvest::html_text() %>%
    gsub(x = ., pattern = "([A-Z])\\w+", replacement = "") %>%
    trimws()
  
  next_release <- as.Date(next_release, format = "%d/%m/%y")
  
  if(length(next_release) == 0) {
    next_release <- release_page %>%
      rvest::html_nodes(xpath = '//*[@id="release-date-section"]/div[2]/div/text()') %>%
      rvest::html_text() %>%
      .[2] %>%
      trimws()
    
    next_release <- as.Date(next_release, format = "%d/%m/%y")
  } 
  
  if(length(next_release) == 0) {
    next_release <- NA
  } 

  return(next_release)
}
