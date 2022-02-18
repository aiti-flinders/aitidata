
update_payroll_substate <- function(force_update = FALSE) {
  abs_test <- readabs::read_payrolls(series = "sa3_jobs", path = "data-raw")
  
  
  if (max(abs_test$date) > max(aitidata::payroll_substate$date) | force_update) {
    
    message("updating `payroll_substate.rda`")
    
    abs_file <- abs_test
    
    
    payroll_substate <- abs_file %>%
      dplyr::mutate(state_name = strayr::clean_state(.data$state, to = "state_name"),
                    sa3_name = .data$statistical_area_level_3,
                    indicator = "Payroll Index") %>%
      dplyr::left_join(strayr::read_absmap("sa32016", remove_year_suffix = TRUE), by = c("state_name", "sa3_name")) %>%
      dplyr::select(.data$state_name,
                    .data$date, 
                    .data$value, 
                    .data$sa3_code, 
                    .data$indicator) %>%
      dplyr::filter(!is.na(.data$sa3_code), !is.na(.data$value))
    
    usethis::use_data(payroll_substate, overwrite = TRUE, compress = "xz")
    file.remove("data-raw/6160055001_DO005.xlsx")

  } else {
    message("Skipping `payroll_substate.rda`: appears to be up-to-date")
    file.remove("data-raw/6160055001_DO005.xlsx")
  }
  
}