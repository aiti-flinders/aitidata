#' @title Counts of Australian Businesses, including Entries and Exists, June 2015 to June 2019
#'
#' @description
#' A dataset containing the number of businesses, by industry division, by SA2 statistical areas,
#' by employment size ranges
#'
#' @format A dataframe with 6 variables:
#' \describe{
#' \item{date}{date}
#' \item{division}{Industry division of operating business}
#' \item{sa2_main_2016}{9 digit statistical area code (2016 SA2)}
#' \item{sa2_name_2016}{Name of statistical area}
#' \item{indicator}{Employment ranges}
#' }
#'
#' @source \url{https://www.abs.gov.au/AUSSTATS/abs@.nsf/Lookup/8165.0Main+Features2June%202015%20to%20June%202019?OpenDocument}
#'
"cabee_sa2"


#' @title ABS Employment by Industry
#'
#' @description
#' A dataset containing quarterly national and sub-national employment indicators
#' by industry of employment since February 1991.
#'
#' @format A dataframe with 11 variables:
#' \describe{
#' \item{date}{Date}
#' \item{year}{Year}
#' \item{month}{Month}
#' \item{indicator}{Indicator}
#' \itemize{
#' \item{Employed total}
#' \item{Underemployed total}
#' \item{Underemployment ratio (proportion of employed)}
#' \item{Employed full-time}
#' \item{Employed part-time}
#' }
#' \item{industry}{Industry of employment}
#' \item{gender}{Gender}
#' \item{age}{Age}
#' \item{state}{State}
#' \item{series_type}{Level of adjustment of original data: original (no adjustment), seasonally adjusted, or trend}
#' \item{value}{Value of employment indicator}
#' \item{unit}{Unit of measurement for indiciator}
#' }
#'
#' @source \url{https://www.abs.gov.au/ausstats/abs@.nsf/PrimaryMainFeatures/6291.0.55.001?OpenDocument}
"industry_employment"

#' ABS Detailed employment by industry
"industry_employment_detailed"


#' @title Internet Vacancies Index
#'
#' @description
#' A dataset containing monthly nation and sub-national internet vacancies by
#' occupation since January 2006. Data is updated monthly, about one week
#' after the Labour Force Survey is released.
#'
#' @format A dataframe with 7 variables
#' \describe{
#' \item{state}{State}
#' \item{date}{year month date, since January 2006}
#' \item{anzsco_2}{2 digit ANZSCO}
#' \item{occupation}{Occupation name}
#' \item{value}{Number of internet vacancies recorded}
#' \item{anzsco_1}{1 digit ANZSCO}
#' \item{occupation_group}{Occupation group name}
#' }
#'
#' @source \url{https://lmip.gov.au/default.aspx?LMIP/GainInsights/VacancyReport}
"internet_vacancy_index"

#' @title JobSeeker data by SA2
#'
#' @description
#' Department of Social Services estimates of monthly jobseeker and
#' youth allowance payments since March 2020
#'
#' @format A data frame with 4 variables
#' \describe{
#' \item{sa2_code}{Statistical Area 2 Code. A mix of 2016 and 2021 boundaries}
#' \item{sa2_name}{Statistical Area 2 Name. A mix of 2016 and 2021 boundaries}
#' \item{date}{Date}
#' \item{indicator}{Jobseeker payment, Youth allowance other, Jobseeker growth, Youth allowance growth}
#' \item{value}{Value}
#' }
#'
#' @source \url{https://data.gov.au/data/dataset/jobseeker-payment-and-youth-allowance-recipients-monthly-profile}
"jobseeker_sa2"

#' ABS Labour Account
#'
#' Experimental ABS labour force data
#'
#' @format A data frame with 10 variables
#' \describe{
#' \item{date}{Date}
#' \item{month}{Month}
#' \item{year}{Year}
#' \item{prefix}{Prefix on the indicator - safe to ignore}
#' \item{indicator}{Labour account indicator}
#' \item{state}{State}
#' \item{industry}{Industry}
#' \item{series_type}{Series type}
#' \item{value}{Value}
#' \item{unit}{Unit of value}
#' }
#'
#' @source \url{https://www.abs.gov.au/ausstats/abs@.nsf/mf/6150.0.55.003}
"labour_account"

#' ABS Labour Force Survey
#'
#' A dataset containing monthly national and sub-national labour force
#' indicators since February 1978.
#'
#' @format A data frame with 10 variables:
#' \describe{
#' \item{date}{date of survey}
#' \item{sex}{sex of individual surveyed: persons, male, or female}
#' \item{age}{age of individual surveyed}
#' \item{state}{state or territory (including Australia)}
#' \item{series_type}{level of adjustment of original data: original (no adjustment), seasonally adjusted, or trend}
#' \item{unit}{unit of measurement for indicator}
#' \item{indicator}{labour force indicator}
#' \item{value}{value of labour force indicator}
#' }
#'
#' @source \url{https://www.abs.gov.au/ausstats/abs@.nsf/mf/6202.0}
"labour_force"

#' ABS Weekly Payroll Index
#'
#' ABS Weekly Payroll data since 4th January 2020.
#'
#' @format A dataframe with 6 variables:
#' \describe{
#' \item{date}{Date}
#' \item{gender}{Gender}
#' \item{age}{Age group}
#' \item{state}{State}
#' \item{industry}{Industry}
#' \item{value}{Value}
#' }
#'
#' @source \url{https://www.abs.gov.au/ausstats/abs@.nsf/mf/6160.0.55.001}
"payroll_index"

#' DESE Small (SA2) Area Labour Market 
#'
#' The Department of Education, Skills and Employment quarterly regional
#' estimates of unemployment and the unemployment rate at the Statistical
#' Area Level 2 (SA2)
#'
#' @format A dataframe with 6 variables:
#' \describe{
#' \item{indicator}{One of Labour force total, Unemployment rate, Unemployed total}
#' \item{sa2_name_2016}{Name of the SA2 region}
#' \item{sa2_main_2016}{9 digit code representing the SA2 region}
#' \item{date}{Quarterly since December 2010}
#' \item{value}{Value of the indicator}
#' \item{state_name_2016}{State name}
#' }
#'
#' @source \url{https://www.employment.gov.au/small-area-labour-markets-publication-0}
"small_area_labour_market"

#' ABS Measures of Underutilisation
"underutilisation"

#' South Australia Historic Net Debt
"south_australia_net_debt"

#' ABS National Accounts 
"national_accounts"

#' Australian Manufacturing
"aus_manufacturing"

#' Industry value add
"national_accounts"

#' Internet Vacancies Regional
"internet_vacancy_regional"

#' Hours worked
"hours_worked"

#' Retail trade
"retail_trade"

#' Underemployment by industry
"industry_underemployment"

#' Underemployment by occupation
"occupation_underemployment"

#' Experimental household spending
"household_spending"




