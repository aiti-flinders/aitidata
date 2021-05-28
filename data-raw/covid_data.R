## code to prepare `covid_data` dataset goes here
devtools::load_all()
source("data-raw/jobkeeper_sa2.R")
source("data-raw/jobseeker_sa2.R")
source("data-raw/small_area_labour_market.R")
source("data-raw/payroll_substate.R")

covid_data <- bind_rows(jobkeeper_sa2, jobseeker_sa2) %>%
  left_join(small_area_labour_market %>%
    filter(
      indicator == "Smoothed labour force (persons)",
      date == max(.$date)
    ) %>%
    select(
      labour_force = value,
      sa2_main_2016
    )) %>%
  pivot_wider(id_cols = c(sa2_main_2016, date, labour_force), names_from = indicator, values_from = value) %>%
  janitor::clean_names() %>%
  mutate(
    jobseeker_proportion = 100 * jobseeker_payment / labour_force,
    jobkeeper_decile = ntile(jobkeeper_proportion, 10),
    jobseeker_decile = ntile(jobseeker_proportion, 10),
    covid_impact = jobkeeper_decile + jobseeker_decile
  ) %>%
  left_join(sa22016) %>%
  select(
    sa2_main_2016,
    sa3_code_2016,
    date,
    jobkeeper_applications,
    jobkeeper_proportion,
    jobseeker_payment,
    jobseeker_proportion,
    covid_impact,
    state_name_2016
  ) %>%
  left_join(payroll_substate %>% filter(indicator == "payroll_index")  %>% select(-indicator, payroll_index = value)) %>%
  arrange(date) %>%
  group_by(state_name_2016, sa2_main_2016) %>%
  mutate(jobkeeper_growth = jobkeeper_applications - lag(jobkeeper_applications)) %>%
  ungroup() %>%
  select(
    state = state_name_2016,
    sa2_main_2016,
    sa3_code_2016,
    date,
    jobkeeper_applications,
    jobkeeper_proportion,
    jobkeeper_growth,
    jobseeker_payment,
    jobseeker_proportion,
    payroll_index,
    covid_impact
  ) %>%
  pivot_longer(cols = c(5:length(.)), names_to = "indicator", values_to = "value")


usethis::use_data(covid_data, overwrite = TRUE, compress = "xz")
