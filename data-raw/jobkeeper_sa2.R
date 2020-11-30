## code to prepare `jobkeeper_sa2` dataset goes here

library(sf)
library(absmapsdata)
library(tidyverse)
library(xml2)
library(rvest)
library(readxl)

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

  unlink("data-raw/absmaps", recursive = T)
} else {
  mesh_aus <- readRDS("data-raw/mesh_aus2016.rds")
}

if (!file.exists("data-raw/postal_areas.zip")) {
  postal_areas <- download.file("https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055003_poa_2016_aust_csv.zip&1270.0.55.003&Data%20Cubes&BCC18002983CD965CA25802C00142BA4&0&July%202016&13.09.2016&Previous",
    destfile = "data-raw/postal_areas.zip",
    mode = "wb"
  )
} else {
  postal_areas <- read_csv("data-raw/postal_areas.zip",
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

if (!as.Date(file.info("data/jobkeeper_sa2.rda")$mtime) >= jobkeeper_date | !file.exists("data/jobkeeper_sa2.rda")) {
  message("Updating jobkeeper_sa2 dataset...")

  download.file(paste0("https://treasury.gov.au/", jobkeeper_data_url), dest = "data-raw/jobkeeper_postal.xlsx", mode = "wb")

  (nms <- names(read_excel("data-raw/jobkeeper_postal.xlsx", sheet = 2, skip = 1, n_max = 0)))

  (ct <- ifelse(grepl("Postcode", nms), "text", "numeric"))

  job_keeper_postal <- read_xlsx(
    path = "data-raw/jobkeeper_postal.xlsx",
    sheet = 2,
    skip = 1,
    col_types = ct
  ) %>%
    janitor::clean_names() %>%
    mutate(postcode = str_pad(postcode, 4, "left", "0"))

  file.remove("data-raw/jobkeeper_postal.xlsx")


  business_sa2 <- daitir::cabee_sa2 %>%
    filter(indicator == "total") %>%
    mutate(sa2_main_2016 = as.character(sa2_main_2016)) %>%
    filter(date == max(.$date)) %>%
    select(-date,
           -indicator,
           total_businesses = value)

  jobkeeper_sa2 <- left_join(postal_areas, mesh_aus, by = c("MB_CODE_2016" = "mb_code_2016")) %>%
    left_join(job_keeper_postal, by = c("POA_CODE_2016" = "postcode")) %>%
    left_join(business_sa2) %>%
    group_by(POA_CODE_2016) %>%
    mutate(share = total_businesses / sum(total_businesses, na.rm = T)) %>%
    ungroup() %>%
    mutate(
      weighted_april_application_count = april_application_count * share,
      weighted_may_application_count = may_application_count * share,
      weighted_june_application_count = june_application_count * share,
      weighted_july_application_count = july_application_count * share,
      weighted_august_application_count = august_application_count * share) %>%
    group_by(sa2_main_2016) %>%
    summarise(
      apps_april = sum(weighted_april_application_count, na.rm = T),
      apps_may = sum(weighted_may_application_count, na.rm = T),
      apps_june = sum(weighted_june_application_count, na.rm = T),
      apps_july = sum(weighted_july_application_count, na.rm = T),
      apps_august = sum(weighted_august_application_count, na.rm = T)
    ) %>%
    pivot_longer(
      cols = c(2:length(.)),
      names_to = "date",
      values_to = "jobkeeper_applications"
    ) %>%
    mutate(
      date = case_when(
        date == "apps_april" ~ as.Date("2020-04-01"),
        date == "apps_may" ~ as.Date("2020-05-01"),
        date == "apps_june" ~ as.Date("2020-06-01"),
        date == "apps_july" ~ as.Date("2020-07-01"),
        date == "apps_august" ~ as.Date("2020-08-01")
      ),
      jobkeeper_applications = ceiling(jobkeeper_applications)
    ) %>%
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
    pivot_wider(names_from = indicator, values_from = value) %>% 
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
  
} else {
  message("jobkeeper_sa2 data is already up to date")
}
