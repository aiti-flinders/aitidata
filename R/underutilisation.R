## code to prepare `underutilisation` dataset goes here
update_underutilisation <- function() {
  abs_test <- aitidata::download_data_cube("labour-force-australia-detailed", cube = "6291023a.xlsx", path = "data-raw") 
  
  abs_file <- readabs::read_abs_local(filenames = "6291023a.xlsx", path = "data-raw")
  
  if (max(abs_file$date) <= max(aitidata::underutilisation$date)) {
    message("Skipping `underutilisation.rda`: appears to be up-to-date")
    file.remove(abs_test)
  } else {
    message("Updating `underutilisation.rda`")
    
    abs_cube <- aitidata::download_data_cube("labour-force-australia-detailed", cube = "6291023b.xlsx", path = "data-raw")
    
    raw <- read_abs_local(filenames = c("6291023a.xlsx", "6291023b.xlsx"), path = "data-raw")
    
    underutilisation_23a <- raw %>%
      dplyr::filter(table_no == "6291023a") %>%
      tidyr::separate(series, into = c("state", "indicator", "gender"), sep = ";") %>%
      dplyr::mutate(dplyr::across(c("state", "indicator", "gender"), ~ trimws(gsub(pattern = ">", x = .x, replacement = ""))),
                    age = "Total (age)",
                    value = ifelse(unit == "000", (1000 * value), value),
                    year = lubridate::year(date),
                    month = lubridate::month(date, label = T, abbr = F)) %>%
      dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
    
    underutilisation_23b <- raw %>%
      dplyr::filter(table_no == "6291023b") %>%
      tidyr::separate(series, into = c("age", "indicator", "gender"), sep = ";", fill = "left") %>%
      dplyr::mutate(across(c("age", "indicator", "gender"), ~trimws(gsub(pattern = ">", x = .x, replacement = ""))),
                    gender = ifelse(gender == "", indicator, gender),
                    indicator = ifelse(indicator %in% c("Persons", "Males", "Females"), age, indicator),
                    age = ifelse(age == indicator, "Total (age)", age),
                    state = "Australia",
                    year = lubridate::year(date),
                    month = lubridate::month(date, label = TRUE, abbr = FALSE)) %>%
      dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
    
    
    underutilisation <- dplyr::bind_rows(underutilisation_23a, underutilisation_23b) %>%
      dplyr::distinct()
    
    file.remove(abs_test)
    file.remove(abs_cube)
    
    usethis::use_data(underutilisation, overwrite = TRUE, compress = "xz")
    return(TRUE)
  }
}
