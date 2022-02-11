#' Run data generating scripts
#'
#' @param force_update logical 
#'
#' @return NULL
#' 
update_abs <- function(force_update = FALSE) {
  update_labour_force(force_update)
  update_employment_by_industry(force_update)
  update_cabee_sa2(force_update)
  update_internet_vacancies_regional(force_update)
  update_aus_manufacturing(force_update)
  update_labour_account(force_update) 
  update_mobility_facebook()
  update_national_accounts(force_update) 
  update_payroll_index(force_update)
  update_payroll_substate(force_update)
  update_retail_trade(force_update)
  update_underutilisation(force_update) 
  update_small_area_labour_market(force_update)
  update_jobseeker_sa2(force_update)
  update_covid_data() #this has to be after jobseeker, payroll, small area
}
