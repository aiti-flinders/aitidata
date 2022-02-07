## code to prepare `retail_trade` dataset goes here
library(readabs)
library(dplyr)
library(lubridate)

# Table 12 releases 1 week later than the other tables. 

abs_test <- try(read_abs(cat_no = "8501.0", tables = "12", retain_files = FALSE), silent = TRUE)

if (is.data.frame(abs_test)) {
  
  #If the download worked, we can proceed as usual
  
  if (max(abs_test$date) <= max(aitidata::retail_trade$date)) {
    
    message("Skipping `retail_trade.rda`: appears to be up-to-date")
    
  } else {
    
    message("Updating `retail-trade-australia`")
    
    retail_trade <- read_abs("8501.0", tables = 12) %>%
      separate_series(column_names = c("indicator", "state", "industry_group")) %>%
      mutate(year = year(date),
             month = month(date, abbr = FALSE, label = TRUE),
             state = case_when(
               state == "Total (State)" ~ "Australia",
               TRUE ~ state
             )) %>%
      select(date, year, month, state, indicator, industry_group, series_type, value, unit)
    
    usethis::use_data(retail_trade, overwrite = TRUE, compress = "xz")
  } 
} 


