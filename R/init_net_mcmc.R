#' Random initial network
#' @description
#' `init_net_mcmc` This function is used to sample random initial network. 
#' The edges are sampled only between GE nodes.
#' @param omics named list containing the gene expression (possibly copy number
#' variation and methylation data). Each component of the list is a matrix 
#' with samples in rows and features in columns.
#' @param layers_def data.frame containing the modality ID, corresponding layer
#' in BN and maximal number of parents from given layer to GE nodes.
#' @param B_prior_mat a biological prior matrix.
#' @importFrom methods setClass
#' @importFrom bnstruct dag<-
#' @return List of 2 elements: random adjacency network and empty network
init_net_mcmc <- function(omics, layers_def, B_prior_mat)
{
    empty.net <- matrix(0, nrow = sum(mapply(ncol,omics)), 
        ncol = sum(mapply(ncol,omics)),
        dimnames = list(unlist(mapply(colnames,omics)),
        unlist(mapply(colnames,omics))))
    init.net <- sample_chain(empty_net = empty.net, 
        omics_ge = omics[[layers_def$omics[1]]])
    rownames(dag(init.net)) <- rownames(empty.net)
    colnames(dag(init.net)) <- rownames(empty.net)
    dag(init.net) <- dag(init.net)[rownames(B_prior_mat),rownames(B_prior_mat)]
    if(any(dag(init.net)==1 & B_prior_mat==0))
    {
        dag(init.net)[dag(init.net)==1 & B_prior_mat==0] <- 0
    }
    while(!is_acyclic(dag(init.net)) |
    any(colSums(dag(init.net)[colnames(omics[[layers_def$omics[1]]]),
    colnames(omics[[layers_def$omics[1]]])]) > layers_def$fan_in_ge[1]))
    {
        init.net <- sample_chain(empty_net = empty.net, 
            omics_ge = omics[[layers_def$omics[1]]])
        rownames(dag(init.net)) <- rownames(empty.net)
        colnames(dag(init.net)) <- rownames(empty.net)
        dag(init.net) <- dag(init.net)[rownames(B_prior_mat),
            rownames(B_prior_mat)]
        if(any(dag(init.net)==1 & B_prior_mat==0))
        {
            dag(init.net)[dag(init.net)==1 & B_prior_mat==0] <- 0
        }
    }
    source.net <- list(adjacency = dag(init.net), nbhd.size = c(), 
        proposal.distr = c(), energy = c(), prior = c(), BGe = c(), 
        likelihood_part = c(), likelihood = c(), acceptance = c(), 
        edge_move = c())
    return(list(source.net = source.net, empty.net = empty.net))
}
