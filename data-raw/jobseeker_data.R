## code to prepare `jobseeker_data` dataset goes here
library(rvest)
library(dplyr)
library(sf)
library(tidyr)
library(stringr)
library(purrr)
library(readxl)
library(strayr)
library(lubridate)


jobseeker_files <- data.frame(
  url = read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") %>% 
    html_nodes("#dataset-resources a") %>% 
    html_attr("href")) %>%
  filter(grepl(".xlsx", url)) %>%
  mutate(date = str_extract(url, "(january|february|march|april|may|june|july|august|september|october|november|december)-\\d{4}"),
         as.Date(paste0(date, "-01"), "%B-%Y-%d")
  ) %>%
  distinct(date, .keep_all = TRUE)

file_paths <- map(jobseeker_files$url, ~aitidata::download_file(.x))

jobseeker_all <- data.frame(
  "sa2" = numeric(),
  "sa2_name" = character(),
  "jobseeker_payment" = numeric(),
  "youth_allowance_other" = numeric()
)

for (i in seq_along(file_paths)) {
  dss_month <- read_excel(file_paths[[i]],
                                  sheet = "Table 4 - By SA2",
                                  skip = 7,
                                  na = "<5",
                                  n_max = 2292,
                                  col_names = c("sa2", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
                                  col_types = c("numeric", "text", "numeric", "numeric")) %>%
    mutate(date = files$date[i]) %>%
    replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5))
  
  jobseeker_all <- bind_rows(jobseeker_all, dss_month)
}

jobseeker_sa2 <- jobseeker_all %>%
  left_join(read_absmap("sa22016", remove_year_suffix = TRUE), by = c("sa2_name")) %>%
  select(.data$sa2_code, 
                .data$jobseeker_payment, 
                .data$youth_allowance_other, 
                .data$date) 

jobseeker_state <- jobseeker_all %>%
  left_join(read_absmap("sa22016", remove_year_suffix = TRUE), by = "sa2_name") %>%
  select(.data$state_name, 
                .data$jobseeker_payment,
                .data$youth_allowance_other,
                .data$date) %>%
  arrange(.data$date) %>%
  group_by(.data$state_name, 
                  .data$date) %>%
  summarise(across(c(.data$jobseeker_payment, .data$youth_allowance_other), ~sum(.,na.rm = T)), .groups = "drop") %>%
  ungroup()

map_lgl(file_paths, file.remove)


usethis::use_data(jobseeker_state, compress = "xz", overwrite = TRUE)
usethis::use_data(jobseeker_sa2, compress = "xz", overwrite = TRUE)



