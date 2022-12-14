% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fan_in_reverse.R
\name{fan_in_reverse}
\alias{fan_in_reverse}
\title{Number of reverse edge candidates}
\usage{
fan_in_reverse(positions, net_layer_max, layers_def)
}
\arguments{
\item{positions}{character vector indicating the interaction between two
nodes (the first string indicates the source node, the second string
indicates the target node).}

\item{net_layer_max}{adjacency matrix of the network containing only GE
nodes.}

\item{layers_def}{data.frame containing the modality ID, corresponding layer
in BN and maximal number of parents from given layer to GE nodes.}
}
\value{
Numeric vector of length 1: reverse edge candidates
}
\description{
\code{fan_in_reverse} Determine the number of edges that can be reversed using
the fan-in restriction in the largest layer.
}
