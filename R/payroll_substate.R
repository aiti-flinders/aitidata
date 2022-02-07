
update_payroll_substate <- function() {
  abs_test <- readabs::read_payrolls(series = "sa3_jobs", path = "data-raw")
  
  
  if (max(abs_test$date) <= max(aitidata::payroll_substate$date)) {
    message("Skipping `payroll_substate.rda`: appears to be up-to-date")
    file.remove("data-raw/6160055001_DO005.xlsx")
  } else {
    message("updating `payroll_substate.rda`")
    
    abs_file <- abs_test
    
    
    payroll_substate <- abs_file %>%
      dplyr::mutate(state_name = clean_state(state, to = "state_name"),
                    sa3_name = statistical_area_level_3,
                    indicator = "Payroll Index") %>%
      dplyr::left_join(strayr::read_absmap("sa32016", remove_year_suffix = TRUE), by = c("state_name", "sa3_name")) %>%
      dplyr::select(state_name, date, value, sa3_code, indicator) %>%
      dplyr::filter(!is.na(sa3_code), !is.na(value))
    
    file.remove("data-raw/6160055001_DO005.xlsx")
    usethis::use_data(payroll_substate, overwrite = TRUE, compress = "xz")
    return(TRUE)
  }
  
}