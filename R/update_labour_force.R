#' Update labour force data
#'
#' @param force_update logical
#'
#' @return logical: TRUE if data updated successfully 
#' @export

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
    
    labour_force_status <- raw |> 
      dplyr::filter(.data$table_no == "6202012" | .data$table_no == "6202012a") |> 
      readabs::separate_series(column_names = c("indicator", "sex", "state"), remove_nas = TRUE) 
    
    
    
    hours_worked <- raw  |> 
      dplyr::filter(.data$table_no == "6202019" | .data$table_no == "6202019a") |> 
      tidyr::separate(.data$series, into = c("indicator", "sex", "state"), sep = ";") |> 
      dplyr::mutate(dplyr::across(c("indicator", "sex"), ~ trimws(gsub(">", "", .))),
                    state = ifelse(.data$sex %in%  states, .data$sex, "Australia"),
                    gender = ifelse(.data$sex %in% states, "Persons", .data$sex))
    
    usethis::use_data(hours_worked, overwrite = TRUE, compress = "xz")
    
    
    underutilisation_aus <- raw |> 
      dplyr::filter(.data$table_no == 6202022) |> 
      readabs::separate_series(column_names = c("indicator", "sex", "age"), remove_nas = TRUE)
    
    
    underutilisation_state <- raw |> 
      dplyr::filter(.data$table_no == "6202023" | .data$table_no == "6202023a",
                    grepl("Underemploy|Underutilisation", series)) |> 
      tidyr::separate(col = .data$series, into = c("indicator", "sex", "state"), sep = ";", extra = "drop") |> 
      dplyr::mutate(dplyr::across(c("indicator", "sex", "state"), ~ trimws(gsub(">", "", .))),
                    state = ifelse(.data$state == "", "Australia", .data$state))

    
    labour_force <- dplyr::bind_rows(list(labour_force_status, underutilisation_aus, underutilisation_state)) |> 
      dplyr::distinct() |> 
      dplyr::filter(!is.na(value))  |>  
      tidyr::pivot_wider(names_from = "indicator", values_from = "value")  |> 
      dplyr::mutate("Underutilised total" = .data$`Unemployed total` + .data$`Underemployed total`)
    
    labour_force <- labour_force %>%
      tidyr::pivot_longer(cols = "Employed total":"Underutilised total",
                          names_to = "indicator", 
                          values_to = "value", 
                          values_drop_na = TRUE) |> 
      dplyr::mutate(ifelse(is.na(age), "Total (age)", age))
    
    usethis::use_data(labour_force, overwrite = TRUE, compress = "xz")
    return(TRUE)
  } else {
    message("Skipping `labour_force.rda`: appears to be up-to-date")
    
  }
}
