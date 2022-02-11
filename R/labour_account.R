## code to prepare `labour_account` dataset goes here

update_labour_account <- function(force_update = FALSE) {
  abs_test <- aitidata::download_data_cube(catalogue_string = "labour-account-australia",
                                           cube = "6150055003DO001.xls",
                                           path = "data-raw")
  
  current_date <- readxl::read_xls(abs_test, sheet = 2, skip = 9) %>%
    dplyr::select(1) %>%
    dplyr::pull() %>%
    max() %>%
    as.Date()
  
  if (current_date > max(aitidata::labour_account$date) | force_update) {
    message("Updating `data/labour_account.rda`")
    
    abs_file <- abs_test
    
    labour_account <- readabs::read_abs_local(filenames = abs_file, path = "data-raw") %>%
      dplyr::mutate(series = ifelse((grepl("Public sector", .data$series) | grepl("Private sector", .data$series)), 
                                    gsub(x = .data$series, pattern = "; P", replacement = "- P"), 
                                    .data$series)) %>%
      tidyr::separate(.data$series, into = c("prefix", "indicator", "state", "industry"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(where(is.character), trimws),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, abbr = FALSE, label = TRUE)) %>%
      dplyr::filter(!grepl(" - Percentage changes", .data$indicator),
                    !is.na(.data$value)) %>%
      dplyr::select(.data$date, 
                    .data$month, 
                    .data$year, 
                    .data$prefix, 
                    .data$indicator, 
                    .data$state, 
                    .data$industry, 
                    .data$series_type, 
                    .data$value,
                    .data$unit)
    
    
    usethis::use_data(labour_account, overwrite = TRUE, compress = "xz")
    file.remove(abs_file)

  } else {
    message("Skipping `labour_account.rda`: appears to be up-to-date")
    file.remove(abs_test)
    
  }
}
