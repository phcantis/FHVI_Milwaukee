# DEVELOPING A FLOOD - HEALTH VULNERABILITY ASSESSMENT FOR THE CITY OF MILWAUKEE, WI

Combining data on health, housing, and socioeconomic vulnerability with flood exposure data to develop indicators and insights about the distribution of flood impacts in Milwaukee, Wisconsin.

This project's original aim was to develop a flood-health vulnerability index (FHVI), a single metric useful to identify areas whose disproportionate exposure and vulnerability to flooding made them a priority when consider the allocation of funds and interventions for flood risk mitigation. However, the development process revealed the importance of being able to trace the different indicator categories considered. For example, it might be unclear why a given census tract stands out as a highly vulnerable one e.g. due to a combination of high vulnerability & exposure values, or just high vulnerability, but no exposure. Because of this, the project has transitioned into a Flood Health Vulnerability *Assessment*, in which several thematic indices are calculated and then overlaid without creating a new metric.

## Workflow

The Flood Health Vulnerability Assessment considers three different types of vulnerability that compound an aggregated vulnerability index. The three vulnerabilities considered are health, socioeconomic, and housing vulnerability. Each vulnerability is assessed through a set of thematic indicators that reflects a higher potential sensitivity or lower reactive capacity in the case of a flood event.

Each vulnerability index is developed through the following steps:

-   The selected indicators under the vulnerability category (health, socioeconomic, or housing) are pre-processed and aggregated to the census tract level. In order to adjust the magnitudes of the indicators to the size of the population of the census tract, each indicator is calculated as a rate or percentage over the total of the population.

-   Each indicator is then normalized to a scale ranging from 0 to 100 so that each indicator has the same influence in the aggregation.

-   The normalized indicators used under each category are summed to obtain a total vulnerability score.

-   The summed vulnerability score is re-normalized to a 0-100 range.

-   Once the three vulnerability indices have been calculated and normalized, an average index is obtained by adding the indices and dividing them by 3. This average vulnerability index is used as a final, aggregated vulnerability metric.

In addition to the three different vulnerabilities, a flood exposure index is developed by combining flood hazard layers with key assets like residential parcels and roads. This index aims to reflect the relative exposure to flooding at the census tract level. The process to develop this index goes as follows:

-   Residential parcels obtained from the city's public GIS data repository are evaluated by measuring their minimum distance to flooding. Parcels located within a 30m radius (\~100 feet) are classified as potentially impacted by flooding. This distance radius is used to conservatively account for potential inaccuracies in the flood risk data, the possibility of occurrence of larger flooding scenarios than the ones considered, and possible indirect impacts on dwellings by for example infiltrating runoff into basements nearby. The percentage of the residential units impacted by flooding is then calculated at the census tract level.

-   A topo-planimetric layer showing Milwaukee's roads is intersected with the city's census tracts to calculate the total road area within each of them. Then, the same dataset is intersected with the flood hazard layer in order to measure the total area affected by flooding within each census tract. The percentage of the total road area impacted by flooding within each census tract is calculated.

-   The two exposure indicators % residential units impacted and % road area flooded are then normalized to a 0-100 range, and the two metrics are averaged to obtain a flood exposure index.

The processes above described lead to the development of two indices - a social vulnerability index (which is the aggregated value of 3 indices) and an exposure index. Both indices have a normalized, non-dimensional value ranging between 0 and 100. In order to identify hotspots where high vulnerability and exposure overlap, we flagged the census tracts whose values for each index fall in the top 75% (or the highest quartile), to then classify the tracts as either a vulnerability hotspot, an exposure hotspot, or a hostpot according to both criteria simultaneously.

## Data and variables considered under each vulnerability / exposure index

The indicators used under each index were selected in close collaboration with members of Groundwork Milwaukee as well as health practitioners located in Milwaukee in a process that considered both their thematic validity and the reduction of collinearity between the variables selected. The collinearity of the indicators selected under different scenarios was evaluated using the Variance Inflation Factor and PCA to understand the clustering between variables. The final variables selected were:

#### Health vulnerability index

