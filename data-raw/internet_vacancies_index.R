## code to prepare `internet_vacancies_index` dataset goes here
## code to prepare `internet_vacancies` dataset goes here
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
library(strayr)




download.file("https://lmip.gov.au/PortalFile.axd?FieldID=2790177&.xlsx",
    destfile = "data-raw/internet_vacancies_basic.xlsx",
    mode = "wb")


raw <- read_excel("data-raw/internet_vacancies_basic.xlsx",
                  sheet = 1,
                  .name_repair = "universal")

internet_vacancies_basic <- raw %>%
  pivot_longer(cols = 5:length(.), names_to = "date", values_to = "value") %>%
  mutate(date = gsub(pattern = "[...]", replacement = "", date),
         date = as.Date(as.numeric(date), origin = "1904-01-01"),
         state = clean_state(State, to = "state_name", fuzzy_match = FALSE)) %>%
  group_by(state, date, ANZSCO_CODE, Title) %>%
  summarise(value = mean(value), .groups = "drop") %>%
  rename(occupation = Title, anzsco_2 = ANZSCO_CODE) %>%
  ungroup()

anzsco_tibble <- tribble(
  ~anzsco_1, ~occupation_group,
  "0", "Total",
  "1", "Managers",
  "2", "Professionals",
  "3", "Technicians and Trades Workers",
  "4", "Community and Personal Service Workers",
  "5", "Clerical and Administrative Workers",
  "6", "Sales Workers",
  "7", "Machinery Operators and Drivers",
  "8", "Labourers"
)

internet_vacancies_index <- internet_vacancies_basic %>%
  mutate(anzsco_1 = str_sub(anzsco_2, 0, 1)) %>%
  left_join(anzsco_tibble) %>%
  mutate(
    occupation = ifelse(
      grepl("TOTAL", occupation), 
      "TOTAL", 
      occupation),
    occupation = ifelse(
      (str_length(anzsco_2) == 1 & anzsco_2 != "0"), 
      str_to_title(paste0(occupation, " (Total)")), 
      occupation)
  )


file.remove("data-raw/internet_vacancies_basic.xlsx")

usethis::use_data(internet_vacancies_index, overwrite = TRUE, compress = "xz")


