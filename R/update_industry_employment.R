#' Update Employment by industry data
#'
#' @param force_update logical
#' @return logical
update_industry_employment <- function(force_update = FALSE) {
  
  if (!force_update) {
  
  readabs::download_abs_data_cube("labour-force-australia-detailed",
                                               cube = "6291023a.xlsx",
                                               path = here::here("data-raw"))
  
  current_date <- readabs::read_abs_local(path = here::here("data-raw"),
                                          filenames = "6291023a.xlsx") %>%
    dplyr::pull(date) %>%
    max()
  
  } else {
    current_date <- TRUE
  }
  
  if (current_date > max(aitidata::industry_employment$date) | force_update) {
    
    message("updating `industry_employment`")
    
    readabs::download_abs_data_cube("labour-force-australia-detailed",
                                                           cube = "6291005.xlsx",
                                                           path = here::here("data-raw"))
    
    industry_employment <- readabs::read_abs_local(path = here::here("data-raw"),
                                                   filenames = "6291005.xlsx") |> 
      tidyr::separate(.data$series, into = c("state", "industry", "indicator"), sep = ";", extra = "drop") |> 
      dplyr::mutate(dplyr::across(c("state", "industry", "indicator"), ~ gsub(pattern = "> ", x = .x, replacement = "")),
                    dplyr::across(where(is.character), ~trimws(.x)),
                    indicator = ifelse(indicator == "", industry, indicator),
                    industry = ifelse(grepl(x = industry, pattern = "Employed"), "Total (industry)", industry)) |> 
      dplyr::group_by(date, indicator, state) |> 
      dplyr::mutate(value_share = 200 * value / sum(value)) |> 
      dplyr::ungroup() 
    
    usethis::use_data(industry_employment, overwrite = TRUE, compress = "xz")
    return(TRUE)
    } else {
    message("Skipping `industry_employment.rda`: appears to be up-to-date")
    return(TRUE)
  
  }
}
