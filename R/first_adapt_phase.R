#' 1st adaption phase
#' @description
#' `first_adapt_phase` 1st adaption phase of the adaptive MCMC: 
#' the variance of the proposal distribution is changed to achieve 
#' the MC acceptance rate of 0.44.
#' @param omics named list containing the gene expression 
#' (possibly copy number variation and methylation data). 
#' Each component of the list is a matrix with samples in rows and 
#' features in columns.
#' @param B_prior_mat a biological prior matrix.
#' @param energy_all_configs_node list of nodes energy for all possible 
#' parent set configurations.
#' @param len numeric vector initial width of the sampling interval 
#' for hyperparameter beta.
#' @param layers_def data.frame containing the modality ID, corresponding 
#' layer in BN and maximal number of parents from given layer to GE nodes.
#' @param prob_mbr numeric vector probability of the MBR step.
#' @param BGe_score_all_configs_node list of nodes BGe score 
#' for all possible parent set configurations.
#' @param parent_set_combinations list of all possible parent set 
#' configuration for all nodes available.
#' @param annot named list containing the associated methylation 
#' probes of given gene.
#' @return List of 1 element: first adaption phase result
first_adapt_phase <- function(omics, B_prior_mat, energy_all_configs_node, 
len, layers_def, prob_mbr, BGe_score_all_configs_node, 
parent_set_combinations, annot) {
    init.net1 <- init_net_mcmc(omics = omics, layers_def = layers_def,
    B_prior_mat = B_prior_mat)
    first.adapt.phase_net <- source_net_def(omics = omics, len = len,
        init_net_mcmc.output = init.net1, 
        parent_set_combinations = parent_set_combinations,
        BGe_score_all_configs_node = BGe_score_all_configs_node,
        B_prior_mat = B_prior_mat, layers_def = layers_def,
        energy_all_configs_node = energy_all_configs_node)
    first.adapt.phase_net <- acceptance_check(round_check = 100,
        first.adapt.phase_net = first.adapt.phase_net, 
        last_iter_check = 100, prob_mbr = prob_mbr, 
        layers_def = layers_def, omics = omics, annot = annot, 
        parent_set_combinations = parent_set_combinations, 
        BGe_score_all_configs_node = BGe_score_all_configs_node)
    first.adapt.phase_net <- acceptance_check(round_check = 100,
        first.adapt.phase_net = first.adapt.phase_net, 
        last_iter_check = 200, omics = omics, annot = annot, 
        prob_mbr = prob_mbr, layers_def = layers_def, 
        parent_set_combinations = parent_set_combinations, 
        BGe_score_all_configs_node = BGe_score_all_configs_node)
    first.adapt.phase_net <- acceptance_check(round_check = 200,
        first.adapt.phase_net = first.adapt.phase_net, 
        last_iter_check = 400, prob_mbr = prob_mbr, 
        layers_def = layers_def, omics = omics, annot = annot,
        parent_set_combinations = parent_set_combinations, 
        BGe_score_all_configs_node = BGe_score_all_configs_node)
    return(first.adapt.phase_net)
}
