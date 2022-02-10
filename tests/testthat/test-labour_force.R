test_that("update_labour_force works", {
  pkg <- local_create_package()
  
  expect_true(update_labour_force(TRUE))
})
