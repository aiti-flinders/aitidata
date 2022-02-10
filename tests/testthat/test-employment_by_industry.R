test_that("employment_by_industry can be updated", {
  pkg <- local_create_package()
  
  expect_true(update_employment_by_industry(TRUE))
})
