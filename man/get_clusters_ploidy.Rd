% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_clusters_ploidy.R
\name{get_clusters_ploidy}
\alias{get_clusters_ploidy}
\title{Extract the clusters ploidy profiles.}
\usage{
get_clusters_ploidy(
  x,
  chromosomes = paste0("chr", c(1:22, "X", "Y")),
  clusters = NULL,
  offset_amplitude = TRUE,
  alpha = 0.05
)
}
\arguments{
\item{x}{Input object with clusters.}

\item{chromosomes}{Chromosome id to subset.}

\item{clusters}{Cluster id to subset.}

\item{offset_amplitude}{If TRUE, normalise CNA values for comparisons (z-score alike)}

\item{alpha}{The parameter to select what to highlight.}
}
\value{

}
\description{
Extract the clone ploidy profiles from a fit object.
It can subset by chromosomes, cluster and select what to highlight
based on a parameter (alpha)
}
\examples{

x = Rcongas::congas_example

# Default view
x \%>\% get_clusters_ploidy()

# Subset by chromosome
x \%>\% get_clusters_ploidy(chromosomes = 'chr1')

# Subset by cluster id and chromosome
x \%>\% get_clusters_ploidy(chromosomes = 'chr1', clusters = "c1")

# Change parameter to find what is most relevant
x \%>\% get_clusters_ploidy(alpha = 0.1)
}
