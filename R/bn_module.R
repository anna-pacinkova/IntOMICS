#' #' BN module
#' @description
#' `bn_module` Performs automatically tuned MCMC sampling from posterior 
#' distribution together with conventional MCMC sampling using empirical
#' biological prior matrix to sample network structures from posterior
#' distribution.
#' @param burn_in numeric vector the minimal length of burn-in period 
#' of the MCMC simulation.
#' @param thin numeric vector thinning frequency of the resulting MCMC
#' simulation.
#' @param OMICS_mod_res list output from the omics_module function.
#' @param minseglen numeric vector minimal number of iterations 
#' with the c_rms value below the c_rms threshold.
#' @param len numeric vector initial width of the sampling interval 
#' for hyperparameter beta.
#' @param prob_mbr numeric vector probability of the MBR step.
#'
#' @examples
#' data("OMICS_mod_res", package="IntOMICS")
#' if(interactive()){BN_mod_res <- bn_module(burn_in = 10000, 
#'     thin = 500, OMICS_mod_res = OMICS_mod_res, 
#'     minseglen = 500, len = 5, prob_mbr = 0.07)}
#' 
#' @return Large List of 3 elements: empirical biological matrix, 
#' sampling phase result and hyperparameter beta tuning trace
#' @export
bn_module <- function(burn_in, thin, OMICS_mod_res, minseglen, len = 5,
    prob_mbr = 0.07) {
    energy_all_configs_node <- 
    OMICS_mod_res$pf_UB_BGe_pre$energy_all_configs_node
    BGe_score_all_configs_node <- 
    OMICS_mod_res$pf_UB_BGe_pre$BGe_score_all_configs_node
    parent_set_combinations <- 
    OMICS_mod_res$pf_UB_BGe_pre$parents_set_combinations
    annot <- OMICS_mod_res$annot
    ### 1st adaption phase ###
    first.adapt.phase_net <- first_adapt_phase(len = len,
        omics = OMICS_mod_res$omics, annot = annot,
        B_prior_mat = OMICS_mod_res$B_prior_mat, prob_mbr = prob_mbr, 
        energy_all_configs_node = energy_all_configs_node,
        layers_def = OMICS_mod_res$layers_def,
        BGe_score_all_configs_node = BGe_score_all_configs_node,
        parent_set_combinations = parent_set_combinations)
    ### transient phase ###
    transient.phase_net <- transient_phase(omics = OMICS_mod_res$omics,
        first.adapt.phase_net = first.adapt.phase_net, 
        B_prior_mat = OMICS_mod_res$B_prior_mat, prob_mbr = prob_mbr,
        layers_def = OMICS_mod_res$layers_def, annot = annot,
        energy_all_configs_node = energy_all_configs_node, 
        BGe_score_all_configs_node = BGe_score_all_configs_node,
        parent_set_combinations = parent_set_combinations)
    ### 2nd adaption phase ###
    second.adapt.phase_net <- second_adapt_phase(omics = OMICS_mod_res$omics,
        transient.phase_net = transient.phase_net, prob_mbr = prob_mbr,
        B_prior_mat = OMICS_mod_res$B_prior_mat, annot = annot,
        energy_all_configs_node = energy_all_configs_node, 
        layers_def = OMICS_mod_res$layers_def,
        BGe_score_all_configs_node = BGe_score_all_configs_node,
        parent_set_combinations = parent_set_combinations) 
    ### sampling phase ###
    sampling.phase_net <- sampling_phase(omics = OMICS_mod_res$omics,
        second.adapt.phase_net = second.adapt.phase_net, thin = thin,
        layers_def = OMICS_mod_res$layers_def, prob_mbr = prob_mbr,
        minseglen = minseglen, burn_in = burn_in, annot = annot)
    sampling.phase_net$mcmc_sim_part_res$seed1 <- 
    sampling.phase_net$mcmc_sim_part_res$seed1[c("betas","cpdags")]
    sampling.phase_net$mcmc_sim_part_res$seed2 <- 
    sampling.phase_net$mcmc_sim_part_res$seed2[c("betas","cpdags")]
    beta_tuning <- second.adapt.phase_net$betas
    return(list(sampling.phase_res = sampling.phase_net,
        B_prior_mat_weighted = second.adapt.phase_net$B_prior_mat_weighted, 
        beta_tuning = beta_tuning))
}