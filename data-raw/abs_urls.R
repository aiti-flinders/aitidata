## code to prepare `abs_urls` dataset goes here
abs_urls <- data.frame(
  catalogue_string = c("labour-force-australia",
                       "australian-national-accounts-national-income-expenditure-and-product",
                       "weekly-payroll-jobs-and-wages-australia",
                       "labour-force-australia-detailed",
                       "labour-account-austraila",
                       "counts-australian-businesses-including-entries-and-exits",
                       "australian-industry"),
  url = c("https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/latest-release",
          "https://www.abs.gov.au/statistics/economy/national-accounts/australian-national-accounts-national-income-expenditure-and-product/latest-release",
          "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release",
          "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia-detailed/latest-release",
          "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-account-australia/latest-release",
          "https://www.abs.gov.au/statistics/economy/business-indicators/counts-australian-businesses-including-entries-and-exits/latest-release",
          "https://www.abs.gov.au/statistics/industry/industry-overview/australian-industry/latest-release")
)

usethis::use_data(abs_urls, overwrite = TRUE)
