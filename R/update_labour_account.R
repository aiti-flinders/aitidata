## code to prepare `labour_account` dataset goes here

update_labour_account <- function(force_update = FALSE) {
  abs_test <- aitidata::download_data_cube(catalogue_string = "labour-account-australia",
                                           cube = "6150055003DO001.xls",
                                           path = "data-raw")
  
  current_date <- readxl::read_excel(abs_test, sheet = 2, skip = 9) %>%
    dplyr::select(1) %>%
    dplyr::pull() %>%
    max() %>%
    as.Date()
  
  if (current_date > max(aitidata::labour_account$date) | force_update) {
    message("Updating `data/labour_account.rda`")
    
    purrr::walk(.x = sprintf("%0.2d", 2:20), 
                .f = ~ aitidata::download_data_cube("labour-account-australia", 
                                                    glue::glue("6150055003DO0{.x}.xlsx"),
                                                    path = "data-raw/labour-account"))
    
    labour_account <- readabs::read_abs_local(path = "data-raw/labour-account") %>%
      dplyr::mutate(series = ifelse((grepl("Public sector", .data$series) | grepl("Private sector", .data$series)), 
                                    gsub(x = .data$series, pattern = "; P", replacement = "- P"), 
                                    .data$series)) %>%
      tidyr::separate(.data$series, into = c("prefix", "indicator", "state", "industry"), sep = ";", extra = "drop") %>%
      dplyr::mutate(dplyr::across(where(is.character), trimws),
                    industry = gsub("(.\\([A-S]\\))", x = industry, replacement = ""),
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, abbr = FALSE, label = TRUE)) %>%
      dplyr::filter(!grepl(" - Percentage changes", .data$indicator),
                    !is.na(.data$value)) %>%
      dplyr::select("date", 
                    "month", 
                    "year", 
                    "prefix", 
                    "indicator", 
                    "state", 
                    "industry", 
                    "series_type", 
                    "value",
                    "unit")
    
    
    usethis::use_data(labour_account, overwrite = TRUE, compress = "xz")
    any(file.remove(paste0("data-raw/labour-account/",list.files("data-raw/labour-account"))))

  } else {
    message("Skipping `labour_account.rda`: appears to be up-to-date")
    file.remove(abs_test)
    
  }
}
