#' Update labour force data
#'
#' @param force_update logical
#'
#' @return logical: TRUE if data updated successfully 

update_labour_force <- function(force_update = FALSE) {
  
  abs_test <- readabs::read_abs(cat_no = "6202.0", tables = "19a", retain_files = FALSE)
  
  if (max(abs_test$date) > max(aitidata::labour_force$date) | force_update) {
    
    message("Updating `labour-force-australia`")
    
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
    
    
    raw <- readabs::read_abs(cat_no = "6202.0", tables = c("12", "12a", "19", "19a", "22", "23", "23a"), retain_files = FALSE)
    
    labour_force_status <- raw %>%
      dplyr::filter(.data$table_no == "6202012" | .data$table_no == "6202012a") %>%
      readabs::separate_series(column_names = c("indicator", "gender", "state"), remove_nas = TRUE) %>%
      dplyr::mutate(
        value = ifelse(.data$unit == "000", (1000 * .data$value), (.data$value)),
        year = lubridate::year(.data$date),
        month = lubridate::month(.data$date, label = TRUE, abbr = FALSE),
        age = "Total (age)"
      ) %>%
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
    
    
    
    hours_worked <- raw %>%
      dplyr::filter(.data$table_no == "6202019" | .data$table_no == "6202019a") %>%
      tidyr::separate(.data$series, into = c("indicator", "gender", "state"), sep = ";") %>%
      dplyr::mutate(dplyr::across(c(.data$indicator, .data$gender), ~ trimws(gsub(">", "", .))),
                    state = ifelse(.data$gender %in%  states, .data$gender, "Australia"),
                    gender = ifelse(.data$gender %in% states, "Persons", .data$gender),
                    unit = "000",
                    value = ifelse(.data$unit == "000", 1000 * .data$value, .data$value),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = TRUE, abbr = FALSE),
                    age = "Total (age)"
      ) %>%
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
    
    usethis::use_data(hours_worked, overwrite = TRUE, compress = "xz")
    
    
    underutilisation_aus <- raw %>%
      dplyr::filter(.data$table_no == 6202022) %>%
      tidyr::separate(col = .data$series, into = c("indicator", "gender", "age"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(c(.data$indicator, .data$gender, .data$age), ~ trimws(gsub(">", "", .))),
                    age = ifelse(.data$age == "", "Total (age)", .data$age),
                    value = ifelse(.data$unit == "000", (1000 * .data$value), .data$value),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = T, abbr = F),
                    state = "Australia") %>%
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
    
    
    underutilisation_state <- raw %>%
      dplyr::filter(.data$table_no == "6202023" | .data$table_no == "6202023a") %>%
      tidyr::separate(col = .data$series, into = c("indicator", "gender", "state"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(c(.data$indicator, .data$gender, .data$state), ~ trimws(gsub(">", "", .))),
                    state = ifelse(.data$state == "", "Australia", .data$state),
                    value = ifelse(.data$unit == "000", (1000 * .data$value), .data$value),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, label = T, abbr = F),
                    age = "Total (age)") %>%
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
    
    labour_force <- dplyr::bind_rows(list(labour_force_status, underutilisation_aus, underutilisation_state)) %>%
      dplyr::distinct() %>%
      dplyr::filter(!is.na(.data$value)) %>% 
      tidyr::pivot_wider(names_from = .data$indicator, values_from = .data$value) %>%
      dplyr::mutate("Underutilised total" = .data$`Unemployed total` + .data$`Underemployed total`)
    
    labour_force <- labour_force %>%
      tidyr::pivot_longer(cols = .data$`Employed total`:.data$`Underutilised total`,
                          names_to = "indicator", 
                          values_to = "value", 
                          values_drop_na = TRUE)
    
    usethis::use_data(labour_force, overwrite = TRUE, compress = "xz")
    return(TRUE)
  } else {
    message("Skipping `labour_force.rda`: appears to be up-to-date")
    
  }
}
