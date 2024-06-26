% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{jobkeeper_sa2}
\alias{jobkeeper_sa2}
\title{JobKeeper data by SA2}
\format{
A dataframe with 4 variables
\describe{
\item{sa2_main_2016}{Statistical Area 2 Code}
\item{date}{Date}
\item{indicator}{Jobkeeper applications, Total businesses, Jobkeeper proportion}
\item{value}{Value}
}

A dataframe with 10 variables:
\describe{
\item{sa2_code_2016}{9 digit code representing the Statistical Area Level 2 the business is located in}
\item{date}{Monthly between April 2020 and March 2021}
\item{month}{Name of the month}
\item{year}{Year}
\item{indicator}{One of Jobkeeper applications, Total businesses, Jobkeeper proportion}
\item{value}{Value of the indicator}
\item{unit}{Units of the data}
}
}
\source{
\url{https://treasury.gov.au/coronavirus/jobkeeper/data}
}
\usage{
jobkeeper_sa2

jobkeeper_sa2
}
\description{
This dataset uses treasury estimates of JobKeeper applications by
postcode, and reconciles that to a statistical area measure instead.
Conversion is done through apportioning businesses via meshblocks.

The Australian Treasury collected and reported on the number of
businesses within a postcode who were receiving the temporary jobkeeper
supplement between April 2020 and March 2021. Data are provided by postcode and
postcodes with less than 5 businesses receiving jobkeeper are suppressed.
Data are converted from postcode to Statistical Area 2.
}
\keyword{datasets}
