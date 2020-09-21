library(dplyr)

abs_cats <- tibble::tribble(
  ~cat_no, ~theme, ~parent_topic, ~topic, ~tables,  ~data_name, 
  "6202.0","labour", "employment-and-unemployment", "labour-force-australia", list("12" = "Labour force status by Sex, State and Territory", 
                                            "19" = "Monthly hours worked in all jobs (Extrapolated): by Employed full-time, part-time and Sex and by State and Territory",
                                            "22" = "Underutilised persons by Age and Sex",
                                            "23" = "Underutilised persons by State and Territory and Sex"), "labour_force",
  "5206.0","economy", "national-accounts", "australian-national-accounts-national-income-expenditure-and-product", list("1" = "Key National Accounts Aggregates",
                                                                                           "6" = "Gross Value Added by Industry"), "national_accounts",
  "6160.0.55.001", "labour", "earnings-and-work-hours", "weekly-payroll-jobs-and-wages-australia", list("4" = "Payroll Jobs and Wages Indexes"), "payroll_index",
  "6160.0.55.001", "labour", "earnings-and-work-hours", "weekly-payroll-jobs-and-wages-australia", list("5" = "Statistical Area 4 and Industry subdivision"), "payroll_sa4",
  "6291.0.55.001", "labour", "employment-and-unemployment", "labour-force-australia-detailed-quarterly", list("5" = "Employed persons by State, Territory and Industry division of main job (ANZSIC)",
                                                             "19" = "Underemployed persons by Industry division (ANZSIC), Occupation major group (ANZSCO) of main job and Sex"), "employment_by_industry",
  "6291.0.55.001", "labour", "employment-and-unemployment", "labour-force-australia-detailed-quarterly", list("23a" = "Volume measures of underutilisation by State, Territory and Sex",
                                                             "23b" = "Volume measures of underutilisation by Age and Sex"), "underutilisation",
  "6150.0.55.003", "labour", "employment-and-unemployment", "labour-account-australia", list("1" = "Total All Industries"), "labour_account",
  "8165.0","economy", "business-indicators", "counts-australian-businesses-including-entries-and-exits", list("8" = "Businesses by Industry Division by Statistical Area Level 2 by Employment Size Ranges"), "cabee_sa2")

abs_cats <- tidyr::unnest_longer(abs_cats, col = tables) %>% 
  dplyr::rowwise() %>%   
  dplyr::mutate(next_release = abs_next_release(topic = topic, theme = theme, parent_topic = parent_topic))

non_abs_cats <- tibble::tribble(
  ~url, ~xpath,  ~title, ~data_name, 
  "https://data.gov.au/data/dataset/728daa75-06e8-442d-931c-93ecc6a57880", "//*[@id='content']/div[3]/div/article/div/section[3]/table/tbody/tr[9]/td", "JobSeeker Payment and Youth Allowance recipients - monthly profile", "jobseeker_sa2",
  "https://treasury.gov.au/coronavirus/jobkeeper/data", '//*[@id="block-mainpagecontent-2"]/div/article/div/div/table/tbody/tr/td[2]/p/font', "JobKeeper postcode data", "jobkeeper_sa2",
  "https://www.employment.gov.au/small-area-labour-markets-publication-0", '//*[@id="node-10604"]/div/div/div/div/h2[1]', "Small Area Labour Markets publication", "small_area_labour_market"
  ) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(next_release = xml2::read_html(url) %>% rvest::html_nodes(xpath = xpath) %>% rvest::html_text()) 
                
                
                
usethis::use_data(abs_cats,  internal = TRUE, compress = 'xz', overwrite = TRUE)
