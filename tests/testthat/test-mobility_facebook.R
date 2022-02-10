test_that("update_mobility_facebook works", {
  pkg <- local_create_package()
  
  expect_true(update_mobility_facebook(TRUE))
})
