update_national_accounts <- function(force_update = FALSE) {
  abs_test <- readabs::read_abs(cat_no = "5206.0", tables = 42, retain_files = FALSE)
  
  if (max(abs_test$date) <= max(aitidata::national_accounts$date) | force_update) {
    
    message("Updating `national_accounts.rda`")
    raw <- readabs::read_abs(cat_no = "5206.0", tables = c(1, 6), retain_files = FALSE)
    
    national_accounts <- raw %>%
      dplyr::filter(.data$table_no == "5206006_industry_gva") %>%
      dplyr::mutate(series = stringr::str_replace_all(.data$series, stringr::regex("(\\s\\([A-S]\\)\\s)|(\\s;)$", multiline = TRUE), "")) %>%
      tidyr::separate(.data$series, into = c("industry", "subdivision"), sep = ";", fill = "right") %>%
      dplyr::mutate(dplyr::across(where(is.character), ~ trimws(.)),
                    industry = strayr::clean_anzsic(.data$industry, silent = TRUE)) %>%
      dplyr::filter(.data$industry %in% aitidata::anzsic$division,
                    !is.na(.data$value)) %>%
      dplyr::mutate(subdivision = ifelse(.data$subdivision == "", paste(.data$industry, "(Total)"), .data$subdivision)) %>%
      tidyr::separate(.data$subdivision, into = c("subdivision", "indicator"), sep = ":", fill = "right") %>%
      dplyr::select(.data$date, 
                    .data$industry, 
                    .data$subdivision, 
                    .data$value, 
                    .data$series_type, 
                    .data$unit) %>%
      dplyr::mutate(indicator = dplyr::case_when(
        .data$unit == "$ Millions" ~ "Gross Value Added",
        .data$unit == "Percent" ~ "Percent Changes",
        .data$unit == "Index Points" ~ "Contribution To Growth"),
        indicator = ifelse(.data$indicator == "Percent Changes", paste("Gross value added (Growth)"), .data$indicator),
        subdivision = ifelse(test = .data$subdivision %in% c("Gross Value Added",
                                                             "Percentage Changes",
                                                             "Contributions To Growth",
                                                             "Revision To Percentage Changes"),
                             yes = paste(.data$industry, "(Total)"),
                             no = .data$subdivision),
        indicator = stringr::str_to_sentence(.data$indicator))
    
    
    # industry_aggregates <- raw %>%
    #   filter(table_no == "5206006_industry_gva") %>%
    #   separate(series, into = c("indicator", "type"), sep = ": ") %>%
    #   mutate(across(where(is.character), ~ str_to_sentence(.)),
    #     indicator = ifelse(str_detect(type, "percentage changes"), paste(indicator, "(growth)"), indicator),
    #     type = str_remove_all(type, "( - percentage changes ;)|( ;)")
    #   ) %>%
    #   filter(!is.na(value)) %>%
    #   select(date, indicator, type, value, series_type, unit)
    
    # national_accounts <- bind_rows(industry_aggregates, industry_value_add) %>%
    #   mutate(across(c(industry, subdivision), ~ ifelse(is.na(.), "Total (industry)", .)))
    
    
    usethis::use_data(national_accounts, overwrite = TRUE, compress = "xz")
    return(TRUE)
  } else {
    
    message("Skipping `national_accounts.rda`: appears to be up-to-date")
    file.remove(abs_test)
   
  }
}
