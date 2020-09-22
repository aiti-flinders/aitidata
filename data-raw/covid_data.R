## code to prepare `covid_data` dataset goes here
library(absmapsdata)
library(dplyr)
library(sf)

devtools::load_all(".")

source("data-raw/jobkeeper_sa2.R")
source("data-raw/jobseeker_sa2.R")
source("data-raw/small_area_labour_market.R")
source("data-raw/payroll_sa4.R")

covid_data <- bind_rows(jobkeeper_sa2, jobseeker_sa2)  %>%
  left_join(small_area_labour_market %>% 
              filter(indicator == "Smoothed labour force (persons)",
                     date == max(.$date)) %>%
              select(labour_force = value,
                     sa2_main_2016)) %>% 
  pivot_wider(id_cols = c(sa2_main_2016, date, labour_force), names_from = indicator, values_from = value) %>%
  janitor::clean_names() %>%
  mutate(jobseeker_proportion = 100*jobseeker_payment/labour_force,
         jobkeeper_decile = ntile(jobkeeper_proportion, 10), 
         jobseeker_decile = ntile(jobseeker_proportion, 10), 
         covid_impact = jobkeeper_decile + jobseeker_decile) %>%  
  left_join(sa22016) %>%
  select(sa2_main_2016, 
         date,
         jobkeeper_applications, 
         jobkeeper_proportion, 
         jobseeker_payment,
         jobseeker_proportion,
         covid_impact, 
         state_name_2016) %>% 
  pivot_longer(cols = c(-sa2_main_2016, -state_name_2016, -date), names_to = 'indicator', values_to = 'value') %>%
  bind_rows(payroll_sa4) %>% 
  pivot_longer(cols = c(sa2_main_2016, sa4_code_2016), names_to = "statistical_area", values_to = "statistical_area_code") %>%
  filter(!is.na(statistical_area_code)) %>%
  mutate(statistical_area = str_sub(statistical_area, 0L, 3L)) %>% 
  rename(state = state_name_2016) %>%
  arrange(date) %>% 
  pivot_wider(id_cols = c(date, state, value, statistical_area, statistical_area_code), 
              names_from = indicator, 
              values_from = value) %>% 
  group_by(state, statistical_area, statistical_area_code) %>%
  mutate(jobkeeper_growth = jobkeeper_applications-lag(jobkeeper_applications)) %>% 
  pivot_longer(cols = c(6:11), names_to = 'indicator', values_to = 'value')

usethis::use_data(covid_data, overwrite = TRUE, compress = 'xz')
