#' Update internet vacancies index
#'
#' @param force_update logical
#'
#' @return logical: TRUE if the data updated successfully 
#' @export
update_internet_vacancies_index <- function(force_update = FALSE) {
  
  header <- c('Connection' = 'keep-alive', 
              'user-agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
  
  
  if (!force_update) {
    
    dl <- GET(
      url = "https://labourmarketinsights.gov.au/media/lftjcpze/ivi_data_skilllevel-january-2006-onwards.xlsx",
      header = httr::add_headers(header),
      httr::write_disk("ivi_test.xlsx", overwrite = TRUE)
      )
    
    
    current_date <- readxl::read_excel("ivi_test.xlsx",
                                       sheet = "Trend") %>%
      dplyr::select(dplyr::last_col()) 
    
    current_date <- as.Date(paste0(colnames(current_date), "01"), format = "%b%y%d")
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::internet_vacancies_index$date) | force_update) {
    
    message("Updating `internet_vacancies_index` dataset.")
    
    dl <- GET(
      url = "https://labourmarketinsights.gov.au/media/0pud50bo/ivi_data-january-2006-onwards.xlsx",
      header = httr::add_headers(header),
      httr::write_disk("ivi_basic.xlsx", overwrite = TRUE)
    )
    

    
    internet_vacancies_index <- readxl::read_excel("ivi_basic.xlsx",
                                                   sheet = "Trend") %>%
      tidyr::pivot_longer(cols = -c("Level",
                                    "State", 
                                    "ANZSCO_CODE",
                                    "Title"),
                          names_to = "date", 
                          values_to = "value") %>%
      dplyr::mutate(date = as.Date(x = as.numeric(.data$date), origin = "1899-12-30"),
                    unit = "000",
                    state = strayr::clean_state(.data$State, to = "state_name"),
                    Title = ifelse(grepl("TOTAL", .data$Title), "TOTAL", .data$Title)) %>%
      dplyr::group_by(.data$state, 
                      .data$date, 
                      .data$ANZSCO_CODE, 
                      .data$Title,
                      .data$Level) %>%
      dplyr::summarise(value = mean(.data$value), .groups = "drop") %>%
      dplyr::ungroup() %>% 
      dplyr::select("date",
                    "state",
                    occupation_level = "Level",
                    anzsco_code = "ANZSCO_CODE",
                    anzsco_title = "Title",
                    "value") 
    
    
    
    usethis::use_data(internet_vacancies_index, overwrite = TRUE, compress = "xz")
    file.remove("ivi_basic.xlsx")
  } else {
    message("Skipping update of `internet_vacancies_index`: data is up-to-date")
    file.remove("ivi_test.xlsx")
  }
}


