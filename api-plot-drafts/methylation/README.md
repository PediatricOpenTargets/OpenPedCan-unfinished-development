## Pilot code for methylation plots
*Author:* Alvin Farrel @afarrel

### Purpose

This section documents and has executable code for the proposed methylation plots for the OpenPedCan/MTP API. 
This code cannot be used with the API as is and is included for archival purposes only; if you would like to start working on API development, please see the [main repository README](https://github.com/PediatricOpenTargets/OpenPedCan-unfinished-development)
**WARNING:** This code is not maintained and there may be breaking changes at any time. 
Also, funding has ended for this portion of the MTP project so data may no longer be available in the same way. 
For the most up-to-date instructions on how to access code and data, please see the main [OpenPedCan-analysis repository](https://github.com/PediatricOpenTargets/OpenPedCan-analysis).

### Pilot Plot

**INSERT HERE** Description of plot with link to picture

Next steps for developing these plots for the API would be to refactor the code to handle additional variables and to prep for incorporation into the API. 
It needs to be worked out how to handle different cohorts, handle different cancer types, and how we want to handle the summary table although consensus was converging on summary by gene feaure (like promoter, exon, intron, maybe TSS/TES as well).

### Usage

**NOTE:** Before running code, please check the R script to make sure that you have all necessary packages installed.

**`cnv_pilot_plot_code.Rmd`** This script reads in the data from the `OpenPedCan-analysis` submodule and the input data directory, combines/formats it appropriately, and then plots example plots for the methylation. The methylation data table is included in the `input/` folder because the summary table is above GitHub's storage limits and not included with the `OpenPedCan-analysis` submodule.

Usage:

To exeute the example code: `Rscript --vanilla OT_Methylation_plot.R`

Input:

- gencode annotations: `../../../OpenPedCan-analysis/data/gencode.v39.primary_assembly.annotation.gtf.gz`
- example methylation summary table: `input/example-isoform-methyl-beta-values-summary.tsv.gz`

Output:

Code is not working to produce an output at the time of archiving so it would have to be edited to produce example plots.