#' Update Employment by industry data
#'
#' @param force_update logical
#' @return logical
update_industry_employment <- function(force_update = FALSE) {
  
  if (!force_update) {
  
  readabs::download_abs_data_cube("labour-force-australia-detailed",
                                               cube = "6291023a.xlsx",
                                               path = here::here("data-raw"))
  
  current_date <- readabs::read_abs_local(path = here::here("data-raw"),
                                          filenames = "6291023a.xlsx") %>%
    dplyr::pull(date) %>%
    max()
  
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::industry_employment$date) | force_update) {
    
    message("updating `industry_employment`")
    
    readabs::download_abs_data_cube("labour-force-australia-detailed",
                                                           cube = "6291005.xlsx",
                                                           path = here::here("data-raw"))
    
    industry_employment <- readabs::read_abs_local(path = here::here("data-raw"),
                                                   filenames = "6291005.xlsx") %>%
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
      dplyr::select("date", "year", "month", "indicator", "industry", "gender", "age", "state", "series_type", "value", "unit") 
    
    usethis::use_data(industry_employment, overwrite = TRUE, compress = "xz")
    return(TRUE)
    } else {
    message("Skipping `industry_employment.rda`: appears to be up-to-date")
    return(TRUE)
  
  }
}
