## code to prepare `employment_by_industry_sa2` dataset goes here
#Data from 2016 census - table builder

library(tidyverse)


employment_by_industry_sa2 <- read_csv("data-raw/employment_by_industry_by_sa2.zip", 
                                    skip = 10, 
                                    col_names = c("counting", 
                                                  "sa2_name_2016",
                                                  "industry",
                                                  "value")) %>%
  filter(!is.na(industry),
         sa2_name_2016 != "Total",
         industry != "Total") %>%
  select(industry, sa2_name_2016, value) %>%
  group_by(sa2_name_2016) %>%
  mutate(industry_share = value/sum(value)) %>%
  ungroup() %>%
  group_by(industry) %>%
  mutate(industry_aus = sum(value)) %>%
  ungroup() %>%
  group_by(sa2_name_2016) %>%
  mutate(sa2_share = industry_aus/sum(industry_aus)) %>%
  ungroup() %>%
  group_by(industry, sa2_name_2016, employment = value) %>%
  summarise(rca_employment = industry_share/sa2_share, .groups = 'drop') %>%
  ungroup()



usethis::use_data(employment_by_industry_sa2, compress = "xz", overwrite = TRUE)


  
