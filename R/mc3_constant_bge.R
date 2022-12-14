#' Markov Chain conventional single edge proposal move with BGe score fixed
#' @description
#' `mc3_constant_bge` This function samples a conventional single edge proposal
#' move with ficed BGe score.
#' @param source_net list with adjacency matrix and other parameters needed 
#' for MCMC simulation.
#' @param omics named list containing the gene expression (possibly copy number
#' variation and methylation data). Each component of the list is a matrix 
#' with samples in rows and features in columns.
#' @param layers_def data.frame containing the modality ID, corresponding layer
#' in BN and maximal number of parents from given layer to GE nodes.
#' @param B_prior_mat a biological prior matrix.
#' @param beta.source named list with hyperparameter beta value and other
#' parameters needed for MCMC simulation.
#' @param partition_func_UB_beta_source numeric vector the upper bound 
#' of the partition function needed to define the prior distribution 
#' of network structure.
#' @param parent_set_combinations list of all possible parent set configuration
#' for all nodes available.
#' @param BGe_score_all_configs_node list of nodes BGe score for all possible
#' parent set configurations.
#' @param annot named list containing the associated methylation probes 
#' of given gene.
#' @return List of 10 elements needed to define adjacency matrix 
#' with conventional single edge move
mc3_constant_bge <- function(source_net, omics, layers_def, B_prior_mat, 
beta.source, partition_func_UB_beta_source, parent_set_combinations, 
BGe_score_all_configs_node, annot)
{
    ge_nodes <- rownames(source_net$adjacency)[regexpr("EID",
        rownames(source_net$adjacency))>0]
    vec <- seq_len(length(c(source_net$adjacency)))
    vec <- vec[c(B_prior_mat)>0]
    edge_proposal_res <- edge_proposal(omics = omics,
        net = source_net$adjacency, candidates = vec, layers_def = layers_def,
        ge_nodes = ge_nodes, B_prior_mat = B_prior_mat)
    while(edge_proposal_res$no_action | !is_acyclic(edge_proposal_res$net))
    {
        vec <- vec[vec!=edge_proposal_res$edge]
        edge_proposal_res <- edge_proposal(net = source_net$adjacency,
            candidates = vec, layers_def = layers_def, ge_nodes = ge_nodes, 
            omics = omics, B_prior_mat = B_prior_mat)
    } # end while(edge_proposal_res$no_action...
    nbhd.size <- neighborhood_size(net = edge_proposal_res$net, 
        layers_def = layers_def, B_prior_mat = B_prior_mat, omics = omics)
    energy <- sum(epsilon(net = edge_proposal_res$net, 
        B_prior_mat = B_prior_mat))
    prior <- (-beta.source$value*energy) - partition_func_UB_beta_source
    likelihood_part <- source_net$BGe + prior
    return(list(adjacency = edge_proposal_res$net, nbhd.size = nbhd.size, 
        proposal.distr = c(), energy = energy, prior = prior, likelihood = c(),
        BGe = source_net$BGe, likelihood_part = likelihood_part,
        acceptance = c(), edge_move = edge_proposal_res$edge_move))
}
