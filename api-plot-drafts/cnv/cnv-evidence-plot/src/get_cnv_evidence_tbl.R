# get_cnv_evidence_tbl.R defines a function get_cnv_evidence_tbl to return a 
# CNV tibble of a single gene in a single disease and one of or both of primary
# and relapse cancers

# DRAFT NOTE 2022-11-07: Search document for "UPDATE" for locations that were
# know to need updates after database construction is successfully accomplished
#
# Call sequence:
#
# - docker run calls Rscript --vanilla main.R
# - ../main.R calls source("src/get_cnv_evidence_tbl.R")
#
# Defined variables:
#
# - get_cnv_evidence_tb

# Design notes:
#
# - Are there any notes I want to put here??

# Get a CNV tibble of a single gene in a single disease and one of or both of 
# primary and relapse cancers
#
# Args:
# - ensg_id: a single character value of gene ENSG ID. REQUIRED.
# - relapse_sample_group: a single character value with the following choices.
#   REQUIRED.
#   - "exclude": Exclude relapse tumors. Does NOT raise error if there is no
#     relapse tumor.
#   - "require": Require all relapse tumors. Raise error if there is no relapse
#     tumor.
# - efo_id: a single character value of EFO ID. REQUIRED.
# - gene_symbol: NULL or a single character value of gene symbol. Default is
#   NULL, which is to select the first sorted gene symbol when one ENSG ID maps
#   to multiple gene symbols. If gene_symbol is not NULL, the (efo_id,
#   gene_symbol) tuple is selected when one ENSG ID maps to multiple gene
#   symbols.
# 
# Returns a tibble with the following columns:
# - cohort: a single cohort. If the input efo_id has more than one histology_df
#   cohorts, e.g. GMKF and TARGET, include an additional cohort "All Cohorts" in
#   the result table.
# - EFO: a single EFO ID
# - MONDO: a single MONDO ID
# - Disease: a single Disease/cancer_group
# - cnv_type: categorical descriptor of the copy number variant, one of deep
#   deletion (no copies), loss (fewer copies than ploidy), neutral (same number
#   of copies as ploidy), gain (up to two times ploidy), amplification (greater
#   than two times ploidy)
# - sample_count: a numeric count of the number of samples with an alteration in
#   the given category
# - Gene_Ensembl_ID: a single ENSG ID
# - Gene_symbol: a single gene symbol
# - cancer_status: whether the tumor is primary or relapse. Will contain one or
#   both of those options, depending on the type requested

