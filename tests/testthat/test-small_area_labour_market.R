test_that("update_small_area_labour_market works", {
  pkg <- local_create_package()
  
  expect_true(update_small_area_labour_market(TRUE))
})
