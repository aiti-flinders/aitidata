test_that("update_ functions work", {
  pkg <- local_create_package()
  expect_true(update_internet_vacancies_regional(TRUE))
  expect_true(update_small_area_labour_market(TRUE))
  expect_true(update_employment_by_industry(TRUE))
  expect_true(update_aus_manufacturing(TRUE))
  expect_true(update_mobility_facebook())
  expect_true(update_national_accounts(TRUE))
  expect_true(update_underutilisation(TRUE))
  expect_true(update_labour_account(TRUE))
  expect_true(update_jobseeker_sa2(TRUE))
  expect_true(update_labour_force(TRUE))
  expect_true(update_retail_trade(TRUE))
  expect_true(update_cabee_sa2(TRUE))
  expect_true(update_payroll_index(TRUE))
  expect_true(update_payroll_substate(TRUE))
  expect_true(update_covid_data())
})