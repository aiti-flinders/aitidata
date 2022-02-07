test_that("update_abs still works", {
  skip_if_offline()
  skip_on_cran()

  expect_true(aitidata::update_employment_by_industry())
  expect_true(aitidata::update_labour_force())
  expect_true(aitidata::update_cabee_sa2())
  expect_true(aitidata::update_internet_vacancies_regional())
  expect_true(aitidata::update_aus_manufacturing())
  expect_true(aitidata::update_labour_account())
  expect_true(aitidata::update_mobility_facebook())
  expect_true(aitidata::update_national_accounts())
  expect_true(aitidata::update_payroll_index())
  expect_true(aitidata::update_payroll_substate())
  expect_true(aitidata::update_retail_trade())
  expect_true(aitidata::update_underutilisation())
  expect_true(aitidata::update_covid_data())
  
  
})
