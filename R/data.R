#' Australian and New Zealand Standard Industrial Classification (ANZSIC)
#'
#' A dataset containing the industry divisions, subdivisions, groups, and classes of the
#' 2006 ANZSIC organised heirarchically
#'
#' @format A dataframe with 506 rows and 4 variables:
#' \describe{
#' \item{division}{industry division}
#' \item{subdivision}{subdivision of division}
#' \item{group}{group of subdivision}
#' \item{class}{class of group}
#' }
#'
#' @source \url{https://www.abs.gov.au/AUSSTATS/abs@.nsf/Lookup/1292.0.55.002Main+Features12006?OpenDocument}
#'
"anzsic"

#' Counts of Australian Businesses, including Entries and Exists, June 2015 to June 2019
#'
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

#' COVID-19 Geographic data
#'
#' A dataset containing the jobkeeper applications, jobseeker payments, and derived impact from COVID-19 at
#' a geographical level. Jobkeeper and Jobseeker data is based on the SA2 classiciation, and employment
#' impact is based on the SA4 classification. This dataset combines data from jobseeker_sa2, jobkeeper_sa2,
#' payroll_sa4, and small_area_labour_market datasets and is intended for use on the AITI Economic
#' Indicators dashboard.
#'
#' @format A dataframe with 6 variables:
#' \describe{
#' \item{date}{Date}
#' \item{state_name_2016}{State name}
#' \item{indicator}{COVID-19 indicators}
#' \item{value}{Value}
#' \item{statistical_area}{Number of digits in statistical area}
#' \item{statistical_area_code}{Statistical area code}
#' }
#'
"covid_data"

#' Australian Subnational Economic Complexity
#'
#' A dataset containing economic complexity indicators
#' for Australian states and territories
#'
#' @format A dataframe with 704 observations and 4 variables
#' \describe{
#' \item{location_code}{state or territory abbreviation}
#' \item{year}{Year}
#' \item{indicator}{Place specific economic complexity indicator (diversity, eci, coi, total exports)}
#' \item{value}{Value of indicator}
#' }
#'
"economic_complexity"

#' ABS Employment by Industry
#'
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
"employment_by_industry"

#' ABS Detailed employment by industry
"employment_by_industry_detailed"


#' Internet Vacancies Index
#'
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
"internet_vacancies_index"

#' JobKeeper data by SA2
#'
#' This dataset uses treasury estimates of JobKeeper applications by
#' postcode, and reconciles that to a statistical area measure instead.
#' Conversion is done through apportioning businesses via meshblocks.
#'
#' @format A dataframe with 4 variables
#' \describe{
#' \item{sa2_main_2016}{Statistical Area 2 Code}
#' \item{date}{Date}
#' \item{indicator}{Jobkeeper applications, Total businesses, Jobkeeper proportion}
#' \item{value}{Value}
#' }
#'
#' @source \url{https://treasury.gov.au/coronavirus/jobkeeper/data}
#'
"jobkeeper_sa2"

#' JobSeeker data by SA2
#'
#' Department of Social Services estimates of monthly jobseeker and
#' youth allowance payments since March 2020.
#'
#' @format A dataframe with 4 variables
#' \describe{
#' \item{sa2_main_2016}{Statistical Area 2 Code}
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
#' @format A dataframe with 10 variables
#' \describe{
#' \item{date}{Date}
#' \item{month}{Month}
#' \item{year}{Year}
#' \item{prefix}{Prefix on the indicator - safe to ignore}
#' \item{indicator}{Labour account indicator}
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
#' @format A dataframe with 10 variables:
#' \describe{
#' \item{date}{date of survey}
#' \item{year}{year of survey}
#' \item{month}{month of survey}
#' \item{gender}{gender of individual surveyed: persons, male, or female}
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

#' ABS Weekly Payroll Index for SA3 
#'
#' ABS Weekly Payroll data for Statistical Area 4 Regions
#'
#' @format A dataframe with 5 variables:
#' \describe{
#' \item{state_name_2016}{State}
#' \item{date}{Date}
#' \item{value}{Number of payroll jobs - indexed to March 14th 2020}
#' \item{indicator}{This dataset contains only the payroll index data}
#' }
#'
#' @source \url{https://www.abs.gov.au/ausstats/abs@.nsf/mf/6160.0.55.001}
"payroll_substate"

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

#' Jobkeeper applications by state
#' 
#' The Australian Treasury collected and reported on the number of
#' businesses within a postcode who were receiving the temporary jobkeeper
#' supplement between April 2020 and March 2021. Data are provided by postcode and
#' postcodes with less than 5 businesses receiving jobkeeper are suppressed. 
#' Data are converted from postcode to Statistical Area 2, then grouped by state. 
#' 
#' @format A dataframe with 10 variables:
#' \describe{
#' \item{state}{Name of the state}
#' \item{date}{Monthly between April 2020 and March 2021}
#' \item{month}{Name of the month}
#' \item{year}{Year}
#' \item{indicator}{One of Jobkeeper applications, Total businesses, Jobkeeper proportion}
#' \item{value}{Value of the indicator}
#' \item{unit}{Units of the data}
#' }
"jobkeeper_state"

#' Jobkeeper applications by sa2
#' 
#' The Australian Treasury collected and reported on the number of
#' businesses within a postcode who were receiving the temporary jobkeeper
#' supplement between April 2020 and March 2021. Data are provided by postcode and
#' postcodes with less than 5 businesses receiving jobkeeper are suppressed. 
#' Data are converted from postcode to Statistical Area 2. 
#' 
#' @format A dataframe with 10 variables:
#' \describe{
#' \item{sa2_code_2016}{9 digit code representing the Statistical Area Level 2 the business is located in}
#' \item{date}{Monthly between April 2020 and March 2021}
#' \item{month}{Name of the month}
#' \item{year}{Year}
#' \item{indicator}{One of Jobkeeper applications, Total businesses, Jobkeeper proportion}
#' \item{value}{Value of the indicator}
#' \item{unit}{Units of the data}
#' }
"jobkeeper_sa2"

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

#' Seek Job Ads
"seek_data"

#' Internet Vacancies Regional
"internet_vacancies_regional"

#' Facebook Mobility
"mobility_facebook"

#' aitidata Catalogues
"aitidata_catalogues"

#'jobseeker state
"jobseeker_state"

#'Facebook mobility
"mobility_facebook"

#' Google mobility
"mobility_google"

#' Hours worked
"hours_worked"

#' Internet vacancy regions
"internet_vacancy_regions"

#' Retail trade
"retail_trade"




