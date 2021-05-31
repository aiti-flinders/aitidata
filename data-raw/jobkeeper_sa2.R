## code to prepare `jobkeeper_sa2` dataset goes here
devtools::load_all(".")


if (!file.exists(("data-raw/mesh_aus2016.rda"))) {
  
  file_struct <- data.frame(stringsAsFactors = FALSE,
                            state = c("nsw","vic","qld","sa","wa","tas","nt","act","ot"),
                            url = c("https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_nsw_csv.zip&1270.0.55.001&Data%20Cubes&1FC672E70A77D52FCA257FED0013A0F7&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_vic_csv.zip&1270.0.55.001&Data%20Cubes&F1EA82ECA7A762BCCA257FED0013A253&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_qld_csv.zip&1270.0.55.001&Data%20Cubes&A6A81C7C2CE74FAACA257FED0013A344&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_sa_csv.zip&1270.0.55.001&Data%20Cubes&5763C01CA9A3E566CA257FED0013A38D&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_wa_csv.zip&1270.0.55.001&Data%20Cubes&6C293909851DCBFFCA257FED0013A3BF&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_tas_csv.zip&1270.0.55.001&Data%20Cubes&A9B01B4DACD0BFEFCA257FED0013A3FC&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_nt_csv.zip&1270.0.55.001&Data%20Cubes&CA6464FAA0777F80CA257FED0013A429&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_act_csv.zip&1270.0.55.001&Data%20Cubes&10AFEFD3A73B902ECA257FED0013A455&0&July%202016&12.07.2016&Latest",
                                        "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_ot_csv.zip&1270.0.55.001&Data%20Cubes&DE3FEF9908F4CF9BCA257FED0013A48F&0&July%202016&12.07.2016&Latest"))
  dir.create("data-raw/maps")
  
  purrr::map2(.x = file_struct$state, 
              .y = file_struct$url,
              .f = ~download.file(mode = "wb", url = .y, destfile = paste0("data-raw/maps/mesh_", .x, ".zip")))
  
  mesh_aus <- vroom::vroom(fs::dir_ls(path = "data-raw/maps"), 
                           col_types = readr::cols(
                             MB_CODE_2016 = readr::col_character(),
                             MB_CATEGORY_NAME_2016 = readr::col_character(),
                             SA1_MAINCODE_2016 = readr::col_character(),
                             SA1_7DIGITCODE_2016 = readr::col_character(),
                             SA2_MAINCODE_2016 = readr::col_character(),
                             SA2_5DIGITCODE_2016 = readr::col_character(),
                             SA2_NAME_2016 = readr::col_character(),
                             SA3_CODE_2016 = readr::col_character(),
                             SA3_NAME_2016 = readr::col_character(),
                             SA4_CODE_2016 = readr::col_character(),
                             SA4_NAME_2016 = readr::col_character(),
                             GCCSA_CODE_2016 = readr::col_character(),
                             GCCSA_NAME_2016 = readr::col_character(),
                             STATE_CODE_2016 = readr::col_character(),
                             STATE_NAME_2016 = readr::col_character(),
                             AREA_ALBERS_SQKM = readr::col_double()
                           ))
  
  save(mesh_aus, file = "data-raw/mesh_aus2016.rda", compress = "xz")

  unlink("data-raw/maps", recursive = TRUE)
} else {
  mesh_aus <- get(load("data-raw/mesh_aus2016.rda"))
}

if (!file.exists("data-raw/abs_poa_2016.zip")) {
  download.file(url = "https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055003_poa_2016_aust_csv.zip&1270.0.55.003&Data%20Cubes&BCC18002983CD965CA25802C00142BA4&0&July%202016&13.09.2016&Previous",
                destfile = "data-raw/abs_poa_2016.zip",
                mode = "wb")
  
  postal_areas <- readr::read_csv("data-raw/abs_poa_2016.zip",
                           col_types = readr::cols(
                             MB_CODE_2016 = readr::col_character(),
                             POA_CODE_2016 = readr::col_character(),
                             POA_NAME_2016 = readr::col_character(),
                             AREA_ALBERS_SQKM = readr::col_double()
                           ))
  
} else {
  postal_areas <- readr::read_csv("data-raw/abs_poa_2016.zip",
    col_types = readr::cols(
      MB_CODE_2016 = readr::col_character(),
      POA_CODE_2016 = readr::col_character(),
      POA_NAME_2016 = readr::col_character(),
      AREA_ALBERS_SQKM = readr::col_double()
    )
  )
}

