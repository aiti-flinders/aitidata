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

#'ABS Employment by Industry
#'
#'A dataset containing quarterly national and sub-national employment indicators
#'by industry of employment since February 1991. 
#'
#'@format A dataframe with 11 variables:
#'\describe{
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



