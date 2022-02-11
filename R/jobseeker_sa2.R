#' Update JobSeeker SA2 Data if available
#'
#' @param force_update logical
#'
#' @return logical

update_jobseeker_sa2 <- function(force_update = FALSE) {
  
  
  jobseeker_latest <- aitidata::current_release(
    url = 'https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880', 
    source = "data.gov"
    )
  
  
  files <- data.frame(
    url = rvest::read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") %>% 
      rvest::html_nodes("#dataset-resources a") %>% 
      rvest::html_attr("href")) %>%
    dplyr::filter(grepl(".xlsx", url)) %>%
    dplyr::mutate(date = stringr::str_extract(url, "(january|february|march|april|may|june|july|august|september|october|november|december)-\\d{4}"),
                  date = as.Date(paste0(date, "-01"), "%B-%Y-%d")
    )
  
  #data.gov.au currently has 2 versions of the 2021-07-01 file uploaded
  
  files <- dplyr::distinct(files, date, .keep_all = TRUE)
  
  if (max(files$date) > max(aitidata::jobseeker_sa2$date) | force_update) {
    message("Updating `jobseeker_state.rda`, `jobseeker_sa2.rda`")
    
    file_paths <- purrr::map(files$url, ~aitidata::download_file(.x))
    
    jobseeker_all <- data.frame(
      "sa2" = numeric(),
      "sa2_name" = character(),
      "jobseeker_payment" = numeric(),
      "youth_allowance_other" = numeric()
    )
    
    for (i in seq_along(file_paths)) {
      dss_month <- readxl::read_excel(file_paths[[i]],
                                      sheet = "Table 4 - By SA2",
                                      skip = 7,
                                      na = "<5",
                                      n_max = 2292,
                                      col_names = c("sa2", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
                                      col_types = c("numeric", "text", "numeric", "numeric")) %>%
        dplyr::mutate(date = files$date[i]) %>%
        tidyr::replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5))
      
      jobseeker_all <- dplyr::bind_rows(jobseeker_all, dss_month)
    }
    
    jobseeker_sa2 <- jobseeker_all %>%
      dplyr::left_join(strayr::read_absmap("sa22016", remove_year_suffix = TRUE), by = c("sa2_name")) %>%
      dplyr::select(.data$sa2_code, 
                    .data$jobseeker_payment, 
                    .data$youth_allowance_other, 
                    .data$date) %>%
      dplyr::arrange(.data$date) %>%
      dplyr::group_by(.data$sa2_code) %>%
      dplyr::mutate(jobseeker_growth = .data$jobseeker_payment - dplyr::lag(.data$jobseeker_payment),
                    youth_allowance_growth = .data$youth_allowance_other - dplyr::lag(.data$youth_allowance_other)) %>%
      dplyr::ungroup() %>%
      tidyr::pivot_longer(cols = -c(.data$sa2_code, .data$date), names_to = "indicator", values_to = "value") %>%
      dplyr::mutate(indicator = stringr::str_to_sentence(stringr::str_replace_all(.data$indicator, "_", " ")))
    
    jobseeker_state <- jobseeker_all %>%
      dplyr::left_join(strayr::read_absmap("sa22016", remove_year_suffix = TRUE), by = "sa2_name") %>%
      dplyr::select(.data$state_name, 
                    .data$jobseeker_payment,
                    .data$youth_allowance_other,
                    .data$date) %>%
      dplyr::arrange(.data$date) %>%
      dplyr::group_by(.data$state_name, 
                      .data$date) %>%
      dplyr::summarise(dplyr::across(c(.data$jobseeker_payment, .data$youth_allowance_other), ~sum(.,na.rm = T)), .groups = "drop") %>%
      dplyr::ungroup() %>%
      tidyr::pivot_longer(cols = -c(.data$state_name, .data$date), names_to = "indicator", values_to = "value") %>%
      dplyr::mutate(indicator = stringr::str_to_sentence(stringr::str_replace_all(.data$indicator, "_", " ")),
                    series_type = "Original",
                    gender = "Persons",
                    age = "Total (age)",
                    unit = "000", 
                    year = lubridate::year(.data$date),
                    month = lubridate::month(.data$date, abbr = FALSE, label = TRUE)) %>%
      dplyr::rename(state = .data$state_name)
    
    usethis::use_data(jobseeker_state, compress = "xz", overwrite = TRUE)
    usethis::use_data(jobseeker_sa2, compress = "xz", overwrite = TRUE)
    
    any(purrr::map_lgl(file_paths, file.remove))
  } else {
    message("Skipping: `jobseeker_state.rda`, `jobseeker_sa2.rda`: appears to be up-to-date") 
    return(TRUE)
    
  }
}

