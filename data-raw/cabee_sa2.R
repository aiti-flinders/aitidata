## code to prepare `cabee_sa2` dataset goes here
library(readxl)
library(readabs)
library(tidyverse)
library(lubridate)
library(zoo)

if (!abs_data_up_to_date("8165.0") | !file.exists("data/cabee_sa2.rda")) {
  download_abs_data_cube("8165.0", cube = "816508", path = "data-raw")
  file.rename("data-raw/816508.xls", "data-raw/cabee_sa2.xls")
  
  cabee_dates <- na.omit(as_date(zoo::as.yearmon(excel_sheets("data-raw/cabee_sa2.xls"))))
  cabee_sheets <- paste(month(cabee_dates, label = T, abbr = F), year(cabee_dates))
  
  cabee_sa2 <- tribble(
    ~"date",
    ~"industry_code", 
    ~"industry_label",
    ~"sa2_main_2016",
    ~"sa2_name_2016",
    ~"non_employing",
    ~"employing_1_4",
    ~"employing_5_19",
    ~"employing_20_199",
    ~"employing_200_plus",
    ~"total"
    )
  
  for (i in cabee_sheets) {
    
    cabee_year <- read_xls("data-raw/cabee_sa2.xls", 
                           sheet = i, 
                           skip = 7,
                           col_names = c(
                             "industry_code",
                             "industry_label",
                             "sa2_main_2016",
                             "sa2_name_2016",
                             "non_employing",
                             "employing_1_4",
                             "employing_5_19",
                             "employing_20_199",
                             "employing_200_plus",
                             "total")
    ) %>%
      filter(!is.na(sa2_main_2016)) %>%
      mutate(sa2_main_2016 = as.character(sa2_main_2016),
             date = as.Date(paste(i, "01"), "%B %Y %d")) 
    
    cabee_sa2 <- bind_rows(cabee_year, cabee_sa2)
    
  }
  
  cabee_sa2 <- cabee_sa2 %>%
    pivot_longer(cols = c(-industry_code, -industry_label, -sa2_main_2016, -sa2_name_2016, -date),
                   names_to = "indicator",
                   values_to = "value") %>%
      select(date,
             division = industry_label,
             sa2_main_2016,
             sa2_name_2016,
             indicator,
             value)
  
  file.remove("data-raw/cabee_sa2.xls")
  usethis::use_data(cabee_sa2, compress = "xz", overwrite = TRUE)
}


