#' Update Household spending data
#'
#' @param force_update logical
#' @return logical. TRUE if the update was successful

update_household_spending <- function(force_update = FALSE) {
  
  abs_test <- readabs::read_abs(cat_no = "5682.0", tables = "1", retain_files = FALSE)
  
  if (max(abs_test$date) > max(aitidata::household_spending$date) | force_update) {
    
    message("Updating Monthly Household Spending Indicator")
    
    states <- c(
      "New South Wales",
      "Victoria", 
      "Queensland",
      "South Australia",
      "Western Australia",
      "Tasmania",
      "Northern Territory",
      "Australian Capital Territory"
      )
    
    raw <- readabs::read_abs(cat_no = "5682.0", tables = 1:9, retain_files = FALSE) 
    
    household_spending <- raw %>%
      readabs::separate_series(column_names = c("indicator", "coicop_division", "state", "price")) %>%
      dplyr::filter(indicator == "Calendar adjusted household spending - Index") %>%
      dplyr::mutate(value = ifelse(.data$unit == "000", 1000 * .data$value, .data$value),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = TRUE, abbr = FALSE)) %>%
      dplyr::select("date", 
                    "year", 
                    "month",
                    "indicator", 
                    "coicop_division",
                    "state",
                    "series_type",
                    "value",
                    "unit")
    
    usethis::use_data(household_spending, overwrite = TRUE, compress = "xz")
    return(TRUE)
    
  } else {
    
    message("Monthly Household Spending does not need updating.")
  }
  
}
  



