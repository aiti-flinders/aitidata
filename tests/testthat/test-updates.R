test_that("update_abs still works", {
  skip_if_offline()
  skip_on_cran()
  
  # expect_s3_class(abs_next_release(cat_string = "labour-force-australia", url = NULL), "Date")
  expect_type(aitidata::update_abs(), type = "list")
})
