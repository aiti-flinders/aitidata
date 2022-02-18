#' Update internet vacancies index
#'
#' @param force_update logical
#'
#' @return logical: TRUE if the data updated successfully 
#' @export
update_internet_vacancies_index <- function(force_update = FALSE) {
  
  if (!force_update) {
    
    utils::download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790179&.xlsx",
                         destfile = here::here("data-raw/ivi_test.xlsx"),
                         mode = "wb")
    
    current_date <- readxl::read_excel(here::here("data-raw/ivi_test.xlsx"),
                                       sheet = "Trend") %>%
      dplyr::select(dplyr::last_col()) 
    
    current_date <- as.Date(as.numeric(colnames(current_date)), origin = "1899-12-30")
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::internet_vacancies_index$date) | force_update) {
    
    message("Updating `internet_vacancies_index` dataset.")
    utils::download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790177&.xlsx",
                         destfile = here::here("data-raw/ivi_basic.xlsx"),
                         mode = "wb")
    
    
    internet_vacancies_index <- readxl::read_excel(here::here("data-raw/ivi_basic.xlsx"),
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
    file.remove(here::here("data-raw/ivi_basic.xlsx"))
  } else {
    message("Skipping update of `internet_vacancies_index`: data is up-to-date")
    file.remove(here::here("data-raw/ivi_test.xslx"))
  }
}


