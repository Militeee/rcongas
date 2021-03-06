% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulation.R
\name{change_spot}
\alias{change_spot}
\title{Add a deletion or an insertion in a given segment}
\usage{
change_spot(parent_ploidy, mutation_spots, changes)
}
\arguments{
\item{parent_ploidy}{vector of integers, CNV value in the parent clone}

\item{mutation_spots}{vector of integers, index of the segmnts to be changed in the parent}

\item{changes}{vector of integers, allowed values for deletion and amplification}
}
\value{
the vector with the new subclonal ploidy
}
\description{
Add a deletion or an insertion in a given segment
}
