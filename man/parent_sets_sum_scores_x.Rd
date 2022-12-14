% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parent_sets_sum_scores_x.R
\name{parent_sets_sum_scores_x}
\alias{parent_sets_sum_scores_x}
\title{MBR sum of scores}
\usage{
parent_sets_sum_scores_x(
  parent_set_combinations,
  selected_node,
  descendants,
  parent_set,
  BGe_score_all_configs_node
)
}
\arguments{
\item{parent_set_combinations}{list of all possible parent set configuration
for all nodes available.}

\item{selected_node}{character vector with given node name.}

\item{descendants}{character vector with descendants of selected_node
in given network structure.}

\item{parent_set}{character vector with parents of selected_node in given
network structure.}

\item{BGe_score_all_configs_node}{list of nodes BGe score for all possible
parent set configurations.}
}
\value{
List of 3 elements
}
\description{
\code{parent_sets_sum_scores_x} This function determines the sum of BGe scores
of given node's parents.
}
