#' Update JobSeeker SA2 Data if available
#'
#' @param force_update logical
#'
#' @return logical

update_jobseeker_sa2 <- function(force_update = FALSE) {
  
  files <- data.frame(
    url = rvest::read_html("https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880") %>% 
      rvest::html_nodes("#dataset-resources a") %>% 
      rvest::html_attr("href")) %>%
    dplyr::filter(grepl(".xlsx", url)) %>%
    dplyr::mutate(date = stringr::str_extract(url, "(january|february|march|april|may|june|july|august|september|october|november|december)-\\d{4}"),
                  date = as.Date(paste0(date, "-01"), "%B-%Y-%d")
    ) %>%    #data.gov.au occasionally has duplicate files uploaded
    dplyr::distinct(date, .keep_all = TRUE)
  
  
  
  
  if (max(files$date) > max(aitidata::jobseeker_sa2$date) | force_update) {
    message("Updating `jobseeker_state.rda`, `jobseeker_sa2.rda`")
    
    file_path <- aitidata::download_file(files %>% dplyr::filter(date == max(.$date)) %>% dplyr::pull(url))
    
    sa2_sheet <- which(grepl("By SA2", readxl::excel_sheets(file_path)))

    dss_new <- readxl::read_excel(file_path,
                                  sheet = sa2_sheet,
                                  skip = 7,
                                  na = "<5",
                                  n_max = 2292,
                                  col_names = c("sa2", "sa2_name", "jobseeker_payment", "youth_allowance_other"),
                                  col_types = c("numeric", "text", "numeric", "numeric")) %>%
      dplyr::mutate(date = files %>% dplyr::filter(date == max(.$date)) %>% dplyr::pull(date)) %>%
      tidyr::replace_na(list(jobseeker_payment = 5, youth_allowance_other = 5))  %>%
      dplyr::left_join(strayr::read_absmap("sa22016", remove_year_suffix = TRUE), by = c("sa2_name")) %>%
      dplyr::select("sa2_code", 
                    "jobseeker_payment", 
                    "youth_allowance_other", 
                    "date") %>%
      tidyr::pivot_longer(names_to = "indicator",
                          values_to = "value",
                          cols = c("jobseeker_payment", "youth_allowance_other")) %>%
      dplyr::mutate(indicator = stringr::str_to_sentence(stringr::str_replace_all(.data$indicator, "_", " ")))
    
    
    jobseeker_sa2 <- dss_new %>% 
      dplyr::bind_rows(aitidata::jobseeker_sa2) %>%
      dplyr::distinct()

    jobseeker_state <- dss_new %>%
      dplyr::left_join(strayr::read_absmap("sa22016", remove_year_suffix = TRUE), by = c("sa2_code")) %>%
      dplyr::select(state = "state_name", 
                    "indicator",
                    "value",
                    "date") %>%
      dplyr::arrange(.data$date) %>%
      dplyr::group_by(.data$state, 
                      .data$indicator,
                      .data$date) %>%
      dplyr::summarise(value = sum(value), .groups = "drop") %>%
      dplyr::ungroup() %>%
      dplyr::bind_rows(aitidata::jobseeker_state) 

    usethis::use_data(jobseeker_state, compress = "xz", overwrite = TRUE)
    usethis::use_data(jobseeker_sa2, compress = "xz", overwrite = TRUE)
    
    any(purrr::map_lgl(file_path, file.remove))
  } else {
    message("Skipping: `jobseeker_state.rda`, `jobseeker_sa2.rda`: appears to be up-to-date") 
    return(TRUE)
    
  }
}

