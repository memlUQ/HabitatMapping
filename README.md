# Habitat Mapping in GEE
Google Earth Engine habitat mapping scripts for repeated creation of benthic cover maps, primarily used for creating time series maps. Scripts require georeferenced benthic photoquadrat data classified in [ReefCloud](https://reefcloud.ai/), satellite/airborne multispectral imagery, and bathymetry. The processing scripts are initially setup for mapping across the Eastern Banks in Moreton Bay (seagrass) and on Heron Reef (coral), both in Queensland, Australia. These scripts are divided into:
- Field data pre-processing (R script).
- Image pre-processing (GEE).
- Calibration/validation assignment (GEE).
- Habitat map classification (GEE).

# Field Data Pre-Processing
Classified photoquadrat data from [ReefCloud](https://reefcloud.ai/) is reorganised into the desired benthic classes required for creating habitat maps. Two scripts are used for the time series mapping that utilises the three Google Earth Engine scripts. The two scripts are `GEE_Coral.R` and `GEE_Seagrass.R` which are used for habitat mapping in coral reef and seagrass environments, respectively.
> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

# Image Pre-Processing
The raw satellite image is pre-processed in a GEE script (`1.Image_Processing`). In this process, statistical bands are calculated including: mean, median, standard deviation, texture measurements from the gray level co-occurrence matrix (GLCM), principal componentanalysis (PCA), and simple non-iterative clustering (SNIC) segmentation. Additionally, physical attribute layers are included from previous research: depth, slope, and waves. These physical layers can be omitted if not required.
> [!IMPORTANT]
> This script requires:
> - Multispectral image (**tiff**)
> - Physical layer raster for depth/slope/waves (**tiff**)
> - Outline for the region of interest (**shapefile**)

> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

# Points Processing
The resulting field data from the pre-processing step are processed to link each benthic type to the statistical and physical atribute layers of the processed image in a GEE script (`2.Points_Processing`). Additionally, this script divides the field data into calibration (80%) and validation (20%) datasets, and re-samples the points to ensure representation across the different benthic types.
> [!IMPORTANT]
> This script requires:
> - Multispectral image (**tiff**)
> - Processed segmented image (**tiff**) from `1.Image_Processing`
> - Outline for the region of interest (**shapefile**)
> - Field data (**csv**) from field data pre-processing scripts `GEE_Coral.R` or `GEE_Seagrass.R`

> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

# Image Classification
This script (`3.Classification`) links the calibration dataset (output from `2.Points_Processing`) and the pre-processed imagery (output from `1.Image_Proessing`) via a randome forest classifier and generates habitat composition maps. Additionally, by linking the resulting classified image and the valdiation dataset (output from `2.Points_Processing`), accuracy assessments are performed resulting in overall, producer's, and user's accuracies.
> [!IMPORTANT]
> This script requires:
> - Multispectral image (**tiff**)
> - Processed segmented image (**tiff**) from `1.Image_Processing`
> - Physical layer raster for depth/slope/waves (**tiff**)
> - Outline for the region of interest (**shapefile**)
> - Calibration points (**csv**) from `2.Points_Processing`
> - Validation points (**csv**) from `2.Points_Processing`

> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

_Example classified image in GEE display window below._
<img width="783" height="528" alt="image" src="https://github.com/user-attachments/assets/1d456466-489f-4d6d-b9a7-473e5afeadc6" />
