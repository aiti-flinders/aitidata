test_that("update_aus_manufacturing works", {
  pkg <- local_create_package()
  
  expect_true(update_aus_manufacturing(TRUE))
})
