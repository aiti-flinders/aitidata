test_that("update cabee_sa2 works", {
  pkg <- local_create_package()
  
  expect_true(update_cabee_sa2(TRUE))
})
