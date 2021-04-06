## code to prepare `jobkeeper_sa2` dataset goes here

library(sf)
library(absmaps)
library(absmapsdata)
library(readr)
library(stringr)
library(tidyr)
library(dplyr)
library(xml2)
library(rvest)
library(readxl)
library(aitidata)

if (!file.exists(here::here("data-raw/mesh_aus2016.rds"))) {
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

  unlink("data-raw/absmaps", recursive = T)
} else {
  mesh_aus <- readRDS("data-raw/mesh_aus2016.rds")
}

if (!file.exists("data-raw/1270055003_poa_2016_aust_csv.zip")) {
  postal_areas <- download_file("https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055003_poa_2016_aust_csv.zip&1270.0.55.003&Data%20Cubes&BCC18002983CD965CA25802C00142BA4&0&July%202016&13.09.2016&Previous",
                                path = "data-raw"
  )
  
  postal_areas <- read_csv(postal_areas, 
                           col_types = cols(
                             MB_CODE_2016 = col_character(),
                             POA_CODE_2016 = col_character(),
                             POA_NAME_2016 = col_character(),
                             AREA_ALBERS_SQKM = col_double()
                           ))
  
} else {
  postal_areas <- read_csv("data-raw/1270055003_poa_2016_aust_csv.zip",
    col_types = cols(
      MB_CODE_2016 = col_character(),
      POA_CODE_2016 = col_character(),
      POA_NAME_2016 = col_character(),
      AREA_ALBERS_SQKM = col_double()
    )
  )
}

jobkeeper_url <- "https://treasury.gov.au/coronavirus/jobkeeper/data"

release_page <- read_html(jobkeeper_url)

jobkeeper_data_url <- release_page %>%
  html_nodes(xpath = '//*[@id="block-mainpagecontent-2"]/div/article/div/div/table/tbody/tr/td[2]/p') %>%
  html_children() %>%
  html_attr("href") %>%
  .[1]

jobkeeper_date <- release_page %>%
  html_text() %>%
  str_extract("(?<=\\: ).*") %>%
  as.Date(format = "%d %B %Y")

#Many conditions for updating this dataset:
#1. New meshblock files
#2. New jobkeeper data
#3. New business count data

