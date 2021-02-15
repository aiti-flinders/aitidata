## code to prepare `national_accounts` dataset goes here
library(readabs)
library(dplyr)
library(tidyr)
library(stringr)

raw <- read_abs(cat_no = "5206.0", tables = c(1, 6), retain_files = FALSE)

national_accounts <- raw %>%
  filter(table_no == "5206006_industry_gva") %>%
  mutate(series = str_replace_all(series, regex("(\\s\\([A-S]\\)\\s)|(\\s;)$", multiline = TRUE), "")) %>%
  separate(series, into = c("industry", "subdivision"), sep = ";", fill = "right") %>%
  mutate(across(where(is.character), ~ trimws(.)),
    industry = str_replace_all(str_to_title(industry), "And", "and")
  ) %>%
  filter(
    industry %in% aitidata::anzsic$division,
    !is.na(value)
  ) %>%
  mutate(subdivision = ifelse(subdivision == "", paste(industry, "(Total)"), subdivision)) %>%
  separate(subdivision, into = c("subdivision", "indicator"), sep = ":", fill = "right") %>%
  select(date, industry, subdivision, value, series_type, unit) %>%
  mutate(
    indicator =
      case_when(
        unit == "$ Millions" ~ "Gross Value Added",
        unit == "Percent" ~ "Percent Changes",
        unit == "Index Points" ~ "Contribution To Growth"
      ),
    indicator = ifelse(indicator == "Percent Changes", paste("Gross value added (Growth)"), indicator),
    subdivision = ifelse(subdivision %in% c(
      "Gross Value Added",
      "Percentage Changes",
      "Contributions To Growth",
      "Revision To Percentage Changes"
    ),
    paste(industry, "(Total)"),
    subdivision
    ),
    indicator = str_to_sentence(indicator)
  )


# industry_aggregates <- raw %>%
#   filter(table_no == "5206006_industry_gva") %>%
#   separate(series, into = c("indicator", "type"), sep = ": ") %>%
#   mutate(across(where(is.character), ~ str_to_sentence(.)),
#     indicator = ifelse(str_detect(type, "percentage changes"), paste(indicator, "(growth)"), indicator),
#     type = str_remove_all(type, "( - percentage changes ;)|( ;)")
#   ) %>%
#   filter(!is.na(value)) %>%
#   select(date, indicator, type, value, series_type, unit)

# national_accounts <- bind_rows(industry_aggregates, industry_value_add) %>%
#   mutate(across(c(industry, subdivision), ~ ifelse(is.na(.), "Total (industry)", .)))


usethis::use_data(national_accounts, overwrite = TRUE, compress = "xz")
