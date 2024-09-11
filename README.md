
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aitidata

<!-- badges: start -->

[![R-CMD-check](https://github.com/aiti-flinders/aitidata/actions/workflows/R-CMD-check.yaml/badge.svg?branch=data_prep)](https://github.com/aiti-flinders/aitidata/actions/workflows/R-CMD-check.yaml)
[![update-abs](https://github.com/aiti-flinders/aitidata/workflows/update-abs/badge.svg)](https://github.com/aiti-flinders/aitidata/actions)

<!-- badges: end -->

`aitidata` is a collection of data sets commonly used by researchers at
the Australian Industrial Transformation Institute. Data is updated at
about 11:30am each day.

The current version of `aitidata` is 0.1.1

Data was last updated 2024-09-11

## Installation

You can install the latest version from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("aiti-flinders/aitidata")
```

## Included data

    #> Warning in max.default(structure(numeric(0), class = "Date"), na.rm = FALSE):
    #> no non-missing arguments to max; returning -Inf

| Data Name                    | Description                                                                           | Most Recent Data |
|:-----------------------------|:--------------------------------------------------------------------------------------|:-----------------|
| hours_worked                 | Hours worked                                                                          | 2024-07-01       |
| labour_force                 | ABS Labour Force Survey                                                               | 2024-07-01       |
| retail_trade                 | Retail trade                                                                          | 2024-07-01       |
| payroll_index                | ABS Weekly Payroll Index                                                              | 2024-06-15       |
| labour_account               | ABS Labour Account                                                                    | 2024-06-01       |
| national_accounts            | ABS National Accounts                                                                 | 2024-06-01       |
| industry_employment          | ABS Employment by Industry                                                            | 2024-05-01       |
| industry_employment_detailed | ABS Detailed employment by industry                                                   | 2024-05-01       |
| industry_underemployment     | Underemployment by industry                                                           | 2024-05-01       |
| occupation_underemployment   | Underemployment by occupation                                                         | 2024-05-01       |
| underutilisation             | ABS Measures of Underutilisation                                                      | 2024-05-01       |
| cabee_sa2                    | Counts of Australian Businesses, including Entries and Exists, June 2015 to June 2019 | 2023-07-01       |
| payroll_substate             | ABS Weekly Payroll Index for SA3                                                      | 2023-06-10       |
| covid_data                   | COVID-19 Geographic data                                                              | 2023-06-01       |
| jobseeker_sa2                | JobSeeker data by SA2                                                                 | 2023-06-01       |
| jobseeker_state              | jobseeker state                                                                       | 2023-06-01       |
| small_area_labour_market     | DESE Small (SA2) Area Labour Market                                                   | 2023-06-01       |
| internet_vacancies_index     | Internet Vacancies Index                                                              | 2022-10-01       |
| internet_vacancies_regional  | Internet Vacancies Regional                                                           | 2022-10-01       |
| mobility_facebook            | Facebook Mobility                                                                     | 2022-05-22       |
| mobility_google              | Google mobility                                                                       | 2021-12-03       |
| jobkeeper_sa2                | JobKeeper data by SA2                                                                 | 2021-03-01       |
| jobkeeper_state              | Jobkeeper applications by state                                                       | 2021-03-01       |
| household_spending           | Experimental household spending                                                       | -Inf             |
| abs_urls                     | Match ABS Catalogue names with URLS                                                   | NA               |
| anzsic                       | Australian and New Zealand Standard Industrial Classification (ANZSIC)                | NA               |
| aus_manufacturing            | Australian Manufacturing                                                              | NA               |
| economic_complexity          | Australian Subnational Economic Complexity                                            | NA               |
| internet_vacancy_regions     | Internet vacancy regions                                                              | NA               |
| seek_data                    | Seek Job Ads                                                                          | NA               |
| south_australia_net_debt     | South Australia Historic Net Debt                                                     | NA               |
