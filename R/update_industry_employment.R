#' Update Employment by industry data
#'
#' @param force_update logical
#' @return logical
update_industry_employment <- function(force_update = FALSE) {
  
  if (!force_update) {
  
  abs_file <- readabs::read_abs(cat_no = "6291.0.55.001", tables = "23a", retain_files = FALSE)
  current_date <- max(abs_file$date)
  
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::industry_employment$date) | force_update) {
    
    message("updating `industry_employment`")
    
    industry_employment <- readabs::read_abs(cat_no = "6291.0.55.001", tables = "5", retain_files = FALSE) %>%
      tidyr::separate(.data$series, into = c("state", "industry", "indicator"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(c("state", "industry", "indicator"), ~ gsub(pattern = "> ", x = .x, replacement = "")),
                    dplyr::across(where(is.character), ~trimws(.x)),
                    indicator = ifelse(.data$indicator == "", .data$industry, .data$indicator),
                    industry = ifelse(grepl(x = .data$industry, pattern = "Employed"), "Total (industry)", .data$industry),
                    gender = "Persons",
                    age = "Total (age)",
                    year = lubridate::year(date),
                    month = lubridate::month(date, label = TRUE, abbr = FALSE),
                    value = ifelse(.data$unit == "000", .data$value * 1000, .data$value)) %>%
      dplyr::group_by(.data$date, .data$indicator, .data$gender, .data$age, .data$state) %>% 
      dplyr::mutate(value_share = 200 * .data$value / sum(.data$value)) %>%
      dplyr::ungroup() %>%
      dplyr::select(.data$date, .data$year, .data$month, .data$indicator, .data$industry, .data$gender, .data$age, .data$state, .data$series_type, .data$value, .data$unit) 
    
    usethis::use_data(industry_employment, overwrite = TRUE, compress = "xz")
    return(TRUE)
  } else {
    message("Skipping `industry_employment.rda`: appears to be up-to-date")
    return(TRUE)
  
  }
}
