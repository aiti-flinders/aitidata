#' prepare `internet_vacancies_regional` dataset 
#'
#' @param force_update logical
#'
#' @return logical: TRUE if the update succeeded
#' @importFrom utils download.file
update_internet_vacancies_regional <- function(force_update = FALSE) {
  
  header <- c('Connection' = 'keep-alive', 
              'user-agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
  
  if (!force_update) {
    
    filename <- xml2::read_html("https://www.jobsandskills.gov.au/work/internet-vacancy-index") %>%
      rvest::html_elements("a.downloadLink.button.primary") %>% 
      rvest::html_attr("href") %>%
      .[2]
    
    
  
    dl <- httr::GET(
      url = paste0("https://www.jobsandskills.gov.au/", filename),
      header = httr::add_headers(header),
      httr::write_disk("ivi_test.xlsx", overwrite = TRUE)
      )
  

  current_date <- readxl::read_excel("ivi_test.xlsx",
                             sheet = "Trend") %>%
    dplyr::select(dplyr::last_col()) 
  
  current_date <- as.Date(paste0(colnames(current_date),"01"), format = "%b%y%d") 
  
  } else {
    
    current_date <- TRUE
  }
   
  
  if (current_date > max(aitidata::internet_vacancies_regional$date) | force_update) {
    
    message("Updating `internet_vacancies_regional` dataset.")
    
    filename <- xml2::read_html("https://www.jobsandskills.gov.au/work/internet-vacancy-index") %>%
      rvest::html_elements("a.downloadLink.button.primary") %>% 
      rvest::html_attr("href") %>%
      .[3]
    
    dl <- httr::GET(
      url = paste0("https://www.jobsandskills.gov.au/", filename),
      header = httr::add_headers(header),
      httr::write_disk("ivi_regional.xlsx", overwrite = TRUE)
      )
    
    

          
    internet_vacancies_regional <- readxl::read_excel("ivi_regional.xlsx",
                                                      sheet = 2) %>%
      tidyr::pivot_longer(cols = -c("Level",
                                    "State",
                                    "region",
                                    "ANZSCO_CODE",
                                    "ANZSCO_TITLE"),
                          names_to = "date",
                          values_to = "value") %>%
      dplyr::mutate(date = as.Date(x = paste0(.data$date, "01"), format = "%b%y%d"),
                    unit = "000",
                    state = strayr::clean_state(.data$State, to = "state_name"),
                    ANZSCO_TITLE = ifelse(grepl("TOTAL", .data$ANZSCO_TITLE), "TOTAL", .data$ANZSCO_TITLE),
                    region = dplyr::case_when(
                      region == "Blue Mountains, Bathurst & Central West NSW" ~ "Blue Mountains Bathurst & Central West",
                      region == "Central Queensland" ~ "Central QLD",
                      region == "Far North Queensland" ~ "Far North QLD",
                      region == 'Hobart & Southeast Tasmania' ~ "Hobart & Southeast TAS",
                      region == "Launceston and Northeast Tasmania" ~ "Launceston and Northeast TAS",
                      region == "North West Tasmania" ~ "North West TAS",
                      region == "Outback Queensland" ~ "Outback QLD",
                      region == "Regional Northern Territory" ~ "Regional NT",
                      TRUE ~ .data$region
                    )) %>%
      dplyr::select("date",
                    occupation_level = "Level",
                    state = "State",
                    vacancy_region = "region",
                    anzsco_code = "ANZSCO_CODE",
                    anzsco_title = "ANZSCO_TITLE",
                    "value")


    usethis::use_data(internet_vacancies_regional, overwrite = TRUE, compress = 'xz')
    file.remove("ivi_regional.xlsx")
    
  } else {
    message("Skipping `internet_vacancies_regional.rda`: appears to be up-to-date")
    file.remove("ivi_test.xlsx")
    
    
    }
}
