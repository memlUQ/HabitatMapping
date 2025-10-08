# Habitat Mapping in GEE
Google Earth Engine habitat mapping scripts for repeated creation of benthic cover maps, primarily used for creating time series maps. Scripts require georeferenced benthic photoquadrat data classified in [ReefCloud](https://reefcloud.ai/), satellite/airborne multispectral imagery, and bathymetry. The processing scripts are initially setup for mapping across the Eastern Banks in Moreton Bay (seagrass) and on Heron Reef (coral), both in Queensland, Australia. These scripts are divided into:
- Field data pre-processing (R script).
- Image pre-processing (GEE).
- Calibration/validation assignment (GEE).
- Habitat map classification (GEE).

# Field Data Pre-Processing
Classified photoquadrat data from [ReefCloud](https://reefcloud.ai/) is reorganised into the desired benthic classes required for creating habitat maps. Two scripts are used for the time series mapping that utilises the three Google Earth Engine scripts. The two scripts are `GEE_Coral.R` and `GEE_Seagrass.R` which are used for habitat mapping in coral reef and seagrass environments, respectively.

# Image Pre-Processing
The raw satellite image is pre-processed in a GEE script (`1.Image_Processing`). In this process, statistical bands are calculated including: mean, median, standard deviation, texture measurements from the gray level co-occurrence matrix (GLCM), principal componentanalysis (PCA), and simple non-iterative clustering (SNIC) segmentation. Additionally, physical attribute layers are included from previous research: depth, slope, and waves. These physical layers can be omitted if not required.
> [!IMPORTANT]
> This script requires:
> - a multispectral image (TIFF)
> - physical layer raster for depth/slope/waves (TIFF)
> - and an outline for the region of interest (SHAPEFILE)

# Points Processing

# Image Classification


# Field Data Pre-processing
Classified photoquadrat data from [ReefCloud](https://reefcloud.ai/) is reorganised into the desired benthic classes required for creating habitat maps. Two scripts are used for the time series mapping that utilises the three Google Earth Engine scripts. The two scripts are `GEE_Coral.R` and `GEE_Seagrass.R` which are used for habitat mapping in coral reef and seagrass environments, respectively. This process groups benthic composition categories into mapping categories: "Coral", "Algae", "Algae/Coral", "Rock", "Rock/Coral", "Sand", "Sand/Coral", and "Mixed". These are based on pre-defined thresholds based on the the Australian Institute of Marine Science (AIMS) Annual Summary Report of Coral Reef Condition (1).

Nots: paths for input and output folder/files needs to be changed to fit the users location and name of field data files.

Habitat Mapping
1. Image Processing
The raw satellite image is pre-processed in a GEE script. In this process, statistical bands are calculated including: mean, median, standard deviation, texture measurements from the gray level co-occurrence matrix (GLCM), principal component analysis (PCA), and simple non-iterative clustering (SNIC) segmentation (2-6). Additionally, physical attribute layers are included from previous research: depth, slope, and waves (7, 8). These are to be included for other reef areas, otherwise can be ommited.

Note: paths for input and output folder/files needs to be changed to fit the users location and name of field data files.

2. Points Processing
The resulting field data from the pre-processing step are processed to link each benthic type to the statistical and physical atribute layers of the processed image. Additionally, this script divides the field data into calibration (80%) and validation (20%) datasets, and re-samples the points to ensure representation across the different benthic types.

Note: paths for input and output folder/files needs to be changed to fit the users location and name of field data files.

3. Classification
This script links the calibration dataset (output from 2. Points Processing) and the pre-processed imagery (output from 1. Image Proessing) via a randome forest calssifier and generates habitat composition maps. Additionally, by linking the resulting classified image and the valdiation dataset (output from 2. Points Processing), accuracy assessments are performed resulting in overall, producer's, and user's accuracies.

Note: paths for input and output folder/files needs to be changed to fit the users location and name of field data files.