if (!as.Date(file.info("data/jobkeeper_sa2.rda")$mtime) >= jobkeeper_date | !file.exists("data/jobkeeper_sa2.rda")) {
  message("Updating jobkeeper_sa2 dataset...")

  download.file(paste0("https://treasury.gov.au/", jobkeeper_data_url), dest = "data-raw/jobkeeper_postal.xlsx", mode = "wb")

  nms <- names(read_excel("data-raw/jobkeeper_postal.xlsx", sheet = 2, skip = 1, n_max = 0))

  ct <- ifelse(grepl("Postcode", nms), "text", "numeric")

  jobkeeper_postal <- read_xlsx(
    path = "data-raw/jobkeeper_postal.xlsx",
    sheet = "First Phase",
    skip = 1,
    col_types = ct
  ) %>%
    janitor::clean_names() %>%
    mutate(postcode = str_pad(postcode, 4, "left", "0")) %>%
    rename_with(.cols = -postcode, ~paste0("apps_",str_extract(., ".+?(?=_)")))
  
  nms <- names(read_excel("data-raw/jobkeeper_postal.xlsx", sheet = 3, skip = 1, n_max = 0))
  
  ct <- ifelse(grepl("Postcode", nms), "text", "numeric")
  
  jobkeeper_extension_first <- read_xlsx(
    path = "data-raw/jobkeeper_postal.xlsx",
    sheet = "Extension - First Quarter",
    skip = 1,
    col_types = ct
  ) %>%
    janitor::clean_names() %>%
    mutate(postcode = str_pad(postcode, 4, "left", "0")) %>%
    rename_with(.cols = -postcode, ~paste0("apps_", str_extract(., ".+?(?=_)")))
  
  nms <- names(read_excel("data-raw/jobkeeper_postal.xlsx", sheet = 4, skip = 1, n_max = 0))
  
  ct <- ifelse(grepl("Postcode", nms), "text", "numeric")
  
  jobkeeper_extension_second <- read_xlsx(
    path = "data-raw/jobkeeper_postal.xlsx",
    sheet = "Extension - Second Quarter",
    skip = 1,
    col_types = ct
  ) %>%
    janitor::clean_names() %>%
    mutate(postcode = str_pad(postcode, 4, "left", "0")) %>%
    rename_with(.cols = -postcode, ~paste0("apps_", str_extract(., ".+?(?=_)")))
  
  jobkeeper_all <- left_join(jobkeeper_postal, jobkeeper_extension_first) %>%
    left_join(jobkeeper_extension_second)
    


  business_sa2 <- aitidata::cabee_sa2 %>%
    filter(indicator == "total") %>%
    group_by(date, sa2_main_2016, sa2_name_2016) %>%
    summarise(total_businesses = sum(value, na.rm = T), .groups = "drop") %>%
    ungroup() %>%
    mutate(sa2_main_2016 = as.character(sa2_main_2016)) %>%
    filter(date == max(.$date)) %>%
    select(-date, -sa2_name_2016)

  jobkeeper_sa2 <- left_join(postal_areas, mesh_aus, by = c("MB_CODE_2016" = "mb_code_2016")) %>%
    left_join(jobkeeper_all, by = c("POA_CODE_2016" = "postcode")) %>%
    left_join(business_sa2) %>%
    group_by(POA_CODE_2016) %>%
    mutate(share = total_businesses / sum(total_businesses, na.rm = T)) %>%
    ungroup() %>%
    mutate(across(contains("apps_"), .fns = ~. * share, .names = "{.col}")) %>%
    group_by(sa2_main_2016) %>%
    summarise(across(contains("apps_"), .fns = ~sum(., na.rm = TRUE), .names = "{.col}")) %>%
    pivot_longer(
      cols = c(2:length(.)),
      names_to = "date",
      values_to = "jobkeeper_applications"
    ) %>%
    mutate(date = str_remove(date, "apps_"),
           date = as.Date(paste0("2020-", match(date, tolower(month.name)), "-01")),
           jobkeeper_applications = ceiling(jobkeeper_applications)) %>%
    left_join(business_sa2) %>%
    mutate(jobkeeper_proportion = ifelse(total_businesses != 0, 100 * jobkeeper_applications / total_businesses, 0)) %>%
    filter(
      !is.na(sa2_main_2016),
      !sa2_main_2016 %in% c(
        "197979799",
        "297979799",
        "397979799",
        "497979799",
        "597979799",
        "697979799",
        "797979799",
        "897979799"
      )
    ) %>%
    pivot_longer(
      cols = c(-sa2_main_2016, -date),
      names_to = "indicator",
      values_to = "value"
    ) %>%
    mutate(across(indicator, ~ str_to_sentence(str_replace_all(., "_", " "))))
  
  jobkeeper_state <- jobkeeper_sa2 %>% 
    ungroup() %>% 
    pivot_wider(id_cols = c(sa2_main_2016, date), names_from = indicator, values_from = value) %>% 
    left_join(absmapsdata::sa22016) %>% 
    group_by(state_name_2016, date) %>% 
    summarise(across(c(`Jobkeeper applications`, `Total businesses`), sum)) %>%
    ungroup() %>%
    pivot_longer(cols = c(`Jobkeeper applications`, `Total businesses`), names_to = "indicator", values_to = "value") %>%
    pivot_wider(names_from = state_name_2016, values_from = value) %>%
    rowwise() %>% 
    mutate(Australia = `Australian Capital Territory` + `New South Wales` + `Northern Territory` + Queensland + `South Australia` + Tasmania + Victoria + `Western Australia`) %>%
    ungroup() %>% 
    pivot_longer(cols = c(3:11), names_to = "state", values_to = "value") %>%
    pivot_wider(names_from = indicator, values_from = value) %>%
    mutate("Jobkeeper proportion" = 100*`Jobkeeper applications`/`Total businesses`) %>%
    pivot_longer(cols = c(3:5), names_to = "indicator", values_to = "value") %>%
    mutate(unit = case_when(indicator == "Jobkeeper proportion" ~ "Percent",
                            TRUE ~ "000"),
           series_type = "Original",
           month = lubridate::month(date, abbr = FALSE, label = TRUE),
           year = lubridate::year(date)) 


  usethis::use_data(jobkeeper_state, overwrite = TRUE, compress = "xz")
  usethis::use_data(jobkeeper_sa2, overwrite = TRUE, compress = "xz")
  
  file.remove("data-raw/jobkeeper_postal.xlsx")
  
} else {
  message("jobkeeper_sa2 data is already up to date")
}
