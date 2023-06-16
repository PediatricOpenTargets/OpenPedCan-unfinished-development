# get_cnv_evidence_summary_tbl.R defines a function
# get_cnv_evidence_summary_tbl to return a summary table that is accompanies and
# is available for download with the plot created in get_cnv_eviden_plot.R
#
# Call sequence:
#
# - docker run calls Rscript --vanilla main.R
# - ../main.R calls source("src/get_cnv_evidence_summary_tbl.R")
#
# Defined variables:
#
# - get_cnv_evidence_summary_tbl

get_cnv_evidence_summary_tbl <- function(cnv_evidence_tbl, 
                                      plot_group = c('primaryOnly', 
                                                     'relapseOnly',
                                                     'primaryAndRelapseSeparate',
                                                     'primaryAndRelapseTogether')) {
  # check to make sure that the value provided for plot_group matches one of the
  # allowed options and ONLY ONE of the allowed options
  plot_group <- match.arg(plot_group, several.ok = F)
  
  # if primary and relapse are combined together, have to calculate without 
  # grouping by specimen_descriptor
  if (plot_group == 'primaryAndRelapseTogether') {
    cnv_evidence_tbl %>% 
      group_by(ensembl, gene_symbol, cancer_group, cohort, status) %>%
      summarize(sample_count = sum(sample_count)) %>%
      group_by(ensembl, gene_symbol, cancer_group, cohort) %>% 
      mutate(group_count = sum(sample_count)) %>% 
      ungroup() %>% 
      mutate(status = factor(status, levels = c('amplification', 'gain', 'neutral',
                                                'loss', 'deep deletion')),
             cohort = factor(cohort, levels = c('All Cohorts', 'GMKF',
                                                'PBTA', 'TARGET')),
             percentage = round(((sample_count / group_count) * 100)),
             label = ifelse(sample_count > 0 & percentage == 0, '<1%',
                            paste0(percentage, '%'))) -> cnv_evidence_plot_tbl
    return(cnv_evidence_plot_tbl)
  } else if (plot_group == 'primaryAndRelapseSeparate') {
    cnv_evidence_tbl %>% 
      group_by(ensembl, gene_symbol, cancer_group, cohort, 
               specimen_descriptor) %>% 
      mutate(group_count = sum(sample_count)) %>% 
      ungroup() %>% 
      mutate(status = factor(status, levels = c('amplification', 'gain', 'neutral',
                                                'loss', 'deep deletion')),
             cohort = factor(cohort, levels = c('All Cohorts', 'GMKF',
                                                'PBTA', 'TARGET')),
             percentage = round(((sample_count / group_count) * 100)),
             label = ifelse(sample_count > 0 & percentage == 0, '<1%',
                            paste0(percentage, '%'))) -> cnv_evidence_plot_tbl
    return(cnv_evidence_plot_tbl)
  } else if (plot_group == 'primaryOnly') {
    cnv_evidence_tbl %>% 
      filter(specimen_descriptor == 'Primary Tumor') %>% 
      group_by(ensembl, gene_symbol, cancer_group, cohort, 
               specimen_descriptor) %>% 
      mutate(group_count = sum(sample_count)) %>% 
      ungroup() %>% 
      mutate(status = factor(status, levels = c('amplification', 'gain', 'neutral',
                                                'loss', 'deep deletion')),
             cohort = factor(cohort, levels = c('All Cohorts', 'GMKF',
                                                'PBTA', 'TARGET')),
             percentage = round(((sample_count / group_count) * 100)),
             label = ifelse(sample_count > 0 & percentage == 0, '<1%',
                            paste0(percentage, '%'))) -> cnv_evidence_plot_tbl
    return(cnv_evidence_plot_tbl)
  } else if (plot_group == 'relapseOnly') {
    cnv_evidence_tbl %>% 
      filter(specimen_descriptor == 'Relapse Tumor') %>% 
      group_by(ensembl, gene_symbol, cancer_group, cohort, 
               specimen_descriptor) %>% 
      mutate(group_count = sum(sample_count)) %>% 
      ungroup() %>% 
      mutate(status = factor(status, levels = c('amplification', 'gain', 'neutral',
                                                'loss', 'deep deletion')),
             cohort = factor(cohort, levels = c('All Cohorts', 'GMKF',
                                                'PBTA', 'TARGET')),
             percentage = round(((sample_count / group_count) * 100)),
             label = ifelse(sample_count > 0 & percentage == 0, '<1%',
                            paste0(percentage, '%'))) -> cnv_evidence_plot_tbl
    return(cnv_evidence_plot_tbl)
  }
}

