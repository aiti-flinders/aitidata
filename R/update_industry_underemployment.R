#' Update `underemployment_by_industry` dataset.
#' 
#' @param force_update logical
#'
#' @return logical: TRUE if update was successful
#' @export
#'
update_industry_underemployment <- function(force_update = FALSE) {
    
  readabs::download_abs_data_cube("labour-force-australia-detailed",
                                               cube = "6291023a",
                                               path = here::here("data-raw"))
  
  abs_file <- readabs::read_abs_local(path = here::here("data-raw"),
                                      filenames = "6291023a.xlsx") 
    
    if (max(abs_file$date) > max(aitidata::industry_underemployment$date) | force_update) {
      message("Updating `industry_underemployment`, `occupation_underemployment`")
      
      table_19 <- readabs::download_abs_data_cube("labour-force-australia-detailed",
                                                  cube = "6291019.xlsx",
                                                  path = here::here("data-raw"))
      table_19 <- readabs::read_abs_local(path = here::here("data-raw"),
                                          filenames = "6291019.xlsx") %>%
        readabs::separate_series(column_names = c("industry", "indicator", "gender"),
                                 remove_nas = TRUE) %>%
        dplyr::mutate(year = lubridate::year(.data$date),
                      month = lubridate::month(.data$date, label = TRUE, abbr = FALSE),
                      value = ifelse(.data$unit == "000", .data$value * 1000, .data$value),
                      state = "Australia",
                      age = "Total (age)",
                      industry = ifelse(is.na(.data$industry), "Total (industry)", .data$industry)) %>%
        dplyr::filter(.data$indicator != "Employed total")
      
      industry_underemployment <- table_19 %>% 
        dplyr::filter(!.data$industry %in% c("Managers",
                                       "Professionals",
                                       "Technicians and Trades Workers",
                                       "Community and Personal Service Workers",
                                       "Clerical and Administrative Workers",
                                       "Sales Workers",
                                       "Machinery Operators and Drivers",
                                       "Labourers")) %>%
        dplyr::select(.data$date,
                      .data$year,
                      .data$month,
                      .data$indicator,
                      .data$industry,
                      .data$gender,
                      .data$age,
                      .data$state,
                      .data$series_type,
                      .data$value,
                      .data$unit)
      
      occupation_underemployment <- table_19 %>%
        dplyr::filter(industry %in% c("Managers",
                                      "Professionals",
                                      "Technicians and Trades Workers",
                                      "Community and Personal Service Workers",
                                      "Clerical and Administrative Workers",
                                      "Sales Workers",
                                      "Machinery Operators and Drivers",
                                      "Labourers")) %>%
        dplyr::select(.data$date,
                      .data$year,
                      .data$month,
                      occupation = .data$indicator,
                      .data$industry,
                      .data$gender,
                      .data$age,
                      .data$state,
                      .data$series_type,
                      .data$value,
                      .data$unit)
      
      
      usethis::use_data(industry_underemployment, overwrite = TRUE, compress = "xz")
      usethis::use_data(occupation_underemployment, overwrite = TRUE,compress = "xz")
      return(TRUE)
    } else {
      message(
        "Skipping `industry_underemployment`, `occupation_underemployment`: data is up-to-date"
      )
      return(TRUE)
    }
    
  }
