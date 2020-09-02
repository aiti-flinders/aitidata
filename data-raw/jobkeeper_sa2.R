## code to prepare `jobkeeper_sa2` dataset goes here

library(sf)
library(absmaps)
library(tidyverse)

if (!file.exists("data-raw/mesh_aus2016.rds")) {
  download_absmaps("mesh_sa", saveDirectory = "data-raw")
  download_absmaps("mesh_act", saveDirectory = "data-raw")
  download_absmaps("mesh_vic", saveDirectory = "data-raw")
  download_absmaps("mesh_nsw", saveDirectory = "data-raw")
  download_absmaps("mesh_qld", saveDirectory = "data-raw")
  download_absmaps("mesh_tas", saveDirectory = "data-raw")
  download_absmaps("mesh_nt", saveDirectory = "data-raw")
  download_absmaps("mesh_wa", saveDirectory = "data-raw")
  
  mesh_act <- read_rds("data-raw/absmaps/mesh_act2016/mesh_act2016.rds")
  mesh_nsw <- read_rds("data-raw/absmaps/mesh_nsw2016/mesh_nsw2016.rds")
  mesh_nt <- read_rds("data-raw/absmaps/mesh_nt2016/mesh_nt2016.rds")
  mesh_qld <- read_rds("data-raw/absmaps/mesh_qld2016/mesh_qld2016.rds")
  mesh_sa <- read_rds("data-raw/absmaps/mesh_sa2016/mesh_sa2016.rds")
  mesh_tas <- read_rds("data-raw/absmaps/mesh_tas2016/mesh_tas2016.rds")
  mesh_vic <- read_rds("data-raw/absmaps/mesh_vic2016/mesh_vic2016.rds") 
  mesh_wa <- read_rds("data-raw/absmaps/mesh_wa2016/mesh_wa2016.rds")
  
  
  mesh_aus <- bind_rows(
    mesh_act,
    mesh_nsw,
    mesh_nt,
    mesh_qld,
    mesh_sa,
    mesh_tas,
    mesh_vic,
    mesh_wa
  )
  
  saveRDS(mesh_aus, file = "data-raw/mesh_aus2016.rds")
  

}

mesh_aus <- readRDS("data-raw/mesh_aus2016.rds")

if (!file.exists("data-raw/postal_areas.zip")) {
  postal_areas <- download.file("https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055003_poa_2016_aust_csv.zip&1270.0.55.003&Data%20Cubes&BCC18002983CD965CA25802C00142BA4&0&July%202016&13.09.2016&Previous",
                              destfile = "data-raw/postal_areas.zip",
                              mode = "wb")
}

postal_areas <- read_csv("data-raw/postal_areas.zip", 
                         col_types = cols(
                           MB_CODE_2016 = col_character(),
                           POA_CODE_2016 = col_character(),
                           POA_NAME_2016 = col_character(),
                           AREA_ALBERS_SQKM = col_double()
                         ))

job_keeper_postal <- readxl::read_xlsx("data-raw/JobKeeper-data-20200731.xlsx", skip = 1,
                                       col_types = c("text", "numeric", "numeric")) %>%
  janitor::clean_names() %>%
  mutate(postcode = str_pad(postcode, 4, "left", "0"))

business_sa2 <- readxl::read_xls("data-raw/cabee_sa2.xls", sheet = "June 2019", skip = 7,
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
                                   "total")) %>%
  filter(!is.na(sa2_main_2016)) %>%
  group_by(sa2_main_2016) %>%
  summarise(total_businesses = sum(total, na.rm = T)) %>%
  mutate(sa2_main_2016 = as.character(sa2_main_2016)) 

jobkeeper_sa2 <- left_join(postal_areas, mesh_aus, by = c("MB_CODE_2016" = "mb_code_2016")) %>%
  left_join(job_keeper_postal, by = c("POA_CODE_2016" = "postcode")) %>% 
  left_join(business_sa2) %>% 
  group_by(POA_CODE_2016) %>% 
  mutate(share = total_businesses/sum(total_businesses, na.rm = T)) %>% 
  ungroup() %>% 
  mutate(weighted_may_application_count = may_application_count * share,
         weighted_april_application_count = april_application_count * share) %>% 
  group_by(sa2_main_2016) %>%
  summarise(apps_april = sum(weighted_april_application_count, na.rm = T),
            apps_may = sum(weighted_may_application_count, na.rm = T)) %>%
  pivot_longer(cols = c(2:3), 
               names_to = "date",
               values_to = "jobkeeper_apps") %>%
  mutate(date = case_when(
    date == "apps_april" ~ as.Date("2020-04-01"),
    date == "apps_may" ~ as.Date("2020-05-01")
  ),
  jobkeeper_apps = ceiling(jobkeeper_apps)) %>%
  left_join(business_sa2) %>%
  mutate(jobkeeper_proportion = ifelse(total_businesses != 0, 100*jobkeeper_apps/total_businesses, 0)) %>%
  filter(!is.na(sa2_main_2016),
         !sa2_main_2016 %in% c("197979799", 
                               "297979799",
                               "397979799",
                               "497979799", 
                               "597979799",
                               "697979799",
                               "797979799",
                               "897979799"))

usethis::use_data(jobkeeper_sa2, overwrite = TRUE, compress = "xz")
