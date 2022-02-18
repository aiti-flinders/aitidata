## code to prepare `underutilisation` dataset goes here
update_underutilisation <- function(force_update = FALSE) {
  abs_test <- aitidata::download_data_cube("labour-force-australia-detailed", cube = "6291023a.xlsx", path = "data-raw") 
  
  abs_file <- readabs::read_abs_local(filenames = "6291023a.xlsx", path = "data-raw")
  
  if (max(abs_file$date) > max(aitidata::underutilisation$date) | force_update) {
    message("Updating `underutilisation.rda`")
    
    abs_cube <- aitidata::download_data_cube("labour-force-australia-detailed", cube = "6291023b.xlsx", path = "data-raw")
    
    raw <- readabs::read_abs_local(filenames = c("6291023a.xlsx", "6291023b.xlsx"), path = "data-raw")
    
    underutilisation_23a <- raw %>%
      dplyr::filter(.data$table_no == "6291023a") %>%
      tidyr::separate(.data$series, into = c("state", "indicator", "gender"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(c("state", "indicator", "gender"), ~ trimws(gsub(pattern = ">", x = .x, replacement = ""))),
                    age = "Total (age)",
                    value = ifelse(.data$unit == "000", (1000 * .data$value), .data$value),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = T, abbr = F)) %>%
      dplyr::select(.data$date, 
                    .data$year, 
                    .data$month, 
                    .data$indicator, 
                    .data$gender, 
                    .data$age, 
                    .data$state, 
                    .data$series_type, 
                    .data$value, 
                    .data$unit)
    
    underutilisation_23b <- raw %>%
      dplyr::filter(.data$table_no == "6291023b") %>%
      tidyr::separate(.data$series, into = c("age", "indicator", "gender"), sep = ";", fill = "left", extra = "drop") %>%
      dplyr::mutate(dplyr::across(c("age", "indicator", "gender"), ~trimws(gsub(pattern = ">", x = .x, replacement = ""))),
                    gender = ifelse(.data$gender == "", .data$indicator, .data$gender),
                    indicator = ifelse(.data$indicator %in% c("Persons", "Males", "Females"), .data$age, .data$indicator),
                    age = ifelse(.data$age == .data$indicator, "Total (age)", .data$age),
                    state = "Australia",
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = TRUE, abbr = FALSE)) %>%
      dplyr::select(.data$date,
                    .data$year, 
                    .data$month, 
                    .data$indicator, 
                    .data$gender, 
                    .data$age, 
                    .data$state, 
                    .data$series_type, 
                    .data$value, 
                    .data$unit)
    
    
    underutilisation <- dplyr::bind_rows(underutilisation_23a, underutilisation_23b) %>%
      dplyr::distinct()
    

    usethis::use_data(underutilisation, overwrite = TRUE, compress = "xz")
    any(file.remove(abs_test, abs_cube))
    
  } else {
    message("Skipping `underutilisation.rda`: appears to be up-to-date")
    file.remove(abs_test)
  }
}
