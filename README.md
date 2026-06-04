# Habitat Mapping in GEE
Google Earth Engine habitat mapping scripts for repeated creation of benthic cover maps, primarily used for creating time series maps. Scripts require georeferenced benthic photoquadrat data classified in [ReefCloud](https://reefcloud.ai/), satellite/airborne multispectral imagery, and bathymetry. The processing scripts are initially setup for mapping across the Eastern Banks in Moreton Bay (seagrass) and on Heron Reef (coral), both in Queensland, Australia. These scripts are divided into:
- Field data pre-processing (R script).
- Image pre-processing (GEE).
- Calibration/validation assignment (GEE).
- Habitat map classification (GEE).

# Field Data Pre-Processing
Classified photoquadrat data from [ReefCloud](https://reefcloud.ai/) is reorganised into the desired benthic classes required for creating habitat maps. Two scripts are used for the time series mapping that utilises the three Google Earth Engine scripts. The two scripts are `GEE_Coral.R` and `GEE_Seagrass.R` which are used for habitat mapping in coral reef and seagrass environments, respectively.

Any in situ training data can be used for training and validation (not just derived from ReefCloud), requiring the following fields as a spreadsheet in a `.csv` format:
| Longitude | Latitude | Class_num | Dom_Ben |
| ---------- | ---------- | ---------- | ---------- |
| Longitude in decimal degrees (float) | Latitude in decimal degrees (float) | The **dominant** benthic feature at each field data point (integer [1 -> max no. of classes]) | Name for the **dominant** benthic class (string) |

> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

# Image Pre-Processing
The raw satellite image is pre-processed in a GEE script (`1.Image_Processing`). In this process, statistical bands are calculated including: mean, median, standard deviation, texture measurements from the gray level co-occurrence matrix (GLCM), principal component analysis (PCA), and simple non-iterative clustering (SNIC) segmentation. Additionally, physical attribute layers are included from previous research: depth, slope, and waves. These physical layers can be omitted if not required.
> [!IMPORTANT]
> This script requires:
> - Multispectral image (**tiff**)
> - Physical layer raster for depth/slope/waves (**tiff**)
> - Outline for the region of interest (**shapefile**)

> [!WARNING]
> The input layers above should have the following units:
> - The multispectral image should use $\color{red}{\text{\textbf{surface reflectance}}}$ (atmospherically corrected)
> - The depth and wave height physical layers should be in $\color{red}{\text{\textbf{centimetres}}}$, while slope is $\color{red}{\text{\textbf{dimensionless}}}$ and ranges [0, 1] (as a ratio between horizontal and vertical distances)

> [!NOTE]
> Paths for input and output folder/files need to be changed to fit the users location and name of field data files.

_Example displaying principal components from the image pre-processing script._
<img width="439" height="554" alt="image" src="https://github.com/user-attachments/assets/07684632-8ed6-45ef-9d27-3baba78ad765" />

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

_Example display from the calibration/validation assignment._
<img width="730" height="650" alt="image" src="https://github.com/user-attachments/assets/77f34f42-4d3e-41b7-a41c-fe8e6a8c2515" />

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

_Example classified image in GEE display window._
<img width="783" height="528" alt="image" src="https://github.com/user-attachments/assets/1d456466-489f-4d6d-b9a7-473e5afeadc6" />

# See Also
[Long-term monitoring of **Heron Reef** in the southern Great Barrier Reef, QLD, Australia](https://marineecosystemsmonitoringlab.com.au/long-term-monitoring-of-heron-reef)

[Long-term monitoring of the **Eastern Banks** in Moreton Bay, QLD, Australia](https://marineecosystemsmonitoringlab.com.au/seagrass-long-term-monitoring)

# References
Smart, J.N., Golding, K.M., Hammerman, N.M., Cowley, D., Markey, K., Carrasco Rivera, D.E., Passenger, J., and Roelfsema, C.M. 2026. Georeferenced benthic photo quadrats and benthic cover data derived from a time series of transect surveys for the Eastern Banks, Moreton Bay, Australia, 2004-2025. _The University of Queensland_, Data Collection. [https://doi.org/10.48610/9383138](https://doi.org/10.48610/9383138)

Golding, K.M., Smart, J.N., Cowley, D., Carrasco Rivera, D.E., Hammerman, N.M., Markey, K., Kovacs, E., Diederiks, F.F., Passenger, J., and Roelfsema, C.M. 2026. Georeferenced benthic photo quadrats and benthic cover data derived from a time series of transect surveys for Heron Reef flat and slope areas, Great Barrier Reef, 2019-2025. _The University of Queensland_, Data Collection. [https://doi.org/10.48610/7df1430](https://doi.org/10.48610/7df1430)

Cowley, D., Carrasco Rivera, D.E., Smart, J.N., Hammerman, N.M., Golding, K.M., Diederiks, F.F., and Roelfsema, C.M. 2025. Insights in Seagrass Distribution, Persistence, and Resilience from Decades of Satellite Monitoring. _Remote Sensing_, 17(24):4033. [https://doi.org/10.3390/rs17244033](https://doi.org/10.3390/rs17244033)

Rowell, D. A., Hammerman, N.M., Golding, K.M., Kenyon, T.M., Meziere, Z., Morgans, C., Brown, K.T., Diederiks, F.F., Carrasco Rivera, D.E., Eigeland, K., Paewai-Huggins, R., Markey, K., Beger, M., Chong, F., Donno, G., Dutton, A., Victoria Hsiao, W., Kininmonth, S., Lawson, C.A., Middleton, H., Eyal, G., and Roelfsema, C. 2025. Multi-scale observations during the 2024 mass coral bleaching event on Heron Reef, Australia. _Marine Biology_, 173(17). [https://doi.org/10.1007/s00227-025-04759-5](https://doi.org/10.1007/s00227-025-04759-5)

Carrasco Rivera, D.E., Diederiks, F.F., Hammerman, N.M., Staples, T., Kovacs, E., Markey, K., and Roelfsema, C.M. 2025. Remote Sensing Reveals Multidecadal Trends in Coral Cover at Heron Reef, Australia. _Remote Sensing_, 17(7):1286. [https://doi.org/10.3390/rs17244033](https://doi.org/10.3390/rs17071286)

Smart, J.N., Hammerman, N.M., Golding, K.M., Markey, K., Kovacs E., and Roelfsema C. 2025. Decadal monitoring shows seagrass decline and community shifts following environmental disturbance in Moreton Bay, south-eastern Queensland, Australia. _Marine and Freshwater Research_, 76(10):MF25049. [https://doi.org/10.1071/MF25049](https://doi.org/10.1071/MF25049)

Kovacs, E.M., Roelfsema, C., Udy, J., Baltais, S., Lyons, M., and Phinn, S. 2022. Cloud Processing for Simultaneous Mapping of Seagrass Meadows in Optically Complex and Varied Water. _Remote Sensing_, 14(3):609. [https://doi.org/10.3390/rs14030609](https://doi.org/10.3390/rs14030609)

Kovacs E., Roelfsema, C.M., Lyons, M., and Phinn, S. 2019. Consideration of Seagrass Remote Sensing in Optical Shallow waters, WoldView 3, Landsat 8, ZY3 and Sentinel 2. _Remote Sensing Letters_, 9(7):686-695. [https://doi.org/10.1080/2150704X.2018.1468101](https://doi.org/10.1080/2150704X.2018.1468101)

Roelfsema, C., Kovacs, E., Roos, P., Terzano, D., Lyons, M., and Phinn, S. 2018. Use of a semi-automated object-based analysis to map benthic composition, Heron Reef, Southern Great Barrier Reef. _Remote Sensing Letters_, 9(4):324-333. [https://doi.org/10.1080/2150704X.2017.1420927](https://doi.org/10.1080/2150704X.2017.1420927)

Phinn, S.R., Kovacs, E.M., Roelfsema, C., Canto, R., Collier, C., and McKenzie, L. 2017. Assessing the potential for satellite image monitoring of seagrass thermal dynamics: for inter- and shallow sub-tidal seagrasses in the inshore Great Barrier Reef World Heritage Area, Australia. _Ecological Indicators_, 11(8):803-824. [https://doi.org/10.1080/17538947.2017.1359343](https://doi.org/10.1080/17538947.2017.1359343) ‍

Roelfsema, C.M., Kovacs, E.M., and Phinn, S.R. 2015. Field data sets for seagrass biophysical properties for the Eastern Banks, Moreton Bay, Australia, 2004–2014. _Scientific Data_, 2:150040. [https://doi.org/10.1038/sdata.2015.40](https://doi.org/10.1038/sdata.2015.40)

Lyons, M., Roelfsema, C.M., Kovacs, E., Samper-Villarreal, J., Saunders, M.I., Maxwell, P., and Phinn, S.R. 2015. Rapid Monitoring of Seagrass Biomass Using a Simple Linear Modelling Approach, in the Field and from Space. _Marine Ecology Progress Series_, 530:1-14. [https://doi.org/10.3354/meps11321](https://doi.org/10.3354/meps11321)

Roelfsema, C.M., Lyons, M., Kovacs, E.M., Maxwell, P., Saunders, M.I., Samper-Villarreal, J., and Phinn, S.R. 2014. Multi-temporal mapping of seagrass cover, species and biomass: A semi-automated object based image analysis approach. _Remote Sensing of Environment_, 150:172-187. [https://doi.org/10.1016/j.rse.2014.05.001](https://doi.org/10.1016/j.rse.2014.05.001)

Leiper, I., Phinn, S.R., Roelfsema, C.M., Joyce, K.E., and Dekker, A.D. 2014. Mapping Coral Reef Benthos, Substrates, and Bathymetry, Using Compact Airborne Spectrographic Imager (CASI) Data data and Spectral Angle Mapper. _Remote Sensing_, 6(7):6423-6445. [https://doi.org/10.3390/rs6076423](https://doi.org/10.3390/rs6076423)

Lyons, M.B., Roelfsema, C.M., and Phinn, S.R. 2013. Towards understanding temporal and spatial dynamics of seagrass landscapes using time-series remote sensing. _Estuarine, Coastal and Shelf Science_, 120:42-53. [https://doi.org/10.1016/j.ecss.2013.01.015](https://doi.org/10.1016/j.ecss.2013.01.015)

Lyons, M., Phinn, S.R., and Roelfsema, C.M. 2011. Integrating Quickbird multispectral satellite and field data: Mapping Bathymetry, Seagrass Cover, Seagrass Species and Change in Moreton Bay, Australia in 2004 and 2007. _Remote Sensing_, 3(1):42-64. [https://doi.org/10.3390/rs3010042](https://doi.org/10.3390/rs3010042) ‍

Roelfsema, C.M., Phinn, S.R., and Dennison, W.C. 2002. Spatial Distribution of Benthic Microalgae on Coral Reefs Determined by Remote Sensing. _Coral Reefs_, 21:264-274. [https://doi.org/10.1007/s00338-002-0242-9](https://doi.org/10.1007/s00338-002-0242-9)
