test_that("update_covid_data works", {
  pkg <- local_create_package()
  
  expect_true(update_covid_data())
})
