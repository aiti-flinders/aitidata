#' Update small area labour market data
#'
#' @param force_update logical 
#'
#' @return logical
update_small_area_labour_market <- function(force_update = FALSE) {
  
  if (!force_update) {
  
  download.file("https://lmip.gov.au/PortalFile.axd?FieldID=3193962&.csv",
                destfile = here::here("data-raw/salm_test.csv"),
                mode = "wb")
  current_date <- readr::read_csv(here::here("data-raw/salm_test.csv"),
                           skip = 1) %>%
    dplyr::select(dplyr::last_col()) 
  
  current_date <- as.Date(paste0(colnames(current_date), "-01"), format = "%b-%y-%d")
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::small_area_labour_market$date) | force_update) {
    
    download.file("https://lmip.gov.au/PortalFile.axd?FieldID=3193958&.csv",
                  destfile = here::here("data-raw/salm_sa2.csv"),
                  mode = "wb")
    
    raw <- readr::read_csv(here::here("data-raw/salm_sa2.csv"), 
                           skip = 1, 
                           na = "-")
    
    all_sa2 <- data.frame(strayr::read_absmap("sa22016", remove_year_suffix = TRUE)) %>%
      dplyr::select(.data$sa2_name, .data$sa2_code, .data$state_name)
    
    small_area_labour_market <- raw %>%
      dplyr::mutate(dplyr::across(where(is.numeric), as.character)) %>%
      dplyr::rename(indicator = .data$`Data Item`,
                   sa2_name = .data$`Statistical Area Level 2 (SA2) (2016 ASGS)`,
                   sa2_code = .data$`SA2 Code (2016 ASGS)`) %>%
      tidyr::pivot_longer(cols = -c(.data$indicator,
                                    .data$sa2_name,
                                    .data$sa2_code),
                          names_to = "date",
                          values_to = "value") %>%
      dplyr::mutate(value = as.numeric(gsub(",", "", .data$value)),
                    date = as.Date(paste0(.data$date, "-01"), format = "%b-%y-%d")) %>%
      dplyr::right_join(all_sa2) %>%
      tidyr::complete(.data$indicator, tidyr::nesting(sa2_name, sa2_code), .data$date) %>%
      dplyr::filter(!is.na(.data$date), 
                    !is.na(.data$indicator))
    
    usethis::use_data(small_area_labour_market, overwrite = TRUE, compress = "xz")
    file.remove(here::here("data-raw/salm_sa2.csv"))
    
  } else {
    message("Skipping `small_area_labour_market.rda`: appears to be up-to-date")
    file.remove(here::here("data-raw/salm_test.csv"))
    
  }
}