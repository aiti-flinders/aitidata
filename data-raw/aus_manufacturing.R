## code to prepare `aus_manufacturing` dataset goes here


abs_file <- aitidata::download_data_cube(catalogue_string = "australian-industry",
                                             cube = "Manufacturing industry", 
                                             path = "data-raw")
#fpath <- gsub("[^\\/]*$", "", fpath)
years <- readxl::read_xls(abs_file, sheet = "Table_1", skip = 4, n_max = 0) %>%
  dplyr::select(1, 5, 9) %>%
  colnames()

if (max(years) == max(aitidata::aus_manufacturing$year)) {
  message("`aus_manufacturing.rda` appears to be up to date: skipping update")
  file.remove(abs_file)
} else {
  
  years <- readxl::read_xls(abs_file, sheet = "Table_1", skip = 4, n_max = 0) %>%
    dplyr::select(1, 5, 9) %>%
    colnames()
  
  aus_manufacturing <- readxl::read_xls(abs_file, 
                                sheet = "Table_1", 
                                skip = 7, 
                                col_names = c("industry", "employment_1", "wages_1", "income_1", "iva_1",
                                              "employment_2", "wages_2", "income_2", "iva_2",
                                              "employment_3", "wages_3", "income_3", "iva_3")) %>%
    tidyr::pivot_longer(cols = 2:length(.), names_to = "indicator", values_to = "value") %>%
    dplyr::mutate(year = dplyr::case_when(
      stringr::str_detect(indicator, "_1") ~ years[1],
      stringr::str_detect(indicator, "_2") ~ years[2],
      stringr::str_detect(indicator, "_3") ~ years[3]),
      industry_code = stringr::str_extract(industry, "\\d{2,4}"),
      industry = trimws(stringr::str_replace(industry, "\\d{2,4}", "")),
      indicator = stringr::str_remove_all(indicator, "_[1-3]"))
  
  file.remove(abs_file)
}

usethis::use_data(aus_manufacturing, overwrite = TRUE)

