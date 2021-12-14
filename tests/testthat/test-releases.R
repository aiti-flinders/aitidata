test_that("release dates can be found", {
  expect_error(abs_current_release())
  expect_s3_class(abs_current_release(cat_string = "labour-force-australia", url = NULL), "Date")
})
