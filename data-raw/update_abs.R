## code to prepare `update_abs` dataset goes here
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

abs_cats <- tibble::tribble(
  ~cat_no, ~title, ~tables,  ~data_name, 
  "6202.0", "Labour Force, Australia", list("12" = "Labour force status by Sex, State and Territory", 
                                            "19" = "Monthly hours worked in all jobs (Extrapolated): by Employed full-time, part-time and Sex and by State and Territory",
                                            "22" = "Underutilised persons by Age and Sex",
                                            "23" = "Underutilised persons by State and Territory and Sex"), "labour_force",
  "5206.0", "Australian National Accounts: National Income, Expenditure and Product", list("1" = "Key National Accounts Aggregates",
                                                                                           "6" = "Gross Value Added by Industry"), "national_accounts",
  "6160.0.55.001", "Weekly Payroll Jobs and Wages in Australia", list("4" = "Payroll Jobs and Wages Indexes"), "payroll_index",
  "6160.0.55.001", "Weekly Payroll Jobs and Wages in Australia", list("5" = "Statistical Area 4 and Industry subdivision"), "payroll_sa4",
  "6291.0.55.003", "Labour Force, Australia, Detailed", list("5" = "Employed persons by State, Territory and Industry division of main job (ANZSIC)",
                                                             "19" = "Underemployed persons by Industry division (ANZSIC), Occupation major group (ANZSCO) of main job and Sex"), "employment_by_industry",
  "6291.0.55.003", "Labour Force, Australia, Detailed", list("23a" = "Volume measures of underutilisation by State, Territory and Sex",
                                                             "23b" = "Volume measures of underutilisation by Age and Sex"), "underutilisation",
  "6150.0.55.003", "Labour Account Australia", list("1" = "Total All Industries"), "labour_account",
  "8165.0", "Counts of Australian Businesses, including Entries and Exits", list("8" = "Businesses by Industry Division by Statistical Area Level 2 by Employment Size Ranges"), "cabee_sa2")

abs_cats <- tidyr::unnest_longer(abs_cats, col = tables)

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
  
  file_created <- file.info(paste0("data/", cat_to_file, ".rda"))$ctime
  
  latest <- (current_release <= file_created) & (now < next_release)
  
  return(latest)
}



source(here::here("data-raw", "labour_force.R"))
source(here::here("data-raw", "labour_account.R"))

