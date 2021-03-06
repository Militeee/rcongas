#' Summary for an object of class \code{'rcongas'}.
#'
#' @description The summary is equivalent to a \code{print}.
#'
#' @param x Object of class \code{'rcongas'}.
#' @param ... Extra parameters.
#'
#' @return See \code{\link{print}}.
#'
#' @exportS3Method summary rcongas
#'
#' @examples
#' data(fit_example)
#' summary(fit_example$best)
summary.rcongas = function(object, ...) {
  print.rcongas(object, ...)
}

#' Print for an object of class \code{'rcongas'}.
#'
#' @param x Object of class \code{'rcongas'}.
#' @param ... Extra parameters.
#'
#' @return Nothing.
#'
#' @exportS3Method print rcongas
#'
#' @importFrom crayon white red green yellow black bgYellow blue bold
#' @importFrom cli cli_rule cli_text
#' @importFrom clisymbols symbol
#'
#' @examples
#'
#' x = Rcongas::congas_example
#'
#' print(x)
print.rcongas = function(x, ...)
{
  stopifnot(inherits(x, "rcongas"))
  
  stats_data = get_dataset_stats(x)
  
  # Header
  cli::cli_rule(paste0(
    crayon::bgYellow(crayon::black("[ Rcongas ]")),
    crayon::blue(" {.value {x$description}}")
  ))
  cat('\n')
  
  # Data
  cli::cli_alert(
    'Data: {.field {stats_data$ncells}} cells with {.field {stats_data$ngenes}} genes, aggregated in {.field {stats_data$nsegments}} segments.'
  )
  
  cat("\n")
  
  if (!is.null(stats_data$clusters_k))
    cli::cli_alert_info(
      'Clusters: {.field k = {stats_data$clusters_k}}, model with {.field {stats_data$score_type}} = {.value {round(stats_data$score, 2)}}.'
    )
  else
    cli::cli_alert_warning('Clusters: {crayon::red("not available")}.')
  
  # cat('\n')
  
  
  myp = function (m, symbol = "clisymbols::symbol$pointer")
  {
    paste("{", symbol, "}", m)
  }
  
  
  if (!has_inference(x))
    return()
  pi = (stats_data$clusters_pi * 100) %>% round(2)
  
  cat('\n')
  
  for (i in names(stats_data$clusters_n))
    myp(
      paste0(
        "Cluster {.field {i}}, n = {.value {stats_data$clusters_n[i]}} [{.value { pi[i]}}% of total cells]."
      ),
      symbol = 'clisymbols::symbol$bullet'
    ) %>% cli::cli_text()
  
  # Highlights
  cli::cli_h3("CNA highlights (alpha = 0.05)")
  
  cat('\n')
  
  hl = highlights(x) %>% filter(highlight) %>% arrange(diff)
  
  if (hl %>% nrow > 0)
    # cli::cli_alert_success(" {.field {nsgH}} CNA(s):  {.field {sgH}}")
    # print(hl)
    for (i in hl %>% pull(cluster) %>% unique)
    {
      str = paste0(
        "[",
        hl %>% filter(cluster == i) %>% pull(segment_id),
        ']',
        ' vs ',
        hl %>% filter(cluster == i) %>% pull(versus),
        sep = ''
      )
      
      cli::cli_alert_success(" {.field {i}} CNA(s):  {.field {str}}")
      
    }
  
  
  else
    cli::cli_alert_warning("None found!")
  
  # sgH = get_segment_ids(x, highlight = TRUE)
  # nsgH = sgH %>% length()
  #
  # if(nsgH > 0)
  #   # get_clusters_ploidy(x) %>% filter(highlight) %>% print
  #   cli::cli_alert_success(" {.field {nsgH}} CNA(s):  {.field {sgH}}")
  # else
  #   cli::cli_alert_warning("None found!")
  
  
  
  # paste(
  #   "{crayon::white(clisymbols::symbol$info)} Model scored with {.field {stats_data$score_type}} = {.value {round(stats_data$score, 2)}}"
  # ) %>%
  #   cli::cli_text()
  
  if (Rcongas:::has_DE(x))
  {
    DE_table = Rcongas::get_DE_table(x, cut_pvalue = 0.01, cut_lfc = 0.25)
    
    nde = DE_table %>% nrow()
    
    # Highlights
    cat('\n')
    cli::cli_h3(
      "Differential Expression {.field {x$DE$params$method}}  ({.field {x$DE$params$clone1}} vs {.field {x$DE$params$clone2}})"
    )
    
    cli::cli_alert_success("{.field {nde}} DE genes (alpha = 0.01, |lfc| > 0.25).")
  }
}


#' Print for an object of class \code{'rcongas'}.
#'
#' @description Function \code{plot_gw_cna_profiles} is used to plot
#' the object.
#'
#' @param ... Extra parameters.
#'
#' @return A ggplot object for the plot.
#'
#' @import ggplot2
#'
#' @exportS3Method plot rcongas
#' @export
#'
#' @examples
#'
#' x = Rcongas::congas_example
#'
#' plot(x)
plot.rcongas = function(x, ...)
{
  # default plot
  plot_gw_cna_profiles(x, whole_genome = TRUE)
}


clean_clusters <- function(cm)
{
  to_retain <- names(table(cm$parameters$assignement))
  cm$parameters$mixture_weights <-
    cm$parameters$mixture_weights[to_retain]
  cm$parameters$cnv_probs <-
    cm$parameters$cnv_probs[1:length(to_retain), , drop = F]
  cm$parameters$assignment_probs <-
    cm$parameters$assignment_probs[, 1:length(to_retain), drop = F]
  return(cm)
}

#' @export
`[.rcongas` <- function(x, i, j) {
  x$data$counts <-  x$data$counts[i, j, drop = FALSE]
  x$data$bindims <-  x$data$bindims[i, j, drop = FALSE]
  x$data$cnv <- x$data$cnv[j, , drop = FALSE]
  x$data$gene_locations <-
    x$data$gene_locations %>%  filter(segment_id %in% colnames(x$data$counts))
  gene_to_retain <-
    dplyr::inner_join(x$data$cnv, x$data$gene_locations, by = "segment_id") %>% dplyr::pull(gene)
  
  x$data$gene_counts <-
    x$data$gene_counts[which(rownames(x$data$gene_counts) %in% gene_to_retain), i, drop = FALSE]
  
  if (has_inference(x)) {
    for (k in length(x$inference$model_selection$clusters)) {
      x$inference$models[[k]] <- x$inference$models[[k]][i, j]
    }
  }
  
  return(x)
}
