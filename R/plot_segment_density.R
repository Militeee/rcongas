#' Title
#'
#' @param x
#' @param segment_id
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
plot_segment_density = function(x,
                                segments_ids,
                                group1 = 1,
                                group2 = 2,
                                ...)
{
  plot_single_segment = function(x, segment)
  {
    # Counts data
    counts_data = Rcongas:::get_counts(x, normalise = TRUE) %>%
      Rcongas:::idify() %>%
      dplyr::filter(segment_id == segment)

    # Poisson p-value from the usual test
    test_pvalue = Rcongas:::get_segment_test_counts(x, group1 = group1, group2 = group2, ...) %>%
      Rcongas:::idify() %>%
      dplyr::filter(segment_id == segment)

    # Poisson parameters
    clusters = Rcongas::get_clusters_size(x) %>% names()

    density_points = lapply(clusters, get_poisson_density_values, x = x, segment_id = segment)
    density_points = Reduce(dplyr::bind_rows, density_points)

    # We need to make some adjustments to get the right binning scaling etc
    nbins = 100

    binsize = counts_data %>%
      dplyr::group_by(segment_id) %>%
      dplyr::summarise(min = min(n),
                       max = max(n),
                       .groups = 'keep') %>%
      dplyr::mutate(binsize = (max - min) / nbins) %>%
      dplyr::pull(binsize)

    density_points$y = density_points$y * binsize

    # Coloring
    clusters_colors = Rcongas:::get_clusters_colors(counts_data$cluster)

    # Plot
    counts_data %>%
      ggplot(aes(
        n,
        y = ..count.. / sum(..count..),
        fill = cluster,
        group = cluster
      )) +
      geom_histogram(bins = nbins) +
      facet_wrap( ~ segment_id, ncol = 2, scales = 'free') +
      geom_point(data = density_points,
                 aes(x = x, y = y, color = cluster),
                 inherit.aes = FALSE) +
      geom_line(data = density_points,
                aes(x = x, y = y, color = cluster),
                inherit.aes = FALSE) +
      CNAqc:::my_ggplot_theme() +
      scale_fill_manual(values = sapply(clusters_colors, Rcongas:::lighten, factor = .5)) +
      scale_color_manual(values = Rcongas:::get_clusters_colors(counts_data$cluster)) +
      labs(title = "Poisson counts") +
      labs(x = "RNA counts", y = "Density") +
      geom_text(
        data = test_pvalue,
        aes(
          x = 0,
          y = Inf,
          label = Rcongas:::p_value_format(p)
        ),
        inherit.aes = FALSE,
        size = 2.5,
        hjust = 0,
        vjust = 1.3
      ) +
      coord_cartesian(clip = 'off')

  }


  plots = lapply(segments_ids, plot_single_segment, x = x)
  names(plots) = segments_ids

  return(plots)
}

get_poisson_density_values = function(x,
                                      segment_id,
                                      cluster)
{
  # Poisson parameters - for the density
  poisson_params = Rcongas:::get_poisson_parameters(x) %>%
    Rcongas:::idify() %>%
    dplyr::filter(segment_id == !!segment_id, cluster == !!cluster)

  # Counts data - to determine density range
  counts_data = Rcongas:::get_counts(x, normalise = TRUE) %>%
    Rcongas:::idify() %>%
    dplyr::filter(segment_id == !!segment_id, cluster == !!cluster)

  # Ranges
  min_x = counts_data %>% dplyr::pull(n) %>% min %>% floor()
  max_x = counts_data %>% dplyr::pull(n) %>% max %>% ceiling()

  min_x = ifelse(min_x > 10, min_x - 10, 0)
  max_x = max_x + 10

  # Mixture component likelihood
  lambda  = poisson_params$lambda
  pi = Rcongas::get_clusters_size(x, normalised = TRUE)[cluster]

  data.frame(
    segment_id = segment_id,
    cluster = paste(cluster),
    x = seq(min_x, max_x, by = (max_x - min_x) / 100) %>% round,
    stringsAsFactors = FALSE
  ) %>%
    dplyr::mutate(y = dpois(x, lambda) * pi) %>%
    as_tibble()
}