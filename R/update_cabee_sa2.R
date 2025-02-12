#' Update Count of Australian Businesses Data by SA2
#'
#' @param force_update logical. FALSE (the default) checks if new data is available before updating. 
#'
#' @return logical. TRUE if the update was successful
#' @export 

update_cabee_sa2 <- function(force_update = FALSE) {
  
  
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
  
  
  if (current_date > max(aitidata::cabee_sa2$date) | force_update) {
    
    abs_file <- try(readabs::download_abs_data_cube(catalogue_string = "counts-australian-businesses-including-entries-and-exits", 
                                                    cube = "8165DC08",
                                                    path = "data-raw"), silent = TRUE)
    
    if (!grepl("Error", abs_file)) {
      
      cabee_sheets <- readxl::excel_sheets(abs_file)
      cabee_sheets <- stringr::str_extract(cabee_sheets, "\\d")
      cabee_sheets <- cabee_sheets[!is.na(cabee_sheets)]
      cabee_sheets <- cabee_sheets[stringr::str_detect(cabee_sheets, "b", negate = TRUE)]
      cabee_sheets <- paste("Table", cabee_sheets)
      
      # SA2 Business Counts include both point in time (odd # sheets) and annualised employment size ranges (even # sheets)
      cabee_sheets <- cabee_sheets[grepl("[246]", cabee_sheets)]
      
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
      
      cabee_years <- purrr::map(.x = cabee_sheets,
                                .f = ~readxl::read_excel(abs_file,
                                                         sheet = .x,
                                                         col_names = "year",
                                                         range = "A4") |> 
                                  dplyr::mutate(year = as.Date(paste0("01", stringr::str_extract_all(year, "June \\d+")), "%d %B %Y")) |> 
                                  dplyr::pull(year)) |> 
        purrr::list_c()
      
      cabee_sa2 <- purrr::map2(.x = cabee_sheets,
                               .y = cabee_years,
                               .f = ~ readxl::read_excel(abs_file,
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
                                                         )) |> 
                                 dplyr::filter(!is.na(.data$sa2_main_2016)) |> 
                                 dplyr::mutate(sa2_main_2016 = as.character(.data$sa2_main_2016),
                                               date = .y)) |> 
        purrr::list_rbind()
      
      
      cabee_sa2 <- cabee_sa2 %>%
        tidyr::pivot_longer(cols = -c("industry_code", "industry_label", "sa2_main_2016", "sa2_name_2016", "date"),
                            names_to = "indicator",
                            values_to = "value") %>%
        dplyr::select("date",
                      division = "industry_label",
                      "sa2_main_2016",
                      "sa2_name_2016",
                      "indicator", 
                      "value")
      
      usethis::use_data(cabee_sa2, compress = "xz", overwrite = TRUE)
      file.remove(abs_file)
      
      
    } else {
      message("Skipping `cabee_sa2.rda`: appears to be up-to-date")
      file.remove(abs_test)
      
    }
  }
}

