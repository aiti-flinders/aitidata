## code to prepare `cabee_sa2` dataset goes here
library(readxl)
library(stringr)
library(tidyr)
library(dplyr)
library(lubridate)
library(zoo)

abs_test <- aitidata::download_data_cube(catalogue_string = "counts-australian-businesses-including-entries-and-exits", 
                               cube = "Data cube 1: Tables 1-20 of counts of Australian businesses, including entries and exits",
                               path = "data-raw")

current_date <- readxl::read_excel(abs_test,
                                   sheet = 1,
                                   range = "A2",
                                   col_names = "release") %>%
  dplyr::mutate(release = str_sub(release, start = -9L, end = -1L),
         release = as.Date(paste0(release, "-01"), format = "%B %Y-%d")) %>%
  pull(release)

if (current_date <= max(aitidata::cabee_sa2$date)) {
  message("Skipping `cabee_sa2.rda`: appears to be up-to-date")
  file.remove(abs_test)
} else {
  
  abs_file <- download_data_cube(catalogue_string = "counts-australian-businesses-including-entries-and-exits", 
                                 cube = "Data cube 8: Businesses by industry division by Statistical Area Level 2 by employment size ranges",
                                 path = "data-raw")
  
  cabee_dates <- na.omit(as_date(zoo::as.yearmon(excel_sheets(abs_file))))
  cabee_sheets <- paste(month(cabee_dates, label = T, abbr = F), year(cabee_dates))
  cabee_sheets <-  c(paste(cabee_sheets[1:4], c("a", "b")), cabee_sheets[5])
  cabee_sheets <- cabee_sheets[str_detect(cabee_sheets, "b", negate = TRUE)]
  
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
    cabee_year <- read_xls(abs_file,
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
                             "total"
                           )) %>%
      filter(!is.na(sa2_main_2016)) %>%
      mutate(sa2_main_2016 = as.character(sa2_main_2016),
             date = as.Date(paste(str_remove_all(i, "a"), "01"), format = "%B %Y %d"))
    
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
           indicator, value)
  
  file.remove(abs_file)
  usethis::use_data(cabee_sa2, compress = "xz", overwrite = TRUE)
}
