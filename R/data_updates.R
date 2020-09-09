#' Check if an ABS data source is up to date
#'
#' @param cat_no string. include the ".0"
#' @param data_name optional 
#'
#' @return logical
#' @export abs_data_up_to_date
#'

abs_data_up_to_date <- function(cat_no, data_name = NULL) {
  current_release <- abs_current_release(cat_no) 
  next_release <- lubridate::as_datetime(paste(abs_next_release(cat_no), "11:00:00"), tz = "Australia/Adelaide")
  
  if (is.null(data_name)) {
    cat_to_file <- unique(daitir:::abs_cats[daitir:::abs_cats$cat_no == cat_no, ]$data_name)
  } else {
    cat_to_file <- data_name
  }
  
  now <- lubridate::now()
  
  if (length(cat_to_file) > 1) {
    stop(paste0("ABS catalogue number ", cat_no, " returned multiple datasets - specify data"))
  }
  
  file_created <- file.info(paste0("data/", cat_to_file, ".rda"))$ctime
  
  latest <- (current_release <= file_created) & (now < next_release)
  
  return(latest)
}

#' Find the release date of the most recent ABS Catalogue
#'
#' @param cat_no 
#'
#' @return date
#' @export abs_current_release
#'
#' @examples
abs_current_release <- function(cat_no) {
  
  release_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/second+level+view?ReadForm&prodno={cat_no}&&tabname=Past%20Future%20Issues")
  
  release_page <- xml2::read_html(release_url)
  
  release_table <- tibble::tibble(release = release_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_text(),
                                  url_suffix = release_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_attr("href"))
  
  release_date <- release_table %>%
    dplyr::filter(grepl("(Latest)", .data$release)) %>%
    dplyr::pull(.data$release) %>%
    stringr::str_remove(" \\(Latest\\)") %>%
    stringr::str_extract("Week ending \\d+\\s{1}\\w+ \\d+$|(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?).*") %>%
    stringr::str_replace_all(" ", "%20")
  
  download_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/{cat_no}{release_date}?OpenDocument")
  
  cur_release <- xml2::read_html(download_url) %>%
    rvest::html_nodes(xpath = '//*[@id="Release"]') %>%
    rvest::html_text() %>%
    stringr::str_extract("[0-9/]{8,}")
  
  cur_release <- as.Date(cur_release, format = "%d/%m/%y")
  
  
  return(cur_release)
  
}


#' Find the date of the next release of an ABS dataset
#'
#' @param cat_no 
#'
#' @return date
#' @export abs_next_release
#'
#' @examples
abs_next_release <- function(cat_no) {
  
  release_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/second+level+view?ReadForm&prodno={cat_no}&&tabname=Past%20Future%20Issues")
  
  release_page <- xml2::read_html(release_url)
  
  release_date <- release_page %>%
    rvest::html_nodes(xpath = '//*[@id="mainpane"]/div/ul[1]/li') %>%
    rvest::html_text()
  
  next_date <- stringr::str_sub(release_date, start = -10)
  
  next_date <- as.Date(next_date, format = "%d/%m/%Y")
  
  return(next_date)
  
}
