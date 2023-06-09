# get_cnv_evidence_plot.R defines a function get_cnv_evidence_plot() to return a
# ggplot2 stacked bar plot.
#
# Call sequence:
#
# - docker run calls Rscript --vanilla main.R
# - ../main.R calls source("src/get_cnv_evidence_plot.R")
#
# Defined variables:
#
# - get_cnv_evidence_plot

get_cnv_evidence_plot <- function(cnv_evidence_tbl) {
  ensg_id <- unique(cnv_evidence_tbl$ensembl)
  stopifnot(is.character(ensg_id))
  stopifnot(!is.na(ensg_id))
  stopifnot(identical(length(ensg_id), 1L))
  
  gene_symbol <- unique(cnv_evidence_tbl$gene_symbol)
  stopifnot(is.character(gene_symbol))
  stopifnot(!is.na(gene_symbol))
  stopifnot(identical(length(gene_symbol), 1L))
  
  cohort <- unique(cnv_evidence_tbl$cohort)
  stopifnot(is.character(cohort))
  stopifnot(!is.na(cohort))
  # stopifnot(identical(length(cohort), 1L))
  
  efo_id_vec <- purrr::discard(unique(cnv_evidence_tbl$efo_code), is.na)
  stopifnot(is.character(efo_id_vec))
  stopifnot(length(efo_id_vec) > 0)
  
  # # When there is "Pediatric Primary and Relapse Tumors", there is no "Pediatric
  # # Primary Tumors" or "Pediatric Relapse Tumors"
  # if (all(c("Pediatric Primary Tumors", "Pediatric Relapse Tumors") %in%
  #         uniq_spec_desc_fill_vec) ||
  #     ("Pediatric Primary and Relapse Tumors" %in% uniq_spec_desc_fill_vec)) {
  #   
  #   tumor_title_desc <- "Pediatric primary and relapse tumor"
  #   
  # } else if ("Pediatric Primary Tumors" %in% uniq_spec_desc_fill_vec) {
  #   tumor_title_desc <- "Pediatric primary only tumor"
  #   
  # } else if ("Pediatric Relapse Tumors" %in% uniq_spec_desc_fill_vec) {
  #   tumor_title_desc <- "Pediatric relapse only tumor"
  #   
  # } else {
  #   stop(paste0(
  #     "Internal error: not supported unique tumor descriptors ",
  #     paste(uniq_spec_desc_fill_vec, collapse = ", ")))
  # }
  
  # # Set title
  # if (length(gtex_subgroup_vec) > 0) {
  #   title <- paste0(
  #     gene_symbol, " (", ensg_id, ")\n",
  #     tumor_title_desc, " and GTEx normal adult tissue gene expression")
  # } else {
  #   title <- paste0(
  #     gene_symbol, " (", ensg_id, ")\n",
  #     tumor_title_desc, " gene expression")
  # }
  
  # # Set y-axis label
  # if (y_axis_scale == "linear") {
  #   y_axis_label <- "TPM"
  # } else if (y_axis_scale == "log10") {
  #   y_axis_label <- "log10(TPM + 1)"
  #   gene_tpm_boxplot_tbl <- dplyr::mutate(
  #     gene_tpm_boxplot_tbl, TPM = log10(.data$TPM + 1))
  # } else {
  #   stop(paste0("y_axis_scale = ", y_axis_scale, " is not implemented."))
  # }
  
  # # Set fill guide/legend
  # if (length(spec_desc_fill_color_vec) > 1) {
  #   fill_guide <- ggplot2::guide_legend(title = "")
  # } else {
  #   fill_guide <- "none"
  # }
  
  # # Set margin
  # plot_margin <- ggplot2::theme_get()$plot.margin
  # 
  # if (!identical(length(plot_margin), 4L)) {
  #   plot_margin <- rep(grid::unit(x = 5.5, units = "points"), 4)
  # }
  # 
  # # The x-axis labels are long and rotated 45 degrees, so they are out of the
  # # plot in the default margin. Increase right margin to fit all text.
  # plot_margin[2] <- grid::unit(x = 29, units = "char")
  
  ### Format cnv_evidence_tbl for plotting
  cnv_evidence_tbl %>%
    group_by(ensembl, gene_symbol, cancer_group, specimen_descriptor, cohort) %>%
    mutate(group_count = sum(sample_count)) %>%
    ungroup() %>%
    mutate(status = factor(status, levels = c('amplification', 'gain', 'neutral',
                                              'loss', 'deep deletion')),
           cohort = factor(cohort, levels = c('All Cohorts', 'GMKF',
                                              'PBTA', 'TARGET')),
           cancer_status = ifelse(specimen_descriptor == 'Primary Tumor',
                                  'primary', 'relapse'),
           cancer_status = factor(cancer_status, levels = c('primary', 'relapse')),
           percentage = round(((sample_count / group_count) * 100)),
           label = ifelse(sample_count > 0 & percentage == 0, '<1%',
                          paste0(percentage, '%'))) -> plot_tbl
  
  ### Get sample size labels for the tops of the bars
  plot_tbl %>%
    distinct(cohort, cancer_status, group_count) %>%
    mutate(count_label = paste0('n = ', group_count)) %>%
    ungroup() -> sample_size_labels
  
  ### Get the plot title based on the disease and gene being plotted
  plot_tbl %>%
    distinct(cancer_group, ensembl, gene_symbol) %>%
    mutate(title = paste0(cancer_group, '\n', gene_symbol, 
                          ' (', ensembl, ')')) -> title
  
  ### plot
  ggplot2::ggplot(plot_tbl, ggplot2::aes(x = cohort, y = percentage)) +
    ggplot2::geom_col(ggplot2::aes(fill = status)) +
    viridis::scale_fill_viridis(discrete = T, option = 'viridis',
                                direction = -1, drop = F) +
    ggplot2::geom_text(ggplot2::aes(label = label, color = status),
                       position = position_stack(vjust = 0.5)) +
    ggplot2::scale_color_manual(values = c('gray0', 'gray0', 'gray0', 'gray100',
                                                  'gray100', 'gray100'),
                                                  guide = 'none', drop = F) +
    ggplot2::geom_text(data = sample_size_labels, y = 105,
                       ggplot2::aes(label = count_label)) +
    ggplot2::coord_cartesian(ylim = c(0, 107)) +
    ggplot2::scale_y_continuous(breaks = c(0, 20, 40, 60, 80, 100)) +
    ggplot2::labs(x = 'Cohort', y = 'Percent Copy Number', fill = 'Copy Number',
                  title = title$title) +
    ggplot2::theme_classic(base_size = 16) -> cnv_evidence_plot
  
  return(cnv_evidence_plot)
}