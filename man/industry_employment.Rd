% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{industry_employment}
\alias{industry_employment}
\title{ABS Employment by Industry}
\format{
A dataframe with 11 variables:
\describe{
\item{date}{Date}
\item{year}{Year}
\item{month}{Month}
\item{indicator}{Indicator}
\itemize{
\item{Employed total}
\item{Underemployed total}
\item{Underemployment ratio (proportion of employed)}
\item{Employed full-time}
\item{Employed part-time}
}
\item{industry}{Industry of employment}
\item{gender}{Gender}
\item{age}{Age}
\item{state}{State}
\item{series_type}{Level of adjustment of original data: original (no adjustment), seasonally adjusted, or trend}
\item{value}{Value of employment indicator}
\item{unit}{Unit of measurement for indiciator}
}
}
\source{
\url{https://www.abs.gov.au/ausstats/abs@.nsf/PrimaryMainFeatures/6291.0.55.001?OpenDocument}
}
\usage{
industry_employment
}
\description{
A dataset containing quarterly national and sub-national employment indicators
by industry of employment since February 1991.
}
\keyword{datasets}
