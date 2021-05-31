## code to prepare `small_area_labour_market` dataset goes here
library(sf)

download.file("https://lmip.gov.au/PortalFile.axd?FieldID=3193962&.csv",
                           destfile = "data-raw/salm_test.csv",
                           mode = "wb")
current_date <- readr::read_csv("data-raw/salm_test.csv",
                      skip = 1) %>%
  dplyr::select(dplyr::last_col()) %>%
  colnames() %>%
  paste0(., "-01") %>%
  as.Date(format = "%b-%y-%d")

if (current_date <= max(aitidata::small_area_labour_market$date)) {
  message("Skipping `small_area_labour_market.rda`: appears to be up-to-date")
  file.remove("data-raw/salm_test.csv")
} else {
  download.file("https://lmip.gov.au/PortalFile.axd?FieldID=3193958&.csv",
                destfile = "data-raw/salm_sa2.csv",
                mode = "wb"
  )
  
  raw <- readr::read_csv("data-raw/salm_sa2.csv", skip = 1)
  
  all_sa2 <- data.frame(absmapsdata::sa22016) %>%
    dplyr::select(sa2_name_2016, sa2_main_2016, state_name_2016)
  
  small_area_labour_market <- raw %>%
    dplyr::mutate(dplyr::across(where(is.numeric), as.character)) %>%
    tidyr::pivot_longer(cols = 4:length(.),
                        names_to = "date",
                        values_to = "value") %>%
    dplyr::rename(indicator = `Data Item`,
                  sa2_name_2016 = `Statistical Area Level 2 (SA2) (2016 ASGS)`,
                  sa2_main_2016 = `SA2 Code (2016 ASGS)`) %>%
    dplyr::mutate(value = as.numeric(gsub(",", "", value)),
                  date = as.Date(paste0(date, "-01"), format = "%b-%y-%d")) %>%
    dplyr::right_join(all_sa2) %>%
    tidyr::complete(indicator, tidyr::nesting(sa2_name_2016, sa2_main_2016), date) %>%
    dplyr::filter(!is.na(date), !is.na(indicator))

usethis::use_data(small_area_labour_market, overwrite = TRUE, compress = "xz")
}
