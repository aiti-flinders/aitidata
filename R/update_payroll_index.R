update_payroll_index <- function(force_update = FALSE) {
  
  
  abs_test <- readabs::read_payrolls("industry_jobs", path = "data-raw")
  
  
  
  if (max(abs_test$date) > max(aitidata::payroll_index$date) | force_update) {
    
    message("Updating `payroll_index.rda`")
    
    to_snake <- function(x) {
      x <- gsub(" ", "_", x)
      tolower(x)
    }
    
    payroll_jobs <- readxl::read_excel("data-raw/6160055001_DO004.xlsx", sheet = "Table 4", col_types = "text", skip = 5) %>%
      dplyr::rename_with(.fn = ~ dplyr::case_when(
        .x == "State or Territory" ~ "state",
        .x == "Characteristic" ~ "characteristic",
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
                    dplyr::across(c(state), ~gsub(pattern = ".*\\. ", x =  .x, replacement = "", perl = TRUE)),
                    indicator = "Payroll jobs",
                    state = strayr::clean_state(.data$state, to = "state_name"))
    
    payroll_jobs |> mutate(t = case_when(
      str_detect(characteristic, "All") ~ "all",
      str_detect(characteristic, "(\\d+\\. [A-S])") ~ "industry",
      str_detect(characteristic, "[2][1-7]\\. \\d") ~ "age",
      str_detect(characteristic, "employees") ~ "emp_size",
      str_detect(characteristic, "[0-9][0-9]\\. [A-Z][^-]") ~ "industry_subdivision")) |> 
      mutate(industry = case_when(
        str_detect(t, "industry") ~ characteristic,
        TRUE ~ "Total (industry)"),
        gender = "Persons",
        age = case_when(
          str_detect(t, "age") ~ characteristic,
          TRUE ~ "Total (age)"
        ),
        business_size = case_when(
          str_detect(t, "emp_size") ~ characteristic,
          TRUE ~ "Total (business size)"
        )) |> 
      distinct()
    
    
    
    # payroll_wages <- payroll_index <- readxl::read_excel("data-raw/6160055001_DO004.xlsx", sheet = "Total wages index", col_types = "text", skip = 5) %>%
    #   dplyr::rename_with(.fn = ~ dplyr::case_when(
    #     .x == "State or Territory" ~ "state",
    #     .x == "Industry division" ~ "industry",
    #     .x == "Sub-division" ~ "industry_subdivision",
    #     .x == "Employment size" ~ "emp_size",
    #     .x == "Sex" ~ "gender",
    #     .x == "Age group" ~ "age",
    #     .x == "Statistical Area 4" ~ "sa4",
    #     .x == "Statistical Area 3" ~ "sa3",
    #     TRUE ~ to_snake(.x)
    #   )) %>%
    #   tidyr::pivot_longer(
    #     cols = dplyr::starts_with("4"),
    #     names_to = "date",
    #     values_to = "value"
    #   ) %>%
    #   dplyr::mutate(value = suppressWarnings(as.numeric(.data$value))) %>%
    #   dplyr::filter(.data$value != "NA") %>%
    #   dplyr::mutate(date = as.Date(as.numeric(.data$date), origin = "1899-12-30"),
    #                 dplyr::across(where(is.character), ~gsub(pattern = ".*\\. ", x =  .x, replacement = "", perl = TRUE)),
    #                 indicator = "Payroll wages", 
    #                 state = strayr::clean_state(.data$state, to = "state_name"))
    
    
    
    
    
    payroll_index <- payroll_jobs %>%
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
