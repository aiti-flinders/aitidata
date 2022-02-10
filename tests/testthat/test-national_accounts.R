test_that("update_national_accounts works", {
  pkg <- local_create_package()
  
  expect_true(update_national_accounts(TRUE))
})
