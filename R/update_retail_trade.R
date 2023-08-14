#' Update Retail Trade dataset
#'
#' @param force_update logical
#' @return logical
#'
update_retail_trade <- function(force_update = FALSE) {
  
  # Table 12 releases 1 week later than the other tables. 
  
  abs_test <- try(readabs::read_abs(cat_no = "8501.0", tables = "12", retain_files = FALSE), silent = TRUE)
  
  if (is.data.frame(abs_test)) {
    
    #If the download worked, we can proceed as usual
    
    if (max(abs_test$date) > max(aitidata::retail_trade$date) | force_update) {
      
      message("Updating `retail-trade-australia`")
      
      retail_trade <- readabs::read_abs("8501.0", tables = 12) %>%
        readabs::separate_series(column_names = c("indicator", "state", "industry_group"), remove_nas = TRUE) %>%
        dplyr::mutate(year = lubridate::year(.data$date),
                      month = lubridate::month(.data$date, abbr = FALSE, label = TRUE),
                      state = dplyr::case_when(
                        state == "Total (State)" ~ "Australia",
                        TRUE ~ state
                      )) %>%
        dplyr::select("date",
                      "year",
                      "month", 
                      "state", 
                      "indicator", 
                      "industry_group", 
                      "series_type", 
                      "value", 
                      "unit")
      
      usethis::use_data(retail_trade, overwrite = TRUE, compress = "xz")
      return(TRUE)
      
      
    } else {
      
      message("Skipping `retail_trade.rda`: appears to be up-to-date")
      return(TRUE)
      
    }
    } else {
      return(TRUE)
  }
} 


