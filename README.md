## OpenPedCan-unfinished-development

At the Children's Hospital of Philadelphe, the Open Pediatric Cancer (OpenPedCan) project harmonized pediatric cancer data. One way the data was made available was through an API that, in collaboration with the National Cancer Institute (NCI), provided results from the [OpenPedCan-analysis](https://github.com/PediatricOpenTargets/OpenPedCan-analysis) project to the Molecular [Targets Platform](https://moleculartargets.ccdi.cancer.gov/pediatric-cancer-data-navigation). 
This repository, `OpenPedCan-unfinished-development`, archives and documents code for plots in development for the [OpenPedCan-api](https://github.com/PediatricOpenTargets/OpenPedCan-api).

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

If you are interested in API development or contributing to API development, please see the instructions in the [OpenPedCan-api](https://github.com/PediatricOpenTargets/OpenPedCan-api) repository.
API support may end or be transfered to other partires at any time, so please contact the maintainers of the main [OpenPedCan-analysis](https://github.com/PediatricOpenTargets/OpenPedCan-analysis) repository if that is the case or you would like to get involved in the project.

