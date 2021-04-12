test_that("release date functions return a date", {
  testthat::skip_if_offline()
  library(lubridate)
  expect_true(is.Date(abs_current_release("labour-force-australia")))
  expect_true(is.Date(abs_current_release("labour-force-australia")))
  expect_true(is.Date(abs_current_release("labour-force-australia-detailed")))
  expect_true(is.Date(abs_current_release("labour-force-australia-detailed")))
  expect_true(is.Date(abs_next_release("labour-force-australia")))
  expect_true(is.Date(abs_next_release("labour-force-australia")))
  expect_true(is.Date(abs_next_release("labour-force-australia-detailed")))
  expect_true(is.Date(abs_next_release("labour-force-australia-detailed")))
  
})
