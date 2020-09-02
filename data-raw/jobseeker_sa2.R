## code to prepare `jobseeker_sa2` dataset goes here

library(tidyverse)
library(readxl)
library(absmapsdata)

files <- list.files("data-raw/dss")

jobseeker_sa2 <- tibble(
  "sa2" = numeric(),
  "sa2_name" = character(),
  "jobseeker_payment" = numeric(),
  "youth_allowance_other" = numeric()
)

for (i in 1:length(files)) {
  
  dss_month <- read_excel(paste0("data-raw/dss/",files[i]),
                          sheet = "Table 4 - By SA2",
                          skip = 7,
                          n_max = 2292,
                          col_names = c("sa2", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
                          col_types =  c("numeric", "text", "numeric", "numeric")) %>%
    mutate(date = as.Date(paste0(str_sub(files[i], 66, -6), "-01"), "%b-%Y-%d")) %>%
    replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5))
  
  jobseeker_sa2 <- bind_rows(jobseeker_sa2, dss_month)
  
}


jobseeker_sa2 <- jobseeker_sa2 %>% 
  left_join(sa22016, by = c("sa2_name" = "sa2_name_2016")) %>%
  select(sa2_main_2016, jobseeker_payment, youth_allowance_other, date)

usethis::use_data(jobseeker_sa2, overwrite = TRUE)
