#' Run data generating scripts
#'
#' @return NULL
#' 
#' @export
update_abs <- function() {
  update_labour_force()
  update_employment_by_industry()
  update_cabee_sa2()
  update_internet_vacancies_regional()
  update_aus_manufacturing()
  update_labour_account() 
  update_mobility_facebook()
  update_national_accounts() 
  update_payroll_index()
  update_payroll_substate()
  update_retail_trade()
  update_underutilisation() 
  update_covid_data() #this has to be after jobseeker, payroll, small area
}
