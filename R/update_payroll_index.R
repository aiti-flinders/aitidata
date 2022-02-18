update_payroll_index <- function(force_update = FALSE) {
  
  
  abs_test <- readabs::read_payrolls("industry_jobs", path = "data-raw")
  
  
  
  if (max(abs_test$date) > max(aitidata::payroll_index$date) | force_update) {
    
    message("Updating `payroll_index.rda`")
    
    to_snake <- function(x) {
      x <- gsub(" ", "_", x)
      tolower(x)
    }
    
    payroll_jobs <- readxl::read_excel("data-raw/6160055001_DO004.xlsx", sheet = "Payroll jobs index", col_types = "text", skip = 5) %>%
      dplyr::rename_with(.fn = ~ dplyr::case_when(
        .x == "State or Territory" ~ "state",
        .x == "Industry division" ~ "industry",
        .x == "Sub-division" ~ "industry_subdivision",
        .x == "Employment size" ~ "emp_size",
        .x == "Sex" ~ "gender",
        .x == "Age group" ~ "age",
        .x == "Statistical Area 4" ~ "sa4",
        .x == "Statistical Area 3" ~ "sa3",
        TRUE ~ to_snake(.x)
      )) %>%
      tidyr::pivot_longer(
        cols = dplyr::starts_with("4"),
        names_to = "date",
        values_to = "value"
      ) %>%
      dplyr::mutate(value = suppressWarnings(as.numeric(.data$value))) %>%
      dplyr::filter(.data$value != "NA") %>%
      dplyr::mutate(date = as.Date(as.numeric(.data$date), origin = "1899-12-30"),
                    dplyr::across(where(is.character), ~gsub(pattern = ".*\\. ", x =  .x, replacement = "", perl = TRUE)),
                    indicator = "Payroll jobs",
                    state = strayr::clean_state(.data$state, to = "state_name"))
    
    
    
    payroll_wages <- payroll_index <- readxl::read_excel("data-raw/6160055001_DO004.xlsx", sheet = "Total wages index", col_types = "text", skip = 5) %>%
      dplyr::rename_with(.fn = ~ dplyr::case_when(
        .x == "State or Territory" ~ "state",
        .x == "Industry division" ~ "industry",
        .x == "Sub-division" ~ "industry_subdivision",
        .x == "Employment size" ~ "emp_size",
        .x == "Sex" ~ "gender",
        .x == "Age group" ~ "age",
        .x == "Statistical Area 4" ~ "sa4",
        .x == "Statistical Area 3" ~ "sa3",
        TRUE ~ to_snake(.x)
      )) %>%
      tidyr::pivot_longer(
        cols = dplyr::starts_with("4"),
        names_to = "date",
        values_to = "value"
      ) %>%
      dplyr::mutate(value = suppressWarnings(as.numeric(.data$value))) %>%
      dplyr::filter(.data$value != "NA") %>%
      dplyr::mutate(date = as.Date(as.numeric(.data$date), origin = "1899-12-30"),
                    dplyr::across(where(is.character), ~gsub(pattern = ".*\\. ", x =  .x, replacement = "", perl = TRUE)),
                    indicator = "Payroll wages", 
                    state = strayr::clean_state(.data$state, to = "state_name"))
    
    
    
    
    
    payroll_index <- dplyr::bind_rows(payroll_jobs, payroll_wages) %>%
      dplyr::mutate(industry = strayr::clean_anzsic(.data$industry, silent = TRUE),
                    industry = ifelse(is.na(.data$industry), "Total (industry)", .data$industry),
                    age = ifelse(.data$age == "All ages", "Total (age)", .data$age),
                    year = lubridate::year(date),
                    month = lubridate::month(date, abbr = F, label = T))
    
    
    usethis::use_data(payroll_index, overwrite = TRUE, compress = "xz")
    file.remove("data-raw/6160055001_DO004.xlsx")

  } else {
    message("Skipping `payroll_index.rda`: appears to be up-to-date")
    file.remove("data-raw/6160055001_DO004.xlsx")
    
  }
}
