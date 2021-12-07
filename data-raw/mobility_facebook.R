## code to prepare `mobility_facebook` dataset goes here
library(readr)
library(dplyr)
library(lubridate)
library(tidyr)
library(rhdx)
library(purrr)

set_rhdx_config(hdx_site = "prod")



download_facebook <- function() {
  
 search_datasets("Movement Range Maps") %>%
    pluck(1) %>%
    get_resource(2) %>%
    download_resource(folder = "data-raw", filename = "facebook.zip", force = TRUE)
}

read_facebook <- function() {
  
  fname <- unzip("data-raw/facebook.zip", list = TRUE)$Name[2]
  
  read_tsv(unz("data-raw/facebook.zip", fname)) 
}

download_facebook() 

fb_mobility <-   read_facebook() %>%
  filter(country == "AUS") %>%
    select(state = polygon_name,
           date = ds,
           single_location = all_day_ratio_single_tile_users) %>%
    pivot_longer(cols = single_location,
                 names_to = "metric",
                 values_to = "trend") %>%
    mutate(date = date(date),
           weekday = wday(date))
  



mobility_facebook <- bind_rows(aitidata:::mobility_facebook_2020,
                               fb_mobility)
  
usethis::use_data(mobility_facebook, compress = "xz", overwrite = TRUE)
