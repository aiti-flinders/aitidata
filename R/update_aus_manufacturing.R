#' Update Australian Manufacturing Data
#'
#' @return logical
#' @param force_update logical
#' @importFrom rlang .data
update_aus_manufacturing <- function(force_update = FALSE) {
  
  abs_file <- aitidata::download_data_cube(catalogue_string = "australian-industry",
                                           cube = "Manufacturing industry", 
                                           path = "data-raw")
  #fpath <- gsub("[^\\/]*$", "", fpath)
  years <- readxl::read_excel(abs_file, sheet = "Table_1", skip = 4, n_max = 1) %>%
    dplyr::select(1, 5, 9) 
  
  years <- colnames(years)
  
  if (max(years) > max(aitidata::aus_manufacturing$year) | force_update) {
    
    aus_manufacturing <- readxl::read_excel(abs_file, 
                                          sheet = "Table_1", 
                                          skip = 7, 
                                          col_names = c("industry", "employment_1", "wages_1", "income_1", "iva_1",
                                                        "employment_2", "wages_2", "income_2", "iva_2",
                                                        "employment_3", "wages_3", "income_3", "iva_3")) %>%
      tidyr::pivot_longer(cols = where(is.double), names_to = "indicator", values_to = "value") %>%
      dplyr::mutate(year = dplyr::case_when(
        stringr::str_detect(.data$indicator, "_1") ~ years[1],
        stringr::str_detect(.data$indicator, "_2") ~ years[2],
        stringr::str_detect(.data$indicator, "_3") ~ years[3]),
        industry_code = stringr::str_extract(.data$industry, "\\d{2,4}"),
        industry_code = ifelse(is.na(.data$industry_code), "C", .data$industry_code),
        industry = trimws(stringr::str_replace(.data$industry, "\\d{2,4}", "")),
        indicator = stringr::str_remove_all(.data$indicator, "_[1-3]"))
    
    usethis::use_data(aus_manufacturing, overwrite = TRUE, compress = "xz")
    file.remove(abs_file)
    
  } else {
    
    message("`aus_manufacturing.rda` appears to be up to date: skipping update")
    file.remove(abs_file)
  }
}