jobkeeper_url <- "https://treasury.gov.au/coronavirus/jobkeeper/data"

release_page <- rvest::read_html(jobkeeper_url)

jobkeeper_data_url <- release_page %>%
  rvest::html_nodes(xpath = '//*[@id="block-mainpagecontent-2"]/div/article/div/div/table/tbody/tr/td[2]/p') %>%
  rvest::html_children() %>%
  rvest::html_attr("href") %>%
  .[1]

jobkeeper_date <- release_page %>%
  rvest::html_text() %>%
  stringr::str_extract("(?<=\\: ).*") %>%
  as.Date(format = "%d %B %Y")

#Many conditions for updating this dataset:
#1. New meshblock files
#2. New jobkeeper data
#3. New business count data

get_file_types <- function(file, sheet, skip, n_max) {
  nms <- names(readxl::read_excel(path = file, sheet = sheet, skip = skip, n_max = 0))
  nms <- tolower(nms)
  nms <- gsub(pattern = " ", x = tolower(nms), replacement = "_")
  
  ct <- ifelse(grepl("postcode", nms), "text", "numeric")
  
  ft <- list(nms = nms, ct = ct)

  return(ft)
  
}

read_jobkeeper <- function(file, sheet, ...) {
  ft <- get_file_types(file, sheet = sheet, skip = 1, n_max = 0)
  jobkeeper_postal <- readxl::read_xlsx(path = file, 
                                        sheet = sheet,
                                        skip = 2,
                                        col_types = ft$ct,
                                        col_names = ft$nms, 
                                        ...) %>%
    dplyr::mutate(postcode = stringr::str_pad(postcode, 4, "left", "0")) %>%
    dplyr::rename_with(.cols = -postcode, ~paste0("apps_", stringr::str_extract(.x, ".+?(?=_)")))
  
  return(jobkeeper_postal)
}


