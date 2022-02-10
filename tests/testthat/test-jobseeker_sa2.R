test_that("update_jobseeker_sa2 works", {
  pkg <- local_create_package()
  
  expect_true(update_jobseeker_sa2(TRUE))
})
