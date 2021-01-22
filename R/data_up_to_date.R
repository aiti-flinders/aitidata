#' Checks that installed version of daitir has
#' up to date data
#'
#' @return A message describing the up-to-date-ness of the installed package.
#' @export data_up_to_date
#'
data_up_to_date <- function() {
  up_to_dateness <- build_daitir() %>%
    dplyr::filter(mtime < current_release | is.na(mtime))
  
  if (nrow(up_to_dateness) == 0) {
    message("All data appears to be up to date! Get to work!")
  } else {
    message(sprintf("The following data appears to be out of date.\n%s\nPlease download the latest version of daitir using:\n\ndevtools::install_github('hamgamb/daitir')", unique(up_to_dateness$catalogue_string)))
  }
}