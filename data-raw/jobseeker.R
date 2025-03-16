## code to prepare `jobseeker` dataset goes here
library(tibble)
library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(usethis)

files <- tibble(
  url = read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") |> 
    html_nodes("#dataset-resources a") |> 
    html_attr("href")) |> 
  filter(grepl(".xlsx", url)) %>%
  mutate(date = str_extract(url, "(january|february|march|april|may|june|july|august|september|october|november|december)-\\d{4}"),
         date = as.Date(paste0(date, "-01"), "%B-%Y-%d")
  )  |>     
  distinct(date, .keep_all = TRUE) #data.gov.au occasionally has duplicate files uploaded

read_jobseeker <- function(url, date) {
  fname <- paste0("data-raw/jobseeker/", date, "-jobseeker_sa2.xlsx")
  
  if (!file.exists(fname)) {
    download.file(url, destfile = fname, mode = "wb")
  }
    
    sa2_sheet <- which(grepl("By SA2", excel_sheets(fname)))
    
    monthly <- read_excel(fname,
                          sheet = sa2_sheet,
                          skip = 10,
                          na = "<5",
                          col_names = c("sa2_code", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
                          col_types = c("numeric", "text", "numeric", "numeric")) |> 
      filter(!is.na(sa2_code)) |> 
      mutate(date = {{date}})  |> 
      replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5)) |> 
      select("sa2_code",
             "sa2_name",
             "jobseeker_payment", 
             "youth_allowance_other", 
             "date") |> 
      pivot_longer(names_to = "indicator",
                   values_to = "value",
                   cols = c("jobseeker_payment", "youth_allowance_other")) |> 
      mutate(indicator = str_to_sentence(str_replace_all(indicator, "_", " ")))
  
}


jobseeker_sa2 <- map2(.x = files$url,
                      .y = files$date,
                      .f = function(x,y) read_jobseeker(x, y)) |> 
  list_rbind()

use_data(jobseeker_sa2, overwrite = TRUE, compress = "xz")
