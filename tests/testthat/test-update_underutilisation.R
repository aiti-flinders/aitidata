test_that("update_underutilisation works", {
  pkg <- local_create_package()
  
  expect_true(update_underutilisation(TRUE))
})
