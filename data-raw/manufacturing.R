## code to prepare `manufacturing` dataset goes here
library(readabs)
library(readxl)
library(tidyr)
library(dplyr)
library(stringr)
library(usethis)

manufacturing_url <- get_available_files("australian-industry") |> 
  filter(label == "Manufacturing industry") |> 
  pull(file)

abs_file <- download_abs_data_cube(catalogue_string = "australian-industry",
                                   cube = manufacturing_url, 
                                   path = "data-raw")

years <- colnames(read_excel(abs_file, sheet = "Table_1", range = c("B6:D6")))

aus_manufacturing <- read_excel(abs_file, 
                                sheet = "Table_1", 
                                skip = 7, 
                                col_names = c("industry", 
                                              "employment_1", "wages_1", "income_1", "iva_1",
                                              "employment_2", "wages_2", "income_2", "iva_2",
                                              "employment_3", "wages_3", "income_3", "iva_3")) |> 
  pivot_longer(cols = where(is.double), names_to = "indicator", values_to = "value") |> 
  mutate(year = case_when(
    str_detect(indicator, "_1") ~ years[1],
    str_detect(indicator, "_2") ~ years[2],
    str_detect(indicator, "_3") ~ years[3]),
    industry_code = str_extract(industry, "\\d{2,4}"),
    industry_code = ifelse(is.na(industry_code), "C", industry_code),
    industry = trimws(str_replace(industry, "\\d{2,4}", "")),
    indicator = str_remove_all(indicator, "_[1-3]")) |> 
  filter(!is.na(value),
         !is.na(industry))

use_data(aus_manufacturing, overwrite = TRUE, compress = "xz")