-   [Percentage of adults with diabetes](https://www.healthcompassmilwaukee.org/indicators/index/view?indicatorId=81&localeTypeId=4) (Milwaukee Health Compass, 2019).
-   [Percentage of adults reporting having suffered of poor mental health for the last 14 days](https://www.healthcompassmilwaukee.org/?module=indicators&controller=index&action=view&comparisonId=&indicatorId=1835&localeTypeId=4) (Milwaukee Health Compass, 2019).
-   [Age Adjusted ER Rate due to Asthma](https://www.healthcompassmilwaukee.org/?module=indicators&controller=index&action=view&comparisonId=&indicatorId=1835&localeTypeId=4) (Milwaukee Health Compass, 2019)\*.
-   Percentage of the total population with a disability (American Community Survey 5-year estimates, 2019).
-   Percentage of adults without health insurance (American Community Survey 5-year estimates, 2019).

\*Data was obtained at the zip code level and was then disaggregated to the census tract level using an areal weighted approach.

#### Socioeconomic vulnerability index

-   Percentage of the population living under an income ratio below x2 times the poverty line (American Community Survey 5-year estimates, 2019).
-   Percentage of adults above 25 years old who did not obtain a high school diploma (American Community Survey 5-year estimates, 2019).
-   Percentage of the population above 5 years old who speak English "not well" or worse (American Community Survey 5-year estimates, 2019).
-   Percentage of the total population identified as Black, Indigenous or Person of Color (BIPOC) (Decennial Census, 2010).
-   Percentage of the total population aged lower than 18 or older than 65 years old (Decennial Census, 2010).

#### Housing Vulnerability index

-   Percentage of the total number of residential units in the census tract located in a residential building built before 1950 ([Parcel boundaries](https://data.milwaukee.gov/dataset/parcel-outlines) were merged to the city's [Master Property File](https://data.milwaukee.gov/dataset/mprop). Both datasets were obtained from the data.milwaukee.gov platform).
-   Percentage of households inhabited by an adult living alone (American Community Survey 5-year estimates, 2019).
-   Percentage of households without a car (American Community Survey 5-year estimates, 2019).

#### Flood Exposure Index

-   Flood hazard data was created by combining two flood layers:

    -   FEMA's Special Flood Hazard Area (100-year floodplain), an official, federal flood hazard layer that informs risk mitigation practices and requires the purchase of flood insurance for homes located in it. This layer is limited to representing riverine and coastal flooding, overlooking surface flooding caused by excessive runoff under extreme precipitation scenarios.

    -   A surface runoff layer showing flood depth under a 1hr, 100-year precipitation event was generated using the City Catchment Analysis Tool (CityCAT). This model simulates the flow of surface runoff through the shallow water equations within high resolution time steps (0.01s). Besides flow speed, depth and direction, the model computes infiltration processes and the impact of pervious surfaces in slowing down the flow due to their higher roughness. Baseline results from an analysis in the city of Milwaukee can be found [here](https://static1.squarespace.com/static/552ec5f5e4b07754ed72c4d2/t/61533deb38440076c616cbd4/1632845292279/Milwaukee+Factsheet+FINAL.pdf). To learn more about the CityCAT model, you may check [this factsheet](http://www.urbanfloodresilience.ac.uk/documents/factsheet-citycat.pdf) or this [scientific publication](https://www.sciencedirect.com/science/article/pii/S1364815217310009?casa_token=as6H03Seo3QAAAAA:cVSZEBsNt4eJQCJTCNqyHF_mCL9Axx5QscNctaibKnvyauey7EnBGuT6GFlvtMW71XHy6MWa) that explains the model's functioning in detail.

        The simulation to generate this layer was carried out at a 10x10m resolution (\~30x30ft). The Digital Elevation Models (DEMs) at 10x10m were generated by interpolating the DEMs offered by by the USGS at a resolution of 1 arc-second (\~30m) through bilinear interpolation. Green areas used to compute infiltration and roughness were obtained from [EPA's EnviroAtlas data](https://edg.epa.gov/metadata/catalog/search/resource/details.page?uuid=%7Badf673a0-11b4-40d6-befd-8bf75b370cba%7D) at 1x1m (\~3x3ft) and reaggregated to 10x10m using the nearest neighbor method. A Precipitation hyetograph was developed based on NOAA's Atlas 14 data for Milwaukee's station "WEST ALLIS".

The two flood hazard layers were then merged into a single flood hazard layer, which was then used to overlay with the following two datasets:

-   The merged dataset contained [parcel boundaries](https://data.milwaukee.gov/dataset/parcel-outlines) and the city's [Master Property File](https://data.milwaukee.gov/dataset/mprop) (Both datasets were obtained from the data.milwaukee.gov platform).

-   A roads layer generated by filtering features from Milwaukee's transportation planimetric map labelled as "Paved Driveway", "Paved Parking", "Paved Road", "Paved Shoulder", "Unimproved Road", "Unpaved Driveway", "Unpaved Parking", "Unpaved Shoulder". Milwaukee's planimetric map can be obtained [here](https://mclio.maps.arcgis.com/apps/webappviewer/index.html?id=84c7b8d95af04cdda6b0c2ae26590531).

## Instructions to run the .src codebase

To run the codebase of this project, simply open the .R file titled FHVI_index_build. The first lines of this script will source and run the rest of the files to generate intermediate datasets such as shapefiles or geojsons with the pre-processed indicators needed to build the index. Consequently, the FHVI_index_build.R script will apply the aggregation of the variables to generate the indices, followed by the hotspots mapping.

Once the FHVI_index_build.R file has been completely ran, the file FHVI_index_plotting can be used for some quick, preliminary results visualizations.

## Fieldname definitions for output dataset

The final file produced, "final_FHVI.geojson", has the following fields for each census tract:

GEOID - The Census Tract's Unique ID according to the US Census.

ALAND - The total land area in square meters.

TotPop10 - Total population according to the Decennial Census in 2010.

HV_AdultDiabetesRate - Percentage of the tract's adult population that have diabetes.

HV_PoorMentalHealthRate - Percentage of the tract's adult population that reported poor mental health during the previous 14 days to a medical check up.

HV_AsthmaERRate - Age-adjusted ER Rates due to Asthma.

HV_Disability - Percentage of the total population that has a disability.

HV_NoHIns - Percentage of the total population that has a no health insurance.

SEV_BelPovx2 - Percentage of the total population whose income is below a value that is twice the federal poverty line.

SEV_NoDiploma - Percentage of the total population above 25 years old that did not complete high school.

SEV_LangIsol - Percentage of the population above 5 years old that did speaks English "Not Well" or worse.

SEV_BIPOC - Percentage of the total population that was described as Black, Indigenous or Person of Color in the decennial census in 2010.

SEV_VulnAge  - Percentage of the total population younger than 18 years old or older than 65 years old.

HoV_LiveAlone - Percentage of the tract's households with a single adult living alone.

HoV_Pre50 - Percentage of the residential units built before 1950.

HoV_HHNoCar - Percentage of the tract's households without a car.

EXP_ExpHUnits - Percentage of the tract's residential units impacted by flooding.

EXP_ExpRoadArea - Percentage of the tract's total road area impacted by flooding.

EXP_NSites - Number of polluted sites within the tract impacted by flooding (this metric was not included in the indices, as of now).

EXP_PSites - Percentage of the tract's polluted sites impacted by flooding (this metric was not included in the indices, as of now).

HV - Health vulnerability index, as the sum of the indicators within the HV category.

SEV - Socioeconomic vulnerability index, as the sum of the indicators within the SEV category.

HoV - Housing vulnerability index, as the sum of the indicators within the HoV category.

HV_n - Health vulnerability index, normalized to a 0-100 range.

SEV_n - Socioeconomic vulnerability index, normalized to a 0-100 range.

HoV_n - Housing vulnerability index, normalized to a 0-100 range.

EXP_RES_n  - Percentage of the tract's residential units impacted by flooding, normalized to a 0-100 range.

EXP_ROAD_n  - Percentage of the tract's total road area impacted by flooding, normalized to a 0-100 range.

EXP_SITES_n - Percentage of the tract's polluted sites impacted by flooding, normalized to a 0-100 range (this metric was not included in the indices, as of now).

V_n\_sum - Sum of the normalized indices considered (HV_n + SEV_n + HoV_n), divided by 3.

EXP_n\_sum - Sum of the normalized indices considered (EXP_RES_n + EXP_ROAD_n), divided by 3.

V_x\_EXP_n - product of the two indices considedered (V_n\_sum and EXP_n\_sum), as a possible final index resulting from the aggregation of the two.

V_H - A flag field identifying vulnerability hotspot tracts (flagged with a value of 1).

E_H - A flag field identifying exposure hotspot tracts (flagged with a value of 1).

## Key assumptions to keep track of and consider revising in future iterations

As with any research project that relies on the best available data found, this study relies on a number of assumptions that need to be disclosed and understood, as well as solved in the future if new data or support becomes available.

-   Health data obtained at the zip code level required disaggregation to the census tract level. This was done using an areal weight approach, meaning that census tracts were given a new value based on the proportion of their total area overlapping with zip codes. This step was avoided as much as possible, but was still necessary for the indicator showing emergency rates due to Asthma. A better approach to weigh the influence of a zip code over an overlapping tract to disaggregate a variable would be based on the proportion of the residential parcels or disaggregated population living within the tract and the given zip code.

-   The main aggregation method to calculate vulnerability scores and the indices is the sum of indicators (and a division in the case of the final indices). This kind of approach will produce results tending to the average of the indicators aggregated. The methodology is flexible, however, and could easily be adapted to the implementation of weights that prioritize certain impacts / factors over others. The addition of normalized scores could also be replaced by the calculation of z-scores that may better represent how each value differs from the general average and the dataset's variability.

-   The parcel data utilized required slight tweaks:

    -   When assessing the number of residences built prior to 1950, values lower than 1800 were excluded assuming a wrong value.

    -   When linking parcel data to the census tracts, a small number of parcels considered to fall under the boundaries of Milwaukee were falling outside of its boundaries. Because of this, a tolerance of 120m (\~360feet) was used to ensure that all the parcel data was accounted for.

-   The surface runoff model applied to map the flooded areas under a 1-hour, 100-year flooding scenario was subject to the following assumptions, further explained in the links provided.

    -   The topographic data employed (at 10x10m) was the product of a bilinear interpolation based on a 1x1m dataset.

    -   Due to a lack of data and computational resources, the model did not account for the city's drainage infrastructure. Hence, the scenario assumes that, under the storm's intensity and short duration, the sewers would be temporarily unavailable to cope with the incoming water. Other physical interventions such as flood gates or walls are not taken into account, potentially over-estimating flood risk.

    -   The model's resolution of 10x10m was decided based on the high computational requirements to run such a large city at finer resolutions. This resolution also implies that the city's buildings were not accounted for in the simulation, allowing flood waters to flow freely where as in reality it might be redirected by the presence of obstacles.

## 
