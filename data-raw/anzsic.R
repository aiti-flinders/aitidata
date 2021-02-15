## code to prepare `anzsic` dataset goes here
library(dplyr)
library(tidyr)
library(readxl)



abs_file <- download_file(
  file_download_url = "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1292.0.55.002_anzsic%202006%20-%20codes%20and%20titles.xls&1292.0.55.002&Data%20Cubes&A8CF900440465BDBCA257122001ABA2D&0&2006&28.02.2006&Latest",
  path = "data-raw")

anzsic <- read_excel(abs_file,  
                     sheet = "Classes", 
                     range = "B7:F853", 
                     col_names = c("code",
                                   "division",
                                   "subdivision",
                                   "group",
                                   "class")
)
# Fill NA across:
anzsic_code <- t(apply(anzsic, 1, function(x) `length<-`(na.omit(x), length(x)))) %>%
  as_tibble(.name_repair = "universal") %>%
  select("code" = 1, "name" = 2)

anzsic <- anzsic %>%
  mutate(
    code = anzsic_code$code,
    division = ifelse(division == code, NA, division),
    subdivision = ifelse(subdivision == code, NA, subdivision),
    group = ifelse(group == code, NA, group)
  ) %>%
  fill(division, subdivision, group) %>%
  filter(!is.na(class)) %>%
  select(-code)

file.remove(abs_file)

usethis::use_data(anzsic, overwrite = TRUE, compress = "xz")
