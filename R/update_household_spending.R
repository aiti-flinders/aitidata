#' Update Household spending data
#'
#' @param force_update logical
#' @return logical. TRUE if the update was successful

update_household_spending <- function(force_update = FALSE) {
  
  hh_spending <- function(path, state) {
    
    cur_month_header <- readxl::read_excel(path,
                                           sheet = "Data 2",
                                           range = "A4") %>%
      colnames()
    
    cur_month <- paste0(stringr::str_extract(cur_month_header, "([^,]+$)"), " 01")
    
    rows <- lubridate::interval("2019-01-01", myd(x)) %/% months(1) + 1
    
    
    readxl::read_excel(path, 
                       sheet = "Data 2",
                       skip = 4,
                       n_max = rows,
                       col_types = c("date",
                                     rep("numeric", 14))) %>%
      tidyr::pivot_longer(cols = 2:length(.),
                          names_to = "coicop_division",
                          values_to = "index") %>%
      dplyr::mutate(date = as.Date(...1, origin = "1899-12-30"), 
                    state = state) %>%
      dplyr::filter(!is.na(index)) %>% 
      dplyr::select(-...1)
    
  }
  
  if (!force_update) {
    
    fname <- aitidata::download_data_cube(catalogue_string = "monthly-household-spending-indicator",
                                 cube = "Table 1. Experimental estimates of Household Spending, Australia",
                                 path = here::here("data-raw"))
    
    # hh_spending <- function(path, state) {
    #   
    #   readxl::read_excel(path, 
    #                      sheet = "Data 2",
    #                      skip = 4,
    #                      col_types = c("date",
    #                                    rep("numeric", 14))) %>%
    #     tidyr::pivot_longer(cols = 2:length(.),
    #                         names_to = "coicop_division",
    #                         values_to = "index") %>%
    #     dplyr::mutate(date = as.Date(...1, origin = "1899-12-30"), 
    #                   state = state) %>%
    #     dplyr::filter(!is.na(index)) %>% 
    #     dplyr::select(-...1)
    #   
    # }
    

    current_date <- hh_spending(fname, "Australia") %>%
      dplyr::pull(date) %>%
      max()
    
  } else {
    
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::household_spending$date) | force_update) {
    
    message("updating `household_spending`")
    
    states <- strayr::clean_state(c("Aus", "NSW", "Vic", "Qld", "SA", "WA", "Tas", "NT", "ACT"), to = "state_name") 
    
    cubes <- paste0("Table ", seq(1,9), ". Experimental estimates of Household Spending, ", states)
    
    files <- purrr::map(.x = cubes, .f = ~aitidata::download_data_cube("monthly-household-spending-indicator", cube = .x, path = "data-raw"))
    
    household_spending <- purrr::map2_df(.x = files, .y =  states, .f = ~hh_spending(.x, .y))
    
    usethis::use_data(household_spending, overwrite = TRUE, compress = "xz")
    
    any(file.remove(unlist(files)))
     
  } else {
    message("Skipping `household_spending,rda`: appears to be up-to-date")
    return(fname)
  }
}
  



