## code to prepare `job_vacancies` dataset goes here
library(rvest)
library(readxl)
library(tidyr)
library(dplyr)
library(strayr)
library(usethis)
library(stringr)

# Internet Vacancy Index --------------------------------------------------


url <- "https://www.jobsandskills.gov.au/data/internet-vacancy-index#downloads"

path_to_file <- read_html(url) |> 
  html_elements(xpath = "/html/body/div[1]/div/div/div[2]/div/div/main/section/section/div[2]/div/article/div/div[1]/div[2]/div[8]/div/div/div/div/div/div/div/div/div[3]/a") |>
  html_attr("href")

path_to_file <- paste0("https://www.jobsandskills.gov.au", path_to_file)
fname <- str_extract(path_to_file, "[^\\/]+$")

if (!file.exists(paste0("data-raw/job_vacancies/", fname))) {
  
  download.file(path_to_file, 
                destfile = paste0("data-raw/job_vacancies/", fname),
                mode = "wb")
}

internet_vacancy_index <- read_xlsx(paste0("data-raw/job_vacancies/", fname),
                                    sheet = "Trend") |> 
  pivot_longer(cols = -c("Level",
                         "ANZSCO_CODE",
                         "Title",
                         "State"),
               names_to = "date", 
               values_to = "value") |> 
  mutate(date = as.Date(as.numeric(date), origin = "1899-12-30"),
         unit = "000",
         state = clean_state(State, to = "state_name"),
         Title = ifelse(grepl("TOTAL", Title), "TOTAL", Title)) |> 
  group_by(state, date, ANZSCO_CODE, Title, Level) |> 
  summarise(value = mean(value), .groups = "drop") |> 
  select("date",
         "state",
         occupation_level = "Level",
         anzsco_code = "ANZSCO_CODE",
         anzsco_title = "Title",
         "value") |> 
  mutate(anzsco_title = str_to_title(anzsco_title))


use_data(internet_vacancy_index, overwrite = TRUE, compress = "xz")


# Internet Vacancy Index (Regional) ---------------------------------------

path_to_file <- read_html(url) |> 
  html_elements(xpath = "/html/body/div[1]/div/div/div[2]/div/div/main/section/section/div[2]/div/article/div/div[1]/div[2]/div[8]/div/div/div/div/div/div/div/div/div[4]/a") |>
  html_attr("href")

path_to_file <- paste0("https://www.jobsandskills.gov.au", path_to_file)
fname <- str_extract(path_to_file, "[^\\/]+$")


if (!file.exists(paste0("data-raw/job_vacancies/", fname))) {
  tryCatch(
  download.file(path_to_file, 
                destfile = paste0("data-raw/job_vacancies/", fname),
                mode = "wb"),
  error = "Can't download file."
  )
}


internet_vacancy_regional <- read_excel(paste0("data-raw/job_vacancies/", fname),
                                        sheet = 2) |> 
  pivot_longer(cols = -c("Level",
                         "State",
                         "region",
                         "ANZSCO_CODE",
                         "ANZSCO_TITLE"),
               names_to = "date",
               values_to = "value") |> 
  mutate(date = as.Date(as.numeric(date), origin = "1899-12-30"),
         unit = "000",
         state = clean_state(State, to = "state_name"),
         ANZSCO_TITLE = ifelse(grepl("TOTAL", ANZSCO_TITLE), "TOTAL", ANZSCO_TITLE)) |> 
  select("date",
         occupation_level = "Level",
         state = "State",
         vacancy_region = "region",
         anzsco_code = "ANZSCO_CODE",
         anzsco_title = "ANZSCO_TITLE",
         "value")

use_data(internet_vacancy_regional, overwrite = TRUE, compress = "xz")

