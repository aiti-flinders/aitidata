## code to prepare `jobseeker_sa2` dataset goes here

library(tidyverse)
library(readxl)
library(xml2)
library(rvest)
library(absmapsdata)

jobseeker_latest <- read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") %>%
  html_nodes(xpath = '//*[@id="content"]/div[3]/div/article/div/section[3]/table/tbody/tr[9]/td') %>%
  html_text() %>%
  as.Date()

if (as.Date(file.info("data/jobseeker_sa2.rda")$mtime) < jobseeker_latest | !file.exists("data/jobseeker_sa2.rda")) {
  message("Updating `data/jobseeker_sa2.rda`")

  files <- tibble(
    url = read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") %>% html_nodes("#dataset-resources a") %>% html_attr("href")
  ) %>%
    filter(grepl(".xlsx", url)) %>%
    mutate(date = str_extract(url, "(january|february|march|april|may|june|july|august|september|october|november|december)-\\d{4}"))

  download.file(files$url, destfile = paste0("data-raw/", files$date, ".xlsx"), method = "libcurl", mode = "wb")

  jobseeker_all <- tibble(
    "sa2" = numeric(),
    "sa2_name" = character(),
    "jobseeker_payment" = numeric(),
    "youth_allowance_other" = numeric()
  )

  for (i in seq_along(files$url)) {
    dss_month <- read_excel(paste0("data-raw/", files$date[i], ".xlsx"),
      sheet = "Table 4 - By SA2",
      skip = 7,
      n_max = 2292,
      col_names = c("sa2", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
      col_types = c("numeric", "text", "numeric", "numeric")
    ) %>%
      mutate(date = as.Date(paste0(files$date[i], "-01"), format = "%B-%Y-%d")) %>%
      replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5))

    jobseeker_all <- bind_rows(jobseeker_all, dss_month)
  }

  jobseeker_sa2 <- jobseeker_all %>%
    left_join(sa22016, by = c("sa2_name" = "sa2_name_2016")) %>%
    select(sa2_main_2016, jobseeker_payment, youth_allowance_other, date) %>%
    arrange(date) %>%
    group_by(sa2_main_2016) %>%
    mutate(
      jobseeker_growth = jobseeker_payment - lag(jobseeker_payment),
      youth_allowance_growth = youth_allowance_other - lag(youth_allowance_other)
    ) %>%
    ungroup() %>%
    pivot_longer(cols = c(-sa2_main_2016, -date), names_to = "indicator", values_to = "value") %>%
    mutate(indicator = str_to_sentence(str_replace_all(indicator, "_", " ")))

  usethis::use_data(jobseeker_sa2, compress = "xz", overwrite = TRUE)
} else {
  message("`data/jobseeker_sa2.rda` is already up to date")
}
