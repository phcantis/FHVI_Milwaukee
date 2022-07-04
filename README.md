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

ADD WHAT HAPPENS NEXT (HOTSPOTS CLASSIFICATION AND OVERLAY)

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

-   Percentage of the population living under an income ratio bloew x2 times the poverty line (American Community Survey 5-year estimates, 2019).
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

## Key assumptions to keep track of and consider revising in future iterations

zip code disagregation

averaging approach vs weights // exposure is average of res + roads

parcel data - something is in there i bet

raster data resampling

flood model

## Instructions to run the .src codebase

## Fieldname definitions for output dataset
