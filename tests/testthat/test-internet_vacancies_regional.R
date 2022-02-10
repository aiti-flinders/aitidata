test_that("update_internet_vacancies_regional works", {
  pkg <- local_create_package()
  
  expect_true(update_internet_vacancies_regional(TRUE))
})
