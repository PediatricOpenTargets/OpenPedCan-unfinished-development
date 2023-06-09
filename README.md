## OpenPedCan-unfinished-development

At the Children's Hospital of Philadelphe, the Open Pediatric Cancer (OpenPedCan) project harmonized pediatric cancer data. One way the data was made available was through an API that, in collaboration with the National Cancer Institute (NCI), provided results from the [OpenPedCan-analysis](https://github.com/PediatricOpenTargets/OpenPedCan-analysis) project to the Molecular [Targets Platform](https://moleculartargets.ccdi.cancer.gov/pediatric-cancer-data-navigation). 
This repository, `OpenPedCan-unfinished-development`, archives and documents code for plots in development for the [OpenPedCan-api](https://github.com/PediatricOpenTargets/OpenPedCan-api).
**WARNING:** This repository is intended to be an archive, so code is not maintained and there may be breaking changes at any time. 

### Using `OpenPedCan-unfinished-development` Code

#### Repository Code

This repository makes an attempt to have executable demo code for proposed plots for the `OpenPedCan-api`. 
However, this repository is not actively maintained and code make break or data access through the submodule may be lost at any time.
If you would like access to the OpenPedCan data, please check out the README of the main repository [OpenPedCan-analysis](https://github.com/PediatricOpenTargets/OpenPedCan-analysis) for instructions on how to access the data.

Code for pilot plots is available in the `api-plot-drafts` folder of this repository. 
Please see individual pilot plot READMEs for information on the plots and how to run the demo code, if possible.

#### Using the `OpenPedCan-analysis` Submodule

In order to get the data in the `OpenPedCan-analysis` submodule you have to first initialize the submodule, then use the `data-download.sh` script within the submodule to fetch the data using the following commands:

```
# initialize the submodule
# Note: you should see a message that the submodule has been initialized followed by the standard git progress messages
git submodule update --init --progress

# change directory into the submodule and download the data
cd OpenPedCan-analysis
bash download-data.sh
``` 

### Getting Started with API Development

#### Developing an OpenPedCan-Api Plot

Generally, API development for OpenPedCan followed these steps:

**Step 1:** Before any API development began, demo plots would be produced for the data of interest (gene expression, copy number variants, methylation, etc.) and go through several rounds of iteration based on project member and physician feedback before settling on a final proposed pilot plot. 
Pilot figures do undergo some revision as necessary during incorporation into the API, but will mostly match the plots proposed at this stage.
The majority of the code and plots described in this repository were at this stage of development.

**Step 2:** Develop code and incorporate it into the API that takes data from `OpenPedCan-analysis`, summarizes it for use in the API, and saves it as a SQL database.
This serves two purposes, first that the OpenPedCan-analysis tables may need to be reformatted or combined for the API plots, and second, by summarizing and saving as a SQL table this speeds up query response time.

**Step 3:**  Add the plot code into the API.
Again this may require some refactoring to make the plot code into a single function. 
Also, on the MTP website, every plot includes the option to dowload a summary table of the data in the plot, so code with a function to create the summary table needs to be written.
Typically for each plot there are three functions called, (1) to filter the database for the specifc disease and gene combination being plotted on the website, (2) to make the plot, and (3) to make the sumamry table.
For examples, see the R scripts for gene expression in the [OpenPedCan-api repository](https://github.com/PediatricOpenTargets/OpenPedCan-api/tree/main/src). 

**Step 4:** Add new plot as an endpoint by adding a `plumbr` endpoint function.
See [OpenPedCan-api plumber.R](https://github.com/PediatricOpenTargets/OpenPedCan-api/blob/0a7046b1dedc7a7b954400edae7a45b4d60a8a98/src/plumber.R#L85-L103) for an example.

**Step 5:** Edit testing script to include tests for the new endpoint See the [OpenPedCan-api testing script](https://github.com/PediatricOpenTargets/OpenPedCan-api/blob/0a7046b1dedc7a7b954400edae7a45b4d60a8a98/tests/run_tests.sh) for examples.

#### Getting Started

If you are interested in API development or contributing to API development, please see the instructions in the [OpenPedCan-api](https://github.com/PediatricOpenTargets/OpenPedCan-api) repository, specifically the [API test run](https://github.com/PediatricOpenTargets/OpenPedCan-api#3-test-run-openpedcan-api-server-locally) instructions will help you get the API testing environment set up on your local computer.
API support may end or be transfered to other partires at any time, so please contact the maintainers of the main [OpenPedCan-analysis](https://github.com/PediatricOpenTargets/OpenPedCan-analysis) repository if that is the case or you would like to get involved in the project.