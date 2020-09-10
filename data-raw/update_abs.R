## code to prepare `update_abs` dataset goes here
if(!daitir::abs_data_up_to_date("6202.0")) {
  source(here::here("data-raw", "labour_force.R")) 
}

if (!daitir::abs_data_up_to_date("6150.0.55.003")) {
  source(here::here("data-raw", "labour_account.R"))
}

