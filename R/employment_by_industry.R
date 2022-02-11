#' Update Employment by industry data
#'
#' @param force_update logical
#' @return logical
update_employment_by_industry <- function(force_update = FALSE) {
  
  abs_test <- aitidata::download_data_cube("labour-force-australia-detailed", "6291023a.xlsx", path = here::here("data-raw") )
  
  abs_file <- readabs::read_abs_local(filenames = "6291023a.xlsx", path = here::here("data-raw"))
  
  if (max(abs_file$date) > max(aitidata::employment_by_industry$date) | force_update) {
    
    message("updating `employment_by_industry`")
    
    raw <- aitidata::download_data_cube("labour-force-australia-detailed", "6291005.xlsx", path = "data-raw")
    
    employment_by_industry <- readabs::read_abs_local(filenames = raw, path = "data-raw") %>%
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
    
    usethis::use_data(employment_by_industry, overwrite = TRUE, compress = "xz")
    file.remove(raw)
    
  } else {
    message("Skipping `employment_by_industry.rda`: appears to be up-to-date")
    file.remove(abs_test)
  
  }
}
