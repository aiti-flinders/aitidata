## code to prepare `south_australia_net_debt` dataset goes here
library(readr)
library(dplyr)
library(readabs)

sand <- read_csv("data-raw/public_sector_balance_sheet.csv",
  col_names = c("year", "net_debt", "debt_revenue", "debt_gsp"),
  skip = 1
)

state_accounts <- read_abs("5220.0", tables = 1)

sa_gsp <- state_accounts %>%
  filter(series == "South Australia ;  Gross state product: Current prices ;") %>%
  mutate(year = lubridate::year(date)) %>%
  select(
    gsp = value,
    year
  )

south_australia_net_debt <- left_join(sand, sa_gsp) %>%
  mutate(debt_gsp = 100 * net_debt / gsp)

usethis::use_data(south_australia_net_debt, overwrite = TRUE, compress = "xz")