if (!as.Date(file.info("data/jobkeeper_sa2.rda")$mtime) >= jobkeeper_date | !file.exists("data/jobkeeper_sa2.rda")) {
  message("Updating jobkeeper_sa2 dataset...")

  download.file(paste0("https://treasury.gov.au/", jobkeeper_data_url), dest = "data-raw/jobkeeper_postal.xlsx", mode = "wb")
  
  jobkeeper_phase_1 <- read_jobkeeper("data-raw/jobkeeper_postal.xlsx", 
                                      sheet = 2)
  
  jobkeeper_phase_2 <- read_jobkeeper("data-raw/jobkeeper_postal.xlsx",
                                      sheet = 3)
  
  jobkeeper_phase_3 <- read_jobkeeper("data-raw/jobkeeper_postal.xlsx",
                                      sheet = 4,
                                      range = readxl::cell_limits(c(3, 1), c(NA, 3)))
  
  jobkeeper_all <- dplyr::left_join(jobkeeper_phase_1, jobkeeper_phase_2, by = "postcode") %>%
    dplyr::left_join(jobkeeper_phase_3, by = "postcode")



  business_sa2 <- aitidata::cabee_sa2 %>%
    dplyr::filter(indicator == "total") %>%
    dplyr::group_by(date, sa2_main_2016, sa2_name_2016) %>%
    dplyr::summarise(total_businesses = sum(value, na.rm = T), .groups = "drop") %>%
    dplyr::ungroup() %>%
    dplyr::filter(date == max(.$date)) %>%
    dplyr::select(-date, -sa2_name_2016)

  jobkeeper_sa2 <- dplyr::left_join(postal_areas, mesh_aus, by = "MB_CODE_2016") %>%
    dplyr::left_join(jobkeeper_all, by = c("POA_CODE_2016" = "postcode")) %>%
    dplyr::left_join(business_sa2, by = c("SA2_MAINCODE_2016" = "sa2_main_2016")) %>%
    dplyr::group_by(POA_CODE_2016) %>%
    dplyr::mutate(share = total_businesses / sum(total_businesses, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(dplyr::across(tidyr::contains("apps_"), .fns = ~. * share, .names = "{.col}")) %>%
    dplyr::group_by(SA2_MAINCODE_2016) %>%
    dplyr::summarise(dplyr::across(tidyr::contains("apps_"), .fns = ~sum(., na.rm = TRUE), .names = "{.col}")) %>%
    tidyr::pivot_longer(cols = 2:length(.),
                        names_to = "date",
                        values_to = "jobkeeper_applications") %>%
    dplyr::mutate(date = stringr::str_remove(date, "apps_"),
                  month = match(date, tolower(month.name)),
                  year = dplyr::case_when(month %in% c(1,2,3) ~ 2021,
                                   TRUE ~ 2020),
                  date = as.Date(paste(year, month,  "01", sep = "-")),
                  jobkeeper_applications = ceiling(jobkeeper_applications)) %>%
    dplyr::select(-year, -month) %>%
    dplyr::left_join(business_sa2, by = c("SA2_MAINCODE_2016" = "sa2_main_2016")) %>%
    dplyr::mutate(jobkeeper_proportion = ifelse(total_businesses != 0, 100 * jobkeeper_applications / total_businesses, 0)) %>%
    dplyr::filter(!is.na(SA2_MAINCODE_2016),
                  !SA2_MAINCODE_2016 %in% c("197979799",
                                        "297979799",
                                        "397979799",
                                        "497979799",
                                        "597979799",
                                        "697979799",
                                        "797979799",
                                        "897979799")) %>%
    tidyr::pivot_longer(cols = c(-SA2_MAINCODE_2016, -date),
                        names_to = "indicator",
                        values_to = "value") %>%
    dplyr::rename(sa2_main_2016 = SA2_MAINCODE_2016) %>%
    dplyr::mutate(dplyr::across(indicator, ~ stringr::str_to_sentence(stringr::str_replace_all(., "_", " "))),
                  unit = dplyr::case_when(indicator == "Jobkeeper proportion" ~ "Percent", TRUE ~ "000"),
                  series_type = "Original",
                  month = lubridate::month(date, abbr = FALSE, label = TRUE),
                  year = lubridate::year(date),
                  gender = "Persons",
                  age = "Total (age)")
  
  jobkeeper_state <- jobkeeper_sa2 %>% 
    tidyr::pivot_wider(id_cols = c(sa2_main_2016, date), 
                       names_from = indicator, 
                       values_from = value) %>% 
    dplyr::left_join(mesh_aus[c("SA2_MAINCODE_2016", "STATE_NAME_2016")], by = c("sa2_main_2016" = "SA2_MAINCODE_2016")) %>% 
    dplyr::group_by(STATE_NAME_2016, date) %>% 
    dplyr::summarise(dplyr::across(c(`Jobkeeper applications`, `Total businesses`), sum), .groups = "drop") %>%
    dplyr::ungroup() %>%
    dplyr::filter(STATE_NAME_2016 != "Other Territories") %>%
    tidyr::pivot_longer(cols = c(`Jobkeeper applications`, `Total businesses`), 
                        names_to = "indicator", 
                        values_to = "value") %>%
    tidyr::pivot_wider(names_from = STATE_NAME_2016, 
                       values_from = value) %>%
    dplyr::rowwise() %>% 
    dplyr::mutate(Australia = rowSums(dplyr::across(c(3:10)))) %>%
    dplyr::ungroup() %>% 
    tidyr::pivot_longer(cols = 3:11,
                        names_to = "state", 
                        values_to = "value") %>%
    tidyr::pivot_wider(names_from = indicator, 
                       values_from = value) %>%
    dplyr::mutate("Jobkeeper proportion" = 100*`Jobkeeper applications`/`Total businesses`) %>%
    tidyr::pivot_longer(cols = 3:5, 
                        names_to = "indicator", 
                        values_to = "value") %>%
    dplyr::mutate(unit = dplyr::case_when(indicator == "Jobkeeper proportion" ~ "Percent", TRUE ~ "000"),
                  series_type = "Original",
                  month = lubridate::month(date, abbr = FALSE, label = TRUE),
                  year = lubridate::year(date),
                  gender = "Persons",
                  age = "Total (age)")

  usethis::use_data(jobkeeper_state, overwrite = TRUE, compress = "xz")
  usethis::use_data(jobkeeper_sa2, overwrite = TRUE, compress = "xz")
  
  file.remove("data-raw/jobkeeper_postal.xlsx")
  
} else {
  message("jobkeeper_sa2 data is already up to date")
}
