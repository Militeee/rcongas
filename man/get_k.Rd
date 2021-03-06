% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_k.R
\name{get_k}
\alias{get_k}
\title{Extract the number of mixture components.}
\usage{
get_k(x)
}
\arguments{
\item{x}{Input object with clusters.}
}
\value{
A scalar.
}
\description{
Returns \code{k>0} for the best mixture available in the
object.
}
\examples{
x = Rcongas::congas_example
get_k(x)
}
