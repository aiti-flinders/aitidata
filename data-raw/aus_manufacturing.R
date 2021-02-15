## code to prepare `aus_manufacturing` dataset goes here
library(dplyr)
library(stringr)
library(tidyr)

abs_file <- download_data_cube(catalogue_string = "australian-industry",
                               cube = "Manufacturing industry", 
                               path = "data-raw")
#fpath <- gsub("[^\\/]*$", "", fpath)

aus_manufacturing <- read_xls(abs_file, sheet = "Table_1", skip = 6) %>%
  select(1, (length(.)-3):length(.)) %>%
  rename("industry" = 1, "employment" = 2, "wages" = 3, "income" = 4,  "iva" = 5) %>%
  mutate(industry_code = str_extract(industry, "\\d{2,4}"),
         industry = trimws(str_replace(industry, "\\d{2,4}", ""))) %>%
  filter(industry != "Manufacturing")

file.remove(abs_file)

usethis::use_data(aus_manufacturing, overwrite = TRUE)
