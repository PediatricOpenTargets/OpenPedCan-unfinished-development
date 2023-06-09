## Pilot code for methylation plots
*Author:* Alvin Farrel @afarrel


### Purpose

This section documents and has executable code for the proposed methylation plots for the OpenPedCan/MTP API. This code cannot be used with the API as is and is included for archival purposes only; if you would like to start working on API development, please see the [main repository README](https://github.com/PediatricOpenTargets/OpenPedCan-unfinished-development)

Description of plot (with link to picture?)

### Usage

**NOTE:** Before running code, please check the R script to make sure that you have all necessary packages installed.

To exeute the example code: `Rscript --vanilla OT_Methylation_plot.R`

Input:

- gencode annotations: `../../../OpenPedCan-analysis/data/gencode.v39.primary_assembly.annotation.gtf.gz`
- example methylation summary table: `input/example-isoform-methyl-beta-values-summary.tsv.gz`

Output: