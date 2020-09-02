## code to prepare `economic_complexity` dataset goes here
library(ecomplexity)
library(tidyverse)

states <- str_to_upper(strayr::strayr(seq(1,8,1)))

economic_complexity <- get_data_states() %>%
  filter(location_code %in% states) %>%
  group_by(location_code, year) %>% 
  mutate(total_exports = sum(export_value)) %>%
  ungroup() %>%
  distinct(year, location_code, eci, coi, diversity, total_exports) %>%
  pivot_longer(cols = c(3:6), names_to = "indicator", values_to = "value") 


usethis::use_data(economic_complexity, overwrite = TRUE, compress = "xz")

