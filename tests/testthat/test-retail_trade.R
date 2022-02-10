test_that("update_retail_trade works", {
  pkg <- local_create_package()
  
  expect_true(update_retail_trade(TRUE))
})
