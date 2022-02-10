## code to prepare `covid_data` dataset goes here
update_covid_data <- function() {
  
  maps_data <- strayr::read_absmap("sa22016", remove_year_suffix = TRUE) 
  
  covid_data <- dplyr::bind_rows(aitidata::jobkeeper_sa2, aitidata::jobseeker_sa2) %>%
    dplyr::left_join(by = "sa2_code", aitidata::small_area_labour_market %>% 
                       dplyr::filter(.data$indicator == "Smoothed labour force (persons)", date == max(.data$date)) %>%
                       dplyr::select(labour_force = .data$value, .data$sa2_code)) %>%
    tidyr::pivot_wider(id_cols = c(.data$sa2_code, 
                                   .data$date, 
                                   .data$labour_force), 
                       names_from = .data$indicator, 
                       values_from = .data$value) %>%
    dplyr::rename(jobkeeper_applications = 4,
                  jobkeeper_proportion = 6,
                  jobseeker_payment = 7) %>%
    dplyr::mutate(jobseeker_proportion = 100 * .data$jobseeker_payment / .data$labour_force,
                  jobkeeper_decile = dplyr::ntile(.data$jobkeeper_proportion, 10),
                  jobseeker_decile = dplyr::ntile(.data$jobseeker_proportion, 10),
                  covid_impact = .data$jobkeeper_decile + .data$jobseeker_decile) %>%
    dplyr::left_join(maps_data, by = "sa2_code") %>%
    dplyr::select(.data$sa2_code,
                  .data$sa3_code,
                  .data$date,
                  .data$jobkeeper_applications,
                  .data$jobkeeper_proportion,
                  .data$jobseeker_payment,
                  .data$jobseeker_proportion,
                  .data$covid_impact,
                  .data$state_name) %>%
    dplyr::left_join(by = c("sa3_code", "date", "state_name"),
                     aitidata::payroll_substate %>% dplyr::filter(.data$indicator == "payroll_index")  %>% dplyr::select(-.data$indicator, payroll_index = .data$value)) %>%
    dplyr::arrange(.data$date) %>%
    dplyr::group_by(.data$state_name, .data$sa2_code) %>%
    dplyr::mutate(jobkeeper_growth = .data$jobkeeper_applications - dplyr::lag(.data$jobkeeper_applications)) %>%
    dplyr::ungroup() %>%
    dplyr::select(state = .data$state_name,
                  .data$sa2_code,
                  .data$sa3_code,
                  .data$date,
                  .data$jobkeeper_applications,
                  .data$jobkeeper_proportion,
                  .data$jobkeeper_growth,
                  .data$jobseeker_payment,
                  .data$jobseeker_proportion,
                  .data$payroll_index,
                  .data$covid_impact) %>%
    tidyr::pivot_longer(cols = -c(.data$state,
                                  .data$sa2_code,
                                  .data$sa3_code,
                                  .data$date), 
                        names_to = "indicator",
                        values_to = "value") 
  
  usethis::use_data(covid_data, overwrite = TRUE, compress = "xz")
  return(TRUE)
}
