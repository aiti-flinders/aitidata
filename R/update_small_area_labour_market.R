#' Update small area labour market data
#'
#' @param force_update logical 
#'
#' @return logical
update_small_area_labour_market <- function(force_update = FALSE) {
  
  header <- c("user-agent" = "Labour market data access [hamish.gamble@flinders.edu.au]")
  
  
  if (!force_update) {
    
    
    filename <- xml2::read_html("https://www.nationalskillscommission.gov.au/topics/small-area-labour-markets") %>%
      rvest::html_elements("a.downloadLink") %>%
      rvest::html_attr("href") %>%
      .[5]
    
    dl <- GET(url = paste0("https://www.nationalskillscommission.gov.au/", filename),
              header = httr::add_headers(header))
  
    
  writeBin(dl$content,
           con = "data-raw/salm_test.csv")
  
  current_date <- readr::read_csv(here::here("data-raw/salm_test.csv"),
                           skip = 1) %>%
    dplyr::select(dplyr::last_col()) 
  
  current_date <- as.Date(paste0(colnames(current_date), "-01"), format = "%b-%y-%d")
  
  } else {
    current_date <- TRUE
  } 
  
  if (current_date > max(aitidata::small_area_labour_market$date) | force_update) {
    
    filename <- xml2::read_html("https://www.nationalskillscommission.gov.au/topics/small-area-labour-markets") %>%
      rvest::html_elements("a.downloadLink") %>%
      rvest::html_attr("href") %>%
      .[3]
    
    dl <- GET(url = paste0("https://www.nationalskillscommission.gov.au/", filename),
              header = httr::add_headers(header))
    
    writeBin(dl$content,
             con = "data-raw/salm_sa2.csv")
    
    raw <- readr::read_csv(here::here("data-raw/salm_sa2.csv"), 
                           skip = 1, 
                           na = "-")
    
    all_sa2 <- data.frame(strayr::read_absmap("sa22016", remove_year_suffix = TRUE)) %>%
      dplyr::select(.data$sa2_name, .data$sa2_code, .data$state_name)
    
    
    small_area_labour_market <- raw %>%
      dplyr::mutate(dplyr::across(where(is.numeric), as.character)) %>%
      dplyr::rename(indicator = .data$`Data Item`,
                   sa2_name = .data$`Statistical Area Level 2 (SA2) (2016 ASGS)`,
                   sa2_code = .data$`SA2 Code (2016 ASGS)`) %>%
      tidyr::pivot_longer(cols = -c(.data$indicator,
                                    .data$sa2_name,
                                    .data$sa2_code),
                          names_to = "date",
                          values_to = "value") %>%
      dplyr::mutate(value = as.numeric(gsub(",", "", .data$value)),
                    date = as.Date(paste0(.data$date, "-01"), format = "%b-%y-%d")) %>%
      dplyr::right_join(all_sa2) %>%
      tidyr::complete(.data$indicator, tidyr::nesting(sa2_name, sa2_code), .data$date) %>%
      dplyr::filter(!is.na(.data$date), 
                    !is.na(.data$indicator))
    
    usethis::use_data(small_area_labour_market, overwrite = TRUE, compress = "xz")
    file.remove(here::here("data-raw/salm_sa2.csv"))
    
  } else {
    message("Skipping `small_area_labour_market.rda`: appears to be up-to-date")
    file.remove(here::here("data-raw/salm_test.csv"))
    
  }
}
