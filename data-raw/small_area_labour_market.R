## code to prepare `small_area_labour_market` dataset goes here
library(rvest)
library(usethis)
library(readr)
library(dplyr)

url <- "https://www.jobsandskills.gov.au/data/small-area-labour-markets#downloads"

path_to_file <- read_html(url) |> 
  html_elements(xpath = "/html/body/div[1]/div/div/div[2]/div/div/main/section/section/div[2]/div/article/div/div[1]/div[2]/div[24]/div/div/div/div[2]/a") |> 
  html_attr("href")

path_to_file <- paste0("https://www.jobsandskills.gov.au", path_to_file)

if (!file.exists("data-raw/small_area_labour_market.csv")) {
  download.file(path_to_file,
                destfile = "data-raw/small_area_labour_market.csv",
                mode = "wb")
}

small_area_labour_market <- read_csv("data-raw/small_area_labour_market.csv",
                                     skip = 1,
                                     show_col_types = F,
                                     na = "-") |> 
  mutate(across(where(is.numeric), as.character)) |> 
  rename(indicator = "Data Item",
         sa2_name = "Statistical Area Level 2 (SA2) (2021 ASGS)",
         sa2_code = "SA2 Code (2021 ASGS)") |> 
  pivot_longer(cols = -c("indicator",
                         "sa2_name",
                         "sa2_code"),
               names_to = "date",
               values_to = "value") |> 
  mutate(value =  as.numeric(gsub(",", "", value)),
         date = as.Date(paste0(.data$date, "-01"), format = "%b-%y-%d")) |> 
  select(date, sa2_code, sa2_name, indicator, value)

use_data(small_area_labour_market, compress = "xz", overwrite = TRUE)
