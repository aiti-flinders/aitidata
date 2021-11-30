## code to prepare `mobility_facebook` dataset goes here
library(readr)
library(dplyr)
library(lubridate)
library(tidyr)

facebook_mobility <- function(year = c("2020", "2021")) {
  
  if (is.numeric(year)) {
    year <- as.character(year)
  }
  
  url <- switch(year,
                "2020" = "https://data.humdata.org/dataset/c3429f0e-651b-4788-bb2f-4adbf222c90e/resource/3d77ce5c-ab6d-4864-b8a2-c8bafffac4f3/download/movement-range-data-2020-03-01-2020-12-31.zip",
                "2021" = "https://data.humdata.org/dataset/c3429f0e-651b-4788-bb2f-4adbf222c90e/resource/55a51014-0d27-49ae-bf92-c82a570c2c6c/download/movement-range-data-2021-11-25.zip")
 

  download.file(url, destfile = "data-raw/fb_mobility.zip")
  
  fname <- switch(year,
                  "2020" = unzip("data-raw/fb_mobility.zip", list = TRUE)$Name[1],
                  "2021" = unzip("data-raw/fb_mobility.zip", list = TRUE)$Name[2])
  
  fb_mobility <- read_tsv(unz("data-raw/fb_mobility.zip", fname)) %>%
    filter(country == "AUS") %>%
    select(state = polygon_name,
           date = ds,
           single_location = all_day_ratio_single_tile_users) %>%
    pivot_longer(cols = single_location,
                 names_to = "metric",
                 values_to = "trend") %>%
    mutate(date = date(date),
           weekday = wday(date))
  
  file.remove("data-raw/fb_mobility.zip")
  
  return(fb_mobility)
}

mobility_facebook <- bind_rows(aitidata:::mobility_facebook_2020,
                               facebook_mobility("2021"))
  
usethis::use_data(mobility_facebook, compress = "xz", overwrite = TRUE)
