# Habitat Mapping in GEE
Google Earth Engine habitat mapping scripts for repeated creation of benthic cover maps, primarily used for creating time series maps. Scripts require georeferenced benthic photoquadrat data classified in [ReefCloud](https://reefcloud.ai/), satellite/airborne multispectral imagery, and bathymetry. The processing scripts are initially setup for mapping across the Eastern Banks in Moreton Bay (seagrass) and on Heron Reef (coral), both in Queensland, Australia. These scripts are divided into:
- Field data pre-processing (R script).
- Image pre-processing (GEE).
- Calibration/validation assignment (GEE).
- Habitat map classification (GEE).

  # 0. Field Data Pre-Processing
  Classified photoquadrat data from [ReefCloud](https://reefcloud.ai/) is reorganised into the desired benthic classes required for creating habitat maps. Two scripts are used for the time series mapping that utilises the three Google Earth Engine scripts. The two scripts
  are `GEE_Coral.R` and `GEE_Seagrass.R` which are used for habitat mapping in coral reef and seagrass environments, respectively.

  # 1. Image Pre-Processing

  # 2. Points Processing

  # 3. Image Classification
