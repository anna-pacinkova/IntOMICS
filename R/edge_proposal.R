#' Markov Chain conventional single edge proposal move
#' @description
#' `edge_proposal` This function samples a conventional single edge proposal
#' moves (identify those edges that are possible to change in given network
#' structure)
#' @param net adajcency matrix of given network.
#' @param candidates numeric vector with IDs of potential edge to be changed.
#' @param layers_def data.frame containing the modality ID, corresponding layer
#' in BN and maximal number of parents from given layer to GE nodes.
#' @param ge_nodes character vector with GE node names
#' @param omics named list containing the gene expression (possibly copy number
#' variation and methylation data). 
#' Each component of the list is a matrix with samples in rows and features 
#' in columns.
#' @param B_prior_mat a biological prior matrix.
#' @return List of 6 elements needed to define candidates for conventional
#' single edge proposal move            
edge_proposal <- function(net, candidates, layers_def, ge_nodes, omics,
B_prior_mat) {
    edge <- sample(candidates,1); div <- nrow(net); row <- edge %% div
    if(row==0)
    {
        row <- div; col <- edge %/% div
    } else {
        col <- edge %/% div + 1
    } # end if else (row==0)
    no_action <- FALSE
    if(net[edge]==1)
    {
        if(B_prior_mat[col,row]>0 &
            sum(net[ge_nodes,row])<layers_def$fan_in_ge[
            which.max(layers_def$layer)])
        {
            edge_move <- sample(c("delete","reverse"),1)
            if(edge_move=="delete")
            {
                net[edge] <- 0
            } else {
                net[col,row] <- 1; net[row,col] <- 0
            } # end if else (edge_move=="delete")
        } else {
            edge_move <- "delete"; net[edge] <- 0
        } # end if else ()
    } else {
        edge_move <- "add"
        candidate_layer <- names(which(mapply(omics,FUN=function(mat) 
            length(intersect(colnames(mat),rownames(net)[col]))==1)==TRUE))
        if(candidate_layer==layers_def$omics[which.max(layers_def$layer)])
        {
            if(sum(net[ge_nodes,col])<layers_def$fan_in_ge[
                which.max(layers_def$layer)])
            {
                net[edge] <- 1
            } else {
                no_action <- TRUE
            } # end if(source_net_adjacency[edge]==0 ...
        } else {
            if(regexpr("eid",rownames(net))>0)
            {
                net[edge] <- 1
            } else {
                if(sum(net[colnames(omics[[candidate_layer]]),
                    col])<layers_def$fan_in_ge[layers_def$omics==
                    candidate_layer])
                {
                    net[edge] <- 1
                } else {
                    no_action <- TRUE
                }
            } # end if else (regexpr("eid",rownames(net))>0)
        } # end if else (candidate_layer==layers_def$omics...
    } # end if else (net[edge]==1)
    return(list(net = net, edge = edge, no_action = no_action, row = row, 
        col = col, edge_move = edge_move))
}
