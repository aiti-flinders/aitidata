Sys.setenv("R_TESTS" = "") #To fix r-cmd-check failing online but working locally as per: https://github.com/r-lib/testthat/issues/86

library(testthat)
library(aitidata)

test_check("aitidata")
