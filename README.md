# OpenPedCan-unfinished-development
Unfinished development, mainly for the API, at the time of NCI contract end

### Using the `OpenPedCan-analysis` Submodule

In order to get the data in the `OpenPedCan-analysis` submodule you have to first initialize the submodule, then use the `data-download.sh` script within the submodule to fetch the data using the following commands:

```
# initialize the submodule
# Note: you should see a message that the submodule has been initialized followed by the standard git progress messages
git submodule update --init --progress

# change directory into the submodule and download the data
cd OpenPedCan-analysis
bash download-data.sh
``` 
