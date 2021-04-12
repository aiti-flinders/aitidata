## code to prepare `aitidata_catalogues` dataset goes here
aitidata_catalogues <- tibble::tribble(
  ~cat_no, ~catalogue_string, ~url, ~tables,  ~data_name,  
  "6202.0", "labour-force-australia", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/latest-release", list("12" = "Labour force status by Sex, State and Territory", 
                                                                                                                                                         "19" = "Monthly hours worked in all jobs (Extrapolated): by Employed full-time, part-time and Sex and by State and Territory",
                                                                                                                                                         "22" = "Underutilised persons by Age and Sex",
                                                                                                                                                         "23" = "Underutilised persons by State and Territory and Sex"), "labour_force", 
  "5206.0", "australian-national-accounts-national-income-expenditure-and-product", "https://www.abs.gov.au/statistics/economy/national-accounts/australian-national-accounts-national-income-expenditure-and-product/latest-release", list("1" = "Key National Accounts Aggregates",
                                                                                                                                                                                                                                            "6" = "Gross Value Added by Industry"), "national_accounts", 
  "6160.0.55.001", "weekly-payroll-jobs-and-wages-australia", "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release", list("4" = "Payroll Jobs and Wages Indexes"), "payroll_index", 
  "6160.0.55.001", "weekly-payroll-jobs-and-wages-australia", "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release", list("5" = "Sub-state - Payroll jobs indexes"), "payroll_substate", 
  "6291.0.55.003", "labour-force-australia-detailed", "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/latest-release", list("5" = "Employed persons by State, Territory and Industry division of main job (ANZSIC)",
                                                                                                                                                                                  "19" = "Underemployed persons by Industry division (ANZSIC), Occupation major group (ANZSCO) of main job and Sex"), "employment_by_industry", 
  "6291.0.55.003", "labour-force-australia-detailed","https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/latest-release", list("23a" = "Volume measures of underutilisation by State, Territory and Sex",
                                                                                                                                                                                 "23b" = "Volume measures of underutilisation by Age and Sex"), "underutilisation", 
  "6150.0.55.003", "labour-account-australia",  "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-account-australia/latest-release", list("1" = "Total All Industries"), "labour_account", 
  "8165.0", "counts-australian-businesses-including-entries-and-exits", "https://www.abs.gov.au/statistics/economy/business-indicators/counts-australian-businesses-including-entries-and-exits/latest-release", list("8" = "Businesses by Industry Division by Statistical Area Level 2 by Employment Size Ranges"), "cabee_sa2",
  "8155.0", "australian-industry", "https://www.abs.gov.au/statistics/industry/industry-overview/australian-industry/latest-release", list("Manufacturing industry"), "aus_manufacturing",
  NA, NA, NA, list(NA),  "covid_data",
  NA, "jobseeker-payment-and-youth-allowance-recipients-monthly-profile", "https://data.gov.au/data/dataset/jobseeker-payment-and-youth-allowance-recipients-monthly-profile", NA,  "jobseeker_sa2" ) %>%
  tidyr::unnest_longer(col = tables) 


usethis::use_data(aitidata_catalogues, internal = TRUE, overwrite = TRUE)
