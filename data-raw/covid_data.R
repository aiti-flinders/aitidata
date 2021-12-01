## code to prepare `covid_data` dataset goes here
devtools::load_all(".")
source("data-raw/jobkeeper_sa2.R")
source("data-raw/jobseeker_sa2.R")
source("data-raw/small_area_labour_market.R")
source("data-raw/payroll_substate.R")

maps_data <- strayr::read_absmap("sa22016")

covid_data <- bind_rows(jobkeeper_sa2, jobseeker_sa2) %>%
  dplyr::left_join(by = "sa2_code_2016", small_area_labour_market %>% 
                     dplyr::filter( indicator == "Smoothed labour force (persons)", date == max(.$date)) %>%
                     dplyr::select(labour_force = value, sa2_code_2016)) %>%
  tidyr::pivot_wider(id_cols = c(sa2_code_2016, date, labour_force), names_from = indicator, values_from = value) %>%
  dplyr::rename(jobkeeper_applications = 4,
                jobkeeper_proportion = 6,
                jobseeker_payment = 7) %>%
  dplyr::mutate(jobseeker_proportion = 100 * jobseeker_payment / labour_force,
                jobkeeper_decile = dplyr::ntile(jobkeeper_proportion, 10),
                jobseeker_decile = dplyr::ntile(jobseeker_proportion, 10),
                covid_impact = jobkeeper_decile + jobseeker_decile) %>%
  dplyr::left_join(maps_data, by = "sa2_code_2016") %>%
  dplyr::select(sa2_code_2016,
                sa3_code_2016,
                date,
                jobkeeper_applications,
                jobkeeper_proportion,
                jobseeker_payment,
                jobseeker_proportion,
                covid_impact,
                state_name_2016) %>%
  dplyr::left_join(by = c("sa3_code_2016", "date", "state_name_2016"),
                   payroll_substate %>% dplyr::filter(indicator == "payroll_index")  %>% dplyr::select(-indicator, payroll_index = value)) %>%
  dplyr::arrange(date) %>%
  dplyr::group_by(state_name_2016, sa2_code_2016) %>%
  dplyr::mutate(jobkeeper_growth = jobkeeper_applications - lag(jobkeeper_applications)) %>%
  dplyr::ungroup() %>%
  dplyr::select(state = state_name_2016,
                sa2_code_2016,
                sa3_code_2016,
                date,
                jobkeeper_applications,
                jobkeeper_proportion,
                jobkeeper_growth,
                jobseeker_payment,
                jobseeker_proportion,
                payroll_index,
                covid_impact) %>%
  tidyr::pivot_longer(cols = 5:length(.), names_to = "indicator", values_to = "value")


usethis::use_data(covid_data, overwrite = TRUE, compress = "xz")
