## code to prepare `anzsic` dataset goes here
library(tidyverse)
library(readxl)

anzsic <- read_excel("data-raw/anzsic_2006.xlsx",
                     sheet = "Classes",
                     range = "B7:F853",
                     col_names = c(
                       "code",
                       "division",
                       "subdivision",
                       "group",
                       "class"
                     ))
#Fill NA across:
anzsic_code <- t(apply(anzsic, 1, function(x) `length<-`(na.omit(x), length(x)))) %>%
  as_tibble(.name_repair = 'universal') %>%
  select("code" = 1, "name" = 2)

anzsic <- anzsic %>%
  mutate(code = anzsic_code$code,
         division = ifelse(division == code, NA, division),
         subdivision = ifelse(subdivision == code, NA, subdivision),
         group = ifelse(group == code, NA, group)) %>%
  fill(division, subdivision, group)  %>%
  filter(!is.na(class)) %>%
  select(-code)

usethis::use_data(anzsic, overwrite = TRUE, compress = 'xz')

