## code to prepare `mobility_facebook` dataset goes here
library(readr)
library(dplyr)
library(lubridate)
library(tidyr)
library(rhdx)
library(strayr)
library(purrr)

set_rhdx_config(hdx_site = "prod")



download_facebook <- function() {
  
 search_datasets("Movement Range Maps") %>%
    pluck(1) %>%
    get_resource(2) %>%
    download_resource(folder = "data-raw", filename = "facebook.zip", force = TRUE)
}

read_facebook <- function() {
  
  fname <- unzip("data-raw/facebook.zip", list = TRUE) %>%
    filter(Length == max(.$Length)) %>%
    pull(Name)
  
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
  

lga_to_state <- read_absmap(name = "lga2016") %>%
  mutate(lga_name_2016 = gsub(pattern = " \\(.+\\)",
                              x = lga_name_2016,
                              replacement = "")) %>%
  as_tibble() %>%
  select(lga_name_2016, state_name_2016)

mobility_facebook <- bind_rows(aitidata:::mobility_facebook_2020,
                               fb_mobility) %>%
  left_join(lga_to_state, by = c("state" = "lga_name_2016"))

file.remove("data-raw/facebook.zip")
  
usethis::use_data(mobility_facebook, compress = "xz", overwrite = TRUE)
