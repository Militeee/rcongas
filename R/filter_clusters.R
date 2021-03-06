

#' Filter output clusters
#'
#' @description From a CONGAS fit object remove clusters that do not pass filters.
#' These include number of cells and abundance of cluster (mixing proportions). This function the assigns the 
#' cells back to the most similar remaining cluster. In case the inference was performed using MAP we choose the cluster with
#' the most similar CNV profile (based on euclidean distance), otherwise we assign the cell to the cluster with second highest 
#' probability and renormalize the z.
#'
#'
#' @param x Rcongas object
#' @param ncells minimum size of a valid cluster expressed as absolute number of cells
#' @param abundance minimum size of a cluster expressed as a percentage of the total cell number 
#'
#' @return
#' @export
#'
#' @examples
#'
#' x = Rcongas::congas_example
#'
#' print(x)
#'
#' # Equivalent filters for this model
#' x %>% filter_clusters(abundance = .5)
#'
#' x %>% filter_clusters(ncells = 150)
#'
#' 
filter_clusters  <- function(x, ncells = 10, abundance = 0.03) {


  x$inference$models <-
    lapply(x$inference$models, function(x)
      filter_cluster_aux(x , ncells = ncells, abundance = abundance))
  x <- recalculate_information_criteria(x, x$inference$model_selection$IC_type)

  return(x)
  
}

filter_cluster_aux <- function(x, ncells, abundance) {

  if(length(x$parameters$mixture_weights) == 1) return(x)

  ta <-  table(x$parameters$assignement)

  diff_len <-  length(x$parameters$mixture_weights) - length(ta)

  if( diff_len != 0 ){ ta <- c(ta, rep(x = 0, diff_len))}


  mask <-  (x$parameters$mixture_weights > abundance) | (ta > ncells)

  nremoved <-  sum(!mask)
  
  if(nremoved == 0) return(x)
  
  
  cli::cli_alert_warning("Filtering {nremoved} cluster{?s} due to low cell counts or abudance")
  
  x$parameters$mixture_weights <- x$parameters$mixture_weights[mask] / sum(x$parameters$mixture_weights[mask])
  cnv_probs_new <- x$parameters$cnv_probs[mask,, drop = FALSE]



  
  cli::cli_alert_info("Reculcating cluster assignement and renormalizing posterior probabilities")


  x$parameters$assignment_probs <- x$parameters$assignment_probs[,mask, drop = FALSE] 
  x$parameters$assignment_probs <- exp(log(x$parameters$assignment_probs)  - log(rowSums(x$parameters$assignment_probs)))
  x$parameters$assignement <- apply(x$parameters$assignment_probs, 1,function(y) names(x$parameters$mixture_weights)[which.max(y) %>%  as.numeric]) %>%  as.character()
  x$parameters$assignement[x$parameters$assignement == "character(0)"] <- "c1"
  names(x$parameters$assignement) <-  rownames(x$parameters$assignment_probs)

  x$parameters$cnv_probs <- cnv_probs_new

  return(x)

}