get_cnv_evidence_tbl <- function(efo_id, ensg_id, cancer_status, 
                                 gene_symbol = NULL) {
  stopifnot(is.character(ensg_id))
  stopifnot(identical(length(ensg_id), 1L))
  stopifnot(!is.na(ensg_id))
  
  stopifnot(is.character(cancer_status))
  stopifnot(identical(length(cancer_status), 1L))
  stopifnot(cancer_status %in% c("primary", "relapse"))
  
  stopifnot(is.character(efo_id))
  stopifnot(identical(length(efo_id), 1L))
  stopifnot(!is.na(efo_id))
  
  if (!is.null(gene_symbol)) {
    stopifnot(is.character(gene_symbol))
    stopifnot(identical(length(gene_symbol), 1L))
    stopifnot(!is.na(gene_symbol))
  }
  
  # Query database.
  #
  # connect_db and db_env_vars are coming from main.R.
  conn <- connect_db(db_env_vars)  # nolint: object_usage_linter.
  
  # Case insensitive db schema and table names. DBI/glue quotes names. Table
  # columns are case sensitive.
  q_schema <- tolower(
  ### UPDATE BOTH TO CORRECT CNV SCHEMA
    db_env_vars$CNV_SCHEMA)  # nolint: object_usage_linter.
  q_table <- tolower(
    db_env_vars$CNV_EVIDENCE_TABLE)  # nolint: object_usage_linter.
  
  # Use parameterized queries to protect queries from SQL injection attacks.
  #
  # https://db.rstudio.com/best-practices/run-queries-safely/#parameterized-queries
  q_rs <- DBI::dbSendQuery(
    conn,
    glue::glue_sql("
      SELECT *
      FROM {`q_schema`}.{`q_table`}
      WHERE \"Gene_Ensembl_ID\" = ?
    ", .con = conn)
  )
  # Bind ? in the query statment with values.
  DBI::dbBind(q_rs, list(ensg_id))
  # "dbFetch() always returns a data.frame with as many rows as records were
  # fetched and as many columns as fields in the result set, even if the result
  # is a single value or has one or zero rows."
  #
  # Ref: https://dbi.r-dbi.org/reference/dbfetch
  q_rs_df <- DBI::dbFetch(q_rs)
  DBI::dbClearResult(q_rs)
  DBI::dbDisconnect(conn)
  
  cnv_evidence_tbl <- tibble::as_tibble(q_rs_df)
  
  # Raise error if table is empty, i.e. no data available.
  stopifnot(nrow(cnv_evidence_tbl) > 0)
  
  # Raise error if table is not expected
  stopifnot(identical(
    colnames(cnv_evidence_tbl),
    c("ensembl", "gene_symbol", "cancer_group", "status", "cohort_level",
      "specimen_descriptor", "sample_count", "efo_code", "mondo_code", 
      "ncit_code", "version")
    ))
  # Assert column types are expected.
  placeholder_res <- purrr::imap_lgl(cnv_evidence_tbl, function(xcol, xcolname) {
    if (xcolname == "sample_count") {
      stopifnot(is.numeric(xcol))
    } else {
      stopifnot(is.character(xcol))
    }
    return(TRUE)
  })
  # Assert input ensg_id is the only ENSG ID.
  stopifnot(identical(unique(cnv_evidence_tbl$ensembl), ensg_id))
  # Assert no NA in required columns.
  stopifnot(identical(
    sum(is.na(
      dplyr::select(
        cnv_evidence_tbl, cohort_level, specimen_descriptor,
        sample_count, ensembl, gene_symbol))),
    0L
  ))
  # Assert no duplicated (sample, gene) tuple.
  stopifnot(identical(
    nrow(dplyr::distinct(dplyr::select(cnv_evidence_tbl, -sample_count))),
    nrow(cnv_evidence_tbl)
  ))
  
  # .data and .env are from rlang package, but they do not need to be imported
  # to work. "The .data pronoun is automatically created for you by data-masking
  # functions using the tidy eval framework." This should also apply to .env.
  #
  # - .data "retrieves data-variables from the data frame".
  # - .env "retrieves env-variables from the environment".
  # - Ref: https://rlang.r-lib.org/reference/tidyeval-data.html
  #
  # tpm_df cols: Gene_Ensembl_ID, Gene_symbol, Sample1, Sample2, ...
  
  # Handle one ENSG ID mapping to more than one symbols
  #
  # Predicates at this point:
  #
  # - cnv_evidence_tbl has > 0 rows.
  # - ensg_id is the only ENSG ID.
  # - long_tpm_tbl$Gene_symbol has no NA.
  ltt_uniq_gene_symbols <- unique(cnv_evidence_tbl$gene_symbol)
  
  if (DEBUG) {
    stopifnot(is.character(ltt_uniq_gene_symbols))
    stopifnot(length(ltt_uniq_gene_symbols) > 0)
  }
  
  if (length(ltt_uniq_gene_symbols) > 1) {
    # ensg id is mapped to multiple symbols
    if (!is.null(gene_symbol)) {
      stopifnot(is.character(gene_symbol))
      stopifnot(identical(length(gene_symbol), 1L))
      stopifnot(!is.na(gene_symbol))
      
      long_tpm_tbl <- dplyr::filter(
        long_tpm_tbl, .data$gene_symbol == .env$gene_symbol)
      
      if (nrow(long_tpm_tbl) == 0) {
        stop(paste(ensg_id, gene_symbol, "is not available."))
      }
    } else {
      first_sorted_ltt_uniq_gene_symbol <- dplyr::first(
        sort(ltt_uniq_gene_symbols))
      
      cnv_evidence_tbl <- dplyr::filter(
        cnv_evidence_tbl,
        .data$gene_symbol == .env$first_sorted_ltt_uniq_gene_symbol)
    }
  }
  
  if (DEBUG) {
    stopifnot(identical(length(unique(cnv_evidence_tbl$gene_symbol)), 1L))
  }
  
  # Subset samples.
  
  # The following predicates are asserted in the database building procedure:
  #
  # - If Disease is not NA, EFO is not NA.
  if (DEBUG) {
    stopifnot(identical(
      is.na(cnv_evidence_tbl$cancer_group),
      is.na(cnv_evidence_tbl$efo_code)
    ))
  }
  
  # Subset Diseases (aka cancer groups)
  #
  # Separate gtex and disease tables to simplify different procedures for
  # handling Diseases and GTEx tissues.
  disease_cnv_evidence_tbl <- dplyr::filter(
    cnv_evidence_tbl, !is.na(.data$cancer_group))  # nolint: object_usage_linter.
  
  # specimen_descriptor is asserted above to have no NA
  if (relapse_sample_group == "exclude") {
    disease_cnv_evidence_tbl <- dplyr::filter(
      disease_cnv_evidence_tbl, specimen_descriptor != "Relapse Tumor")
  } else if (relapse_sample_group == "require") {
    # Raise error if no relapse sample, i.e., data not available. Raising error
    # is favored over analyzing without required samples, by design.
    stopifnot(any(disease_cnv_evidence_tbl$specimen_descriptor == "Relapse Tumor"))
  } else {
    stop(paste0(
      "Not implemented relapse_sample_group value ", relapse_sample_group))
  }
  
  # Raise error if no Disease, i.e. data not available.
  stopifnot(nrow(disease_cnv_evidence_tbl) > 0)
  
  if (!is.null(efo_id)) {
    # Keep only Disease (aka cancer group) that is mapped to input efo_id.
    disease_cnv_evidence_tbl <- dplyr::filter(
      disease_cnv_evidence_tbl, .data$efo_code == .env$efo_id)
    
    # Raise error if no Disease passes the filter, i.e., data not available.
    stopifnot(nrow(disease_cnv_evidence_tbl) > 0)
  }
  
  # Let return table have the same colnames and order.
  disease_cnv_evidence_tbl <- dplyr::select(
    disease_cnv_evidence_tbl,
    dplyr::all_of(
      c("ensembl", "gene_symbol", "cancer_group", "status", "cohort_level",
        "specimen_descriptor", "sample_count", "efo_code", "mondo_code", 
        "ncit_code", "version")
    )
  )
  
  return(cnv_evidence_tbl)
}
