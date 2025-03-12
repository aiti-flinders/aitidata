#' Run data generating scripts
#'
#' @param force_update logical 
#'
#' @return NULL
#' 
update_abs <- function() {
  source("data-raw/labour_force.R")
  source("data-raw/labour_force_industry.R")
  source("data-raw/manufacturing.R")
  source("data-raw/labour_account.R")
  source("data-raw/business_counts.R")
  source("data-raw/payroll_data.R")
  source("data-raw/national_accounts.R")
}
