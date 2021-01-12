#' 
#'
#' @importFrom magrittr %>%
#' 
build_daitir <- function() {
  abs_cats <- tibble::tribble(
  ~cat_no, ~url, ~tables,  ~data_name,  
  "6202.0", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/latest-release", list("12" = "Labour force status by Sex, State and Territory", 
                                            "19" = "Monthly hours worked in all jobs (Extrapolated): by Employed full-time, part-time and Sex and by State and Territory",
                                            "22" = "Underutilised persons by Age and Sex",
                                            "23" = "Underutilised persons by State and Territory and Sex"), "labour_force",
  "5206.0", "https://www.abs.gov.au/statistics/economy/national-accounts/australian-national-accounts-national-income-expenditure-and-product/latest-release", list("1" = "Key National Accounts Aggregates",
                                                                                           "6" = "Gross Value Added by Industry"), "national_accounts",
  "6160.0.55.001", "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release", list("4" = "Payroll Jobs and Wages Indexes"), "payroll_index",
  "6160.0.55.001", "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release", list("5" = "Sub-state - Payroll jobs indexes"), "payroll_substate",
  "6291.0.55.003", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/latest-release", list("5" = "Employed persons by State, Territory and Industry division of main job (ANZSIC)",
                                                             "19" = "Underemployed persons by Industry division (ANZSIC), Occupation major group (ANZSCO) of main job and Sex"), "employment_by_industry",
  "6291.0.55.003", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/latest-release", list("23a" = "Volume measures of underutilisation by State, Territory and Sex",
                                                             "23b" = "Volume measures of underutilisation by Age and Sex"), "underutilisation",
  "6150.0.55.003", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-account-australia/latest-release", list("1" = "Total All Industries"), "labour_account",
  "8165.0", "https://www.abs.gov.au/statistics/economy/business-indicators/counts-australian-businesses-including-entries-and-exits/latest-release", list("8" = "Businesses by Industry Division by Statistical Area Level 2 by Employment Size Ranges"), "cabee_sa2") %>%
  tidyr::unnest_longer(col = tables) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(mtime = as.Date(file.info(paste0("data/", data_name, ".rda"))$mtime),
         current_release = abs_current_release(url = url),
         next_release = abs_next_release(url = url))
  
  return(abs_cats)
}

