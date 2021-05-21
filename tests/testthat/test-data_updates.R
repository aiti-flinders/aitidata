test_that("abs_next_release works", {
  testthat::skip_if_offline()
  testthat::skip_on_cran()
  
  # expect_s3_class(abs_next_release(cat_string = "labour-force-australia", url = NULL), "Date")
  expect_s3_class(abs_next_release(cat_string = NULL, url = "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/latest-release"), "Date")
  expect_warning(abs_next_release(cat_string = 'labour-force-australia', url = "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/latest-release"))
  expect_error(abs_next_release())
})