#' Update small area labour market data
#'
#' @param force_update logical 
#'
#' @return logical
update_small_area_labour_market <- function(force_update = FALSE) {
  
  header <- c('Connection' = 'keep-alive', 
              'user-agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
  
  
  if (!force_update) {
    
    
    filename <- xml2::read_html("https://www.jobsandskills.gov.au/work/small-area-labour-markets") %>%
      rvest::html_elements("a.downloadLink.button.brandDark.medium.downloadCloudAfter") %>%
      rvest::html_attr("href") %>%
      .[5]
    
    dl <- GET(url = paste0("https://www.jobsandskills.gov.au/", filename),
              header = httr::add_headers(header),
              httr::write_disk("salm_test.csv", overwrite = TRUE))
  
    
  current_date <- readr::read_csv("salm_test.csv",
                           skip = 1) %>%
    dplyr::select(dplyr::last_col()) 
  
  current_date <- as.Date(paste0(colnames(current_date), "-01"), format = "%b-%y-%d")
  
  } else {
    current_date <- TRUE
  } 
  
  if (current_date > max(aitidata::small_area_labour_market$date) | force_update) {
    
    filename <- xml2::read_html("https://www.jobsandskills.gov.au/work/small-area-labour-markets") %>%
      rvest::html_elements("a.downloadLink.button.brandDark.medium.downloadCloudAfter") %>%
      rvest::html_attr("href") %>%
      .[3]
    
    dl <- GET(url = paste0("https://www.jobsandskills.gov.au/", filename),
              header = httr::add_headers(header),
              httr::write_disk("salm_sa2.csv", overwrite = TRUE))
 
    
    raw <- readr::read_csv("salm_sa2.csv", 
                           skip = 1, 
                           na = "-")
    
    all_sa2 <- data.frame(strayr::read_absmap("sa22016", remove_year_suffix = TRUE)) %>%
      dplyr::select("sa2_name",
                    "sa2_code",
                    "state_name")
    
    
    small_area_labour_market <- raw %>%
      dplyr::mutate(dplyr::across(where(is.numeric), as.character)) %>%
      dplyr::rename(indicator = "Data Item",
                   sa2_name = "Statistical Area Level 2 (SA2)",
                   sa2_code = "SA2 Code") %>%
      tidyr::pivot_longer(cols = -c("indicator",
                                    "sa2_name",
                                    "sa2_code"),
                          names_to = "date",
                          values_to = "value") %>%
      dplyr::mutate(value = as.numeric(gsub(",", "", .data$value)),
                    date = as.Date(paste0(.data$date, "-01"), format = "%b-%y-%d")) %>%
      dplyr::right_join(all_sa2) %>%
      tidyr::complete(.data$indicator, tidyr::nesting(sa2_name, sa2_code), .data$date) %>%
      dplyr::filter(!is.na(.data$date), 
                    !is.na(.data$indicator))
    
    usethis::use_data(small_area_labour_market, overwrite = TRUE, compress = "xz")
    file.remove("salm_sa2.csv")
    
  } else {
    message("Skipping `small_area_labour_market.rda`: appears to be up-to-date")
    file.remove("salm_test.csv")
    
  }
}
