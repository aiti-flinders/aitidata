#' Update `underemployment_by_industry` dataset.
#' 
#' @param force_update logical
#'
#' @return logical: TRUE if update was successful
#' @export
#'
update_underemployment_by_industry <- function(force_update = FALSE) {
    
  abs_file <- readabs::read_abs(cat_no = "6291.0.55.001",
                                tables = "23a",
                                retain_files = FALSE)
    
    if (max(abs_file$date) > max(aitidata::underemployment_by_industry$date) | force_update) {
      message("Updating `underemployment_by_industry`, `underemployment_by_occupation`")
      
      table_19 <- readabs::read_abs("6291.0.55.001", 
                                    tables = "19",
                                    retain_files = F) %>%
        readabs::separate_series(column_names = c("industry", "indicator", "gender"),
                                 remove_nas = TRUE) %>%
        dplyr::mutate(year = lubridate::year(.data$date),
                      month = lubridate::month(.data$date, label = TRUE, abbr = FALSE),
                      value = ifelse(unit == "000", .data$value * 1000, .data$value),
                      state = "Australia",
                      age = "Total (age)",
                      industry = ifelse(is.na(.data$industry), "Total (industry)", .data$industry)) %>%
        dplyr::filter(indicator != "Employed total")
      
      underemployment_by_industry <- table_19 %>% 
        dplyr::filter(!industry %in% c("Managers",
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
      
      underemployment_by_occupation <- table_19 %>%
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
      
      
      usethis::use_data(underemployment_by_industry, overwrite = TRUE, compress = "xz")
      usethis::use_data(underemployment_by_occupation, overwrite = TRUE,compress = "xz")
      return(TRUE)
    } else {
      message(
        "Skipping `underemployment_by_industry`, `underemployment_by_occupation`: data is up-to-date"
      )
      return(TRUE)
    }
    
  }
