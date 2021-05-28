## code to prepare `labour_capability` dataset goes here
library(readr)
library(dplyr)
library(reticulate)

sub_100_businesses <- input_data %>%
  group_by(sa2_name_2016) %>%
  summarise(total = sum(total), .groups = "drop") %>%
  filter(total < 1807) %>%
  pull(sa2_name_2016)

input_data <- read_csv("data-raw/degree2_2016_ur.csv", skip = 9, n_max = 88) %>%
  select(sa2_name_2016 = "SA2 (UR)",
         occupation = "OCCP - 2 Digit Level",
         total = "Count") %>%
  filter(!occupation %in% c("Inadequately described", "Not stated", "Not applicable", "Total"),
         !sa2_name_2016 %in% c("Total", sub_100_businesses)) %>% 
  mutate(year = 2016) %>%
  replace_na(replace = list(total = 0))



ecomplexity <- import("ecomplexity")
cols_input <- dict(time = "year", loc = "sa4_name_2016", prod = "field", val = "value")
out <- ecomplexity$ecomplexity(input_data, cols_input) %>%
  as_tibble() %>%
  filter(!is.nan(pci))

usethis::use_data(labour_capability, overwrite = TRUE)
