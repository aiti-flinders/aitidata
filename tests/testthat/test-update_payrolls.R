test_that("update_payroll functions work", {
  pkg <- local_create_package()
  
  expect_true(update_payroll_index(TRUE))
  expect_true(update_payroll_substate(TRUE))
})
