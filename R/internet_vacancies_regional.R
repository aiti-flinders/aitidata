#' prepare `internet_vacancies_regional` dataset 
#'
#' @param force_update logical
#'
#' @return logical: TRUE if the update succeeded
#' @importFrom utils download.file
update_internet_vacancies_regional <- function(force_update = FALSE) {
  
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
   
  
  if (current_date > max(aitidata::internet_vacancies_regional$date) | force_update) {
    
    message("Updating `internet_vacancies_regional` dataset.")
    
    utils::download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790180&.xlsx",
                  destfile = here::here("data-raw/ivi_regional.xlsx"),
                  mode = "wb")
    
    internet_vacancies_regional <- readxl::read_excel(here::here("data-raw/ivi_regional.xlsx"),
                                                      sheet = "Averaged") %>%
      tidyr::pivot_longer(cols = -c(.data$Level,
                                    .data$State,
                                    .data$region,
                                    .data$ANZSCO_CODE,
                                    .data$ANZSCO_TITLE),
                          names_to = "date",
                          values_to = "value") %>%
      dplyr::mutate(date = as.Date(x = as.numeric(.data$date), origin = "1899-12-30"),
                    unit = "000",
                    state = strayr::clean_state(State, to = "state_name"),
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
      dplyr::select(.data$date,
                    occupation_level = .data$Level,
                    state = .data$State,
                    vacancy_region = .data$region, 
                    anzsco_code = .data$ANZSCO_CODE,
                    anzsco_title = .data$ANZSCO_TITLE,
                    .data$value)
    
    
    usethis::use_data(internet_vacancies_regional, overwrite = TRUE, compress = 'xz')
    file.remove(here::here("data-raw/ivi_regional.xlsx"))
    
  } else {
    message("Skipping `internet_vacancies_regional.rda`: appears to be up-to-date")
    file.remove(here::here("data-raw/ivi_test.xlsx"))
    
    
    }
}
