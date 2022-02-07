update_national_accounts <- function() {
  abs_test <- readabs::read_abs(cat_no = "5206.0", tables = 42, retain_files = FALSE)
  
  if (max(abs_test$date) <= max(aitidata::national_accounts$date)) {
    message("Skipping `national_accounts.rda`: appears to be up-to-date")
  } else {
    
    message("Updating `national_accounts.rda`")
    raw <- readabs::read_abs(cat_no = "5206.0", tables = c(1, 6), retain_files = FALSE)
    
    national_accounts <- raw %>%
      dplyr::filter(table_no == "5206006_industry_gva") %>%
      dplyr::mutate(series = stringr::str_replace_all(series, stringr::regex("(\\s\\([A-S]\\)\\s)|(\\s;)$", multiline = TRUE), "")) %>%
      tidyr::separate(series, into = c("industry", "subdivision"), sep = ";", fill = "right") %>%
      dplyr::mutate(dplyr::across(where(is.character), ~ trimws(.)),
                    industry = strayr::clean_anzsic(industry)) %>%
      dplyr::filter(industry %in% aitidata::anzsic$division,
                    !is.na(value)) %>%
      dplyr::mutate(subdivision = ifelse(subdivision == "", paste(industry, "(Total)"), subdivision)) %>%
      tidyr::separate(subdivision, into = c("subdivision", "indicator"), sep = ":", fill = "right") %>%
      dplyr::select(date, industry, subdivision, value, series_type, unit) %>%
      dplyr::mutate(indicator = dplyr::case_when(
        unit == "$ Millions" ~ "Gross Value Added",
        unit == "Percent" ~ "Percent Changes",
        unit == "Index Points" ~ "Contribution To Growth"),
        indicator = ifelse(indicator == "Percent Changes", paste("Gross value added (Growth)"), indicator),
        subdivision = ifelse(test = subdivision %in% c("Gross Value Added",
                                                       "Percentage Changes",
                                                       "Contributions To Growth",
                                                       "Revision To Percentage Changes"),
                             yes = paste(industry, "(Total)"),
                             no = subdivision),
        indicator = stringr::str_to_sentence(indicator))
    
    
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
  }
}
