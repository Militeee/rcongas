% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_raw_data.R
\name{plot_raw_data}
\alias{plot_raw_data}
\title{Title}
\usage{
plot_raw_data(
  x,
  genes,
  lognormalise = TRUE,
  description = "My CONGAS model",
  clusters = NULL,
  prompt = TRUE,
  ...
)
}
\arguments{
\item{x}{}

\item{genes}{}

\item{lognormalise}{}

\item{description}{}

\item{clusters}{}

\item{prompt}{}

\item{...}{}
}
\value{

}
\description{
Title
}
\examples{

x = Rcongas::congas_example

print(x)

# Extract raw data
raw_x = get_input_raw_data(x)

# Get some genes to plot from those with DE
genes = get_DE_table(x) \%>\% pull(gene)

# Get clusters
clusters = get_clusters(x)

# Default plot (without prompt for automatic documentation generation)
plot_raw_data(raw_x, genes, prompt = FALSE)
}
