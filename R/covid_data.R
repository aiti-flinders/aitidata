## code to prepare `covid_data` dataset goes here
update_covid_data <- function() {
  
  maps_data <- strayr::read_absmap("sa22016", remove_year_suffix = TRUE) 
  
  covid_data <- dplyr::bind_rows(aitidata::jobkeeper_sa2, aitidata::jobseeker_sa2) %>%
    dplyr::left_join(by = "sa2_code", aitidata::small_area_labour_market %>% 
                       dplyr::filter(.data$indicator == "Smoothed labour force (persons)", date == max(.data$date)) %>%
                       dplyr::select(labour_force = "value", "sa2_code")) %>%
    dplyr::filter(!is.na(sa2_code)) %>% 
    tidyr::pivot_wider(id_cols = c("sa2_code", 
                                   "date", 
                                   "labour_force"), 
                       names_from = "indicator", 
                       values_from = "value") %>%
    dplyr::rename(jobkeeper_applications = 4,
                  jobkeeper_proportion = 6,
                  jobseeker_payment = 7) %>%
    dplyr::mutate(jobseeker_proportion = 100 * .data$jobseeker_payment / .data$labour_force,
                  jobkeeper_decile = dplyr::ntile(.data$jobkeeper_proportion, 10),
                  jobseeker_decile = dplyr::ntile(.data$jobseeker_proportion, 10),
                  covid_impact = .data$jobkeeper_decile + .data$jobseeker_decile) %>%
    dplyr::left_join(maps_data, by = "sa2_code") %>%
    dplyr::select("sa2_code",
                  "sa3_code",
                  "date",
                  "jobkeeper_applications",
                  "jobkeeper_proportion",
                  "jobseeker_payment",
                  "jobseeker_proportion",
                  "covid_impact",
                  "state_name") %>%
    dplyr::left_join(by = c("sa3_code", "date", "state_name"),
                     aitidata::payroll_substate %>% dplyr::filter(.data$indicator == "payroll_index")  %>% dplyr::select(-"indicator", payroll_index = "value")) %>%
    dplyr::arrange(.data$date) %>%
    dplyr::group_by(.data$state_name, .data$sa2_code) %>%
    dplyr::mutate(jobkeeper_growth = .data$jobkeeper_applications - dplyr::lag(.data$jobkeeper_applications)) %>%
    dplyr::ungroup() %>%
    dplyr::select(state = "state_name",
                  "sa2_code",
                  "sa3_code",
                  "date",
                  "jobkeeper_applications",
                  "jobkeeper_proportion",
                  "jobkeeper_growth",
                  "jobseeker_payment",
                  "jobseeker_proportion",
                  "payroll_index",
                  "covid_impact") %>%
    tidyr::pivot_longer(cols = -c("state",
                                  "sa2_code",
                                  "sa3_code",
                                  "date"), 
                        names_to = "indicator",
                        values_to = "value") 
  
  usethis::use_data(covid_data, overwrite = TRUE, compress = "xz")
  return(TRUE)
}
