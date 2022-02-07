update_labour_force <- function() {

abs_test <- readabs::read_abs(cat_no = "6202.0", tables = "19a", retain_files = FALSE)

if (max(abs_test$date) <= max(aitidata::labour_force$date)) {
  message("Skipping `labour_force.rda`: appears to be up-to-date")
  return(TRUE)
  } else {
  
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
  
  
  raw <- readabs::read_abs(cat_no = "6202.0", tables = c("12", "12a", "19", "19a", "22", "23", "23a"))
  
  labour_force_12 <- raw %>%
    dplyr::filter(table_no == "6202012" | table_no == "6202012a") %>%
    readabs::separate_series(column_names = c("indicator", "gender", "state")) %>%
    dplyr::mutate(
      value = ifelse(unit == "000", (1000 * value), (value)),
      year = lubridate::year(date),
      month = lubridate::month(date, label = TRUE, abbr = FALSE),
      age = "Total (age)"
    ) %>%
    dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_19 <- raw %>%
    dplyr::filter(table_no == "6202019" | table_no == "6202019a") %>%
    dplyr::separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
    dplyr::mutate(dplyr::across(c(indicator, gender), ~ trimws(gsub(">", "", .))),
           state = ifelse(gender %in% states, gender, "Australia"),
           gender = ifelse(gender %in% states, "Persons", gender),
           unit = "000",
           value = ifelse(unit == "000", 1000 * value, value),
           year = lubridate::year(date),
           month = lubridate::month(date, label = TRUE, abbr = FALSE),
           age = "Total (age)"
    ) %>%
    dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_22 <- raw %>%
    dplyr::filter(table_no == 6202022) %>%
    dplyr::separate(series, into = c("indicator", "gender", "age"), sep = ";") %>%
    dplyr::mutate(dplyr::across(c(indicator, gender, age), ~ trimws(gsub(">", "", .))),
           age = ifelse(age == "", "Total (age)", age),
           value = ifelse(unit == "000", (1000 * value), value),
           year = lubridate::year(date),
           month = lubridate::month(date, label = T, abbr = F),
           state = "Australia"
    ) %>%
    dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_23 <- raw %>%
    dplyr::filter(table_no == "6202023" | table_no == "6202023a") %>%
    dplyr::separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
    dplyr::mutate(dplyr::across(c(indicator, gender, state), ~ trimws(gsub(">", "", .))),
           state = ifelse(state == "", "Australia", state),
           value = ifelse(unit == "000", (1000 * value), value),
           year = lubridate::year(date),
           month = lubridate::month(date, label = T, abbr = F),
           age = "Total (age)"
    ) %>%
    dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  labour_force <- dplyr::bind_rows(list(labour_force_12, labour_force_19, labour_force_22, labour_force_23)) %>%
    dplyr::distinct() %>%
    tidyr::pivot_wider(names_from = indicator, values_from = value) %>%
    dplyr::mutate("Underutilised total" = `Unemployed total` + `Underemployed total`) %>%
    tidyr::pivot_longer(cols = c(9:length(.)), names_to = "indicator", values_to = "value", values_drop_na = TRUE)
  
    usethis::use_data(labour_force, overwrite = TRUE, compress = "xz")
    return(TRUE)
    }
}
