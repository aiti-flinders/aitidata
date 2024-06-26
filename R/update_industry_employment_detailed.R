#' Update detailed employment by industry data
#'
#' @param force_update logical
#'
#' @return logical: TRUE if data updated successfully 
#' @export
#'
update_industry_employment_detailed <- function(force_update = FALSE) {
  
  abs_file <-  readabs::download_abs_data_cube("labour-force-australia-detailed",
                                               cube = "6291023a",
                                               path = here::here("data-raw"))
  
  current_date <- readabs::read_abs_local(path = here::here("data-raw"),
                                          filenames = "6291023a.xlsx") %>%
    dplyr::pull(date) %>%
    max()
  
  if (current_date > max(aitidata::industry_employment_detailed$date) | force_update) {
    message("Updating `industry_employment_detailed.rda`")
    
    abs_file <- aitidata::download_data_cube("labour-force-australia-detailed", 
                                             cube = "EQ06", 
                                             path = "data-raw")
    
    df <- readxl::read_excel(path = abs_file,
                             sheet = "Data 1",
                             skip = 3) %>%
      tidyr::pivot_longer(cols = 5:8, 
                          names_to = "indicator",
                          values_to = "value") %>%
      dplyr::rename(date = "Mid-quarter month",
                    gender = "Sex",
                    state = "State and territory (STT): ASGS (2011)",
                    anzsic_group = "Industry group of main job: ANZSIC (2006) Rev.2.0") %>%
      dplyr::mutate(date = as.Date(.data$date),
                    anzsic_group = stringr::str_sub(.data$anzsic_group, 5)) %>%  
      tidyr::replace_na(list(value = 0))
    
    
    anzsic <- strayr::anzsic2006 %>%
      dplyr::select("anzsic_division",
                    "anzsic_subdivision",
                    "anzsic_group")
    
    industry_employment_detailed <- dplyr::left_join(df, anzsic) %>%
      dplyr::distinct() %>%
      dplyr::group_by(.data$date, .data$indicator, .data$gender, .data$state, .data$anzsic_subdivision, .data$anzsic_division) %>%
      dplyr::summarise(value = sum(.data$value), .groups = "drop") %>%
      dplyr::ungroup() %>%
      dplyr::mutate(value = .data$value * 1000,
                    indicator = stringr::str_replace_all(.data$indicator, "\\('000.+", ""),
                    indicator = trimws(.data$indicator))
    
    usethis::use_data(industry_employment_detailed, compress = "xz", overwrite = TRUE)
    return(TRUE)
  } else {
    message("Skipping `industry_employment_detailed`: appears to be up-to-date")
    return(TRUE)
    }
}


