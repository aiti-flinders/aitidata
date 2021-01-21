## code to prepare `aus_manufacturing` dataset goes here
library(dplyr)
library(tidyr)
library(readabs)

fpath <- download_data_cube("australian-industry", "Manufacturing industry")
fpath <- gsub("[^\\/]*$", "", fpath)

read_xls(fpath, sheet = "Table_1", skip = 6) %>%
  select(1, (length(.)-3):length(.)) %>%
  rename("industry" = 1, "employment" = 2, "wages" = 3, "income" = 4,  "iva" = 5) %>%
  mutate(industry_code = str_extract(industry, "\\d{2,4}"),
         industry = trimws(str_replace(industry, "\\d{2,4}", ""))) %>%
  filter(industry != "Manufacturing")



usethis::use_data(aus_manufacturing, overwrite = TRUE)
