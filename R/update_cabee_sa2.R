#' Update Count of Australian Businesses Data by SA2
#'
#' @param force_update logical. FALSE (the default) checks if new data is available before updating. 
#'
#' @return logical. TRUE if the update was successful
#' @export 

update_cabee_sa2 <- function(force_update = FALSE) {
  
  # The ABS is currently updating the CABEE release schedule. Add the check back after december 16th
  
  abs_test <- aitidata::download_data_cube(catalogue_string = "counts-australian-businesses-including-entries-and-exits",
                                           cube = 1,
                                           path = "data-raw")
  
  current_date <- readxl::read_excel(abs_test,
                                     sheet = 1,
                                     range = "A2",
                                     col_names = "release") %>%
    dplyr::mutate(release = stringr::str_sub(.data$release, start = -9L, end = -1L),
                  release = as.Date(paste0(.data$release, "-01"), format = "%B %Y-%d")) %>%
    dplyr::pull(.data$release)
  
  #current_date <- TRUE
  
  if (current_date > max(aitidata::cabee_sa2$date) | force_update) {
    
    abs_file <- try(aitidata::download_data_cube(catalogue_string = "counts-australian-businesses-including-entries-and-exits", 
                                                 cube = "Data cube 8: Businesses by industry division by Statistical Area Level 2 by employment size ranges",
                                                 path = "data-raw"), silent = TRUE)
    
    if (!grepl("Error", abs_file)) {
      
      cabee_sheets <- readxl::excel_sheets(abs_file)
      cabee_sheets <- stringr::str_extract(cabee_sheets, "\\d+.+")
      cabee_sheets <- cabee_sheets[!is.na(cabee_sheets)]
      cabee_sheets <- cabee_sheets[stringr::str_detect(cabee_sheets, "b", negate = TRUE)]
      
      cabee_sa2 <- tibble::tribble(
        ~"date",
        ~"industry_code",
        ~"industry_label",
        ~"sa2_main_2016",
        ~"sa2_name_2016",
        ~"non_employing",
        ~"employing_1_4",
        ~"employing_5_19",
        ~"employing_20_199",
        ~"employing_200_plus",
        ~"total"
      )
      
      for (i in cabee_sheets) {
        cabee_year <- readxl::read_excel(abs_file,
                                         sheet = i,
                                         skip = 7,
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
                                           "total"
                                         )) %>%
          dplyr::filter(!is.na(.data$sa2_main_2016)) %>%
          dplyr::mutate(sa2_main_2016 = as.character(.data$sa2_main_2016),
                        date = as.Date(paste(stringr::str_extract(i, "\\d+"), "06", "01"), format = "%Y %M %d"))
        
        cabee_sa2 <- dplyr::bind_rows(cabee_year, cabee_sa2)
      }
      
      cabee_sa2 <- cabee_sa2 %>%
        tidyr::pivot_longer(cols = -c(.data$industry_code, .data$industry_label, .data$sa2_main_2016, .data$sa2_name_2016, .data$date),
                            names_to = "indicator",
                            values_to = "value") %>%
        dplyr::select(.data$date,
                      division = .data$industry_label,
                      .data$sa2_main_2016,
                      .data$sa2_name_2016,
                      .data$indicator, 
                      .data$value)
      
      usethis::use_data(cabee_sa2, compress = "xz", overwrite = TRUE)
      file.remove(abs_file)
      
      
    } else {
      message("Skipping `cabee_sa2.rda`: appears to be up-to-date")
      file.remove(abs_test)
      
    }
  }
}

