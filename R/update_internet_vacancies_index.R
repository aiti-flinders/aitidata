#' Update internet vacancies index
#'
#' @param force_update logical
#'
#' @return logical: TRUE if the data updated successfully 
#' @export
update_internet_vacancies_index <- function(force_update = FALSE) {
  
  header <- c("user-agent" = "Labour market data access [hamish.gamble@flinders.edu.au]")
  
  
  if (!force_update) {
    
    dl <- GET(
      url = "https://labourmarketinsights.gov.au/media/lftjcpze/ivi_data_skilllevel-january-2006-onwards.xlsx",
      header = httr::add_headers(header),
      httr::write_disk("ivi_test.xlsx")
      )
    
    
    current_date <- readxl::read_excel("ivi_test.xlsx",
                                       sheet = "Trend") %>%
      dplyr::select(dplyr::last_col()) 
    
    current_date <- as.Date(as.numeric(colnames(current_date)), origin = "1899-12-30")
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::internet_vacancies_index$date) | force_update) {
    
    message("Updating `internet_vacancies_index` dataset.")
    
    dl <- GET(
      url = "https://labourmarketinsights.gov.au/media/0pud50bo/ivi_data-january-2006-onwards.xlsx",
      header = httr::add_headers(header),
      httr::write_disk("ivi_basic.xlsx")
    )
    

    
    internet_vacancies_index <- readxl::read_excel("ivi_basic.xlsx",
                                                   sheet = "Trend") %>%
      tidyr::pivot_longer(cols = -c(.data$Level,
                                    .data$State, 
                                    .data$ANZSCO_CODE,
                                    .data$Title),
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
      dplyr::select(.data$date,
                    .data$state,
                    occupation_level = .data$Level,
                    anzsco_code = .data$ANZSCO_CODE,
                    anzsco_title = .data$Title,
                    .data$value) 
    
    
    
    usethis::use_data(internet_vacancies_index, overwrite = TRUE, compress = "xz")
    file.remove("ivi_basic.xlsx")
  } else {
    message("Skipping update of `internet_vacancies_index`: data is up-to-date")
    file.remove("ivi_test.xlsx")
  }
}


