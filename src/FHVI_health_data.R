## TITLE: PROCESSING RAW HEALTH DATA TO GENERATE A FLOOD-HEALTH RISK INDEX IN MILWAUKEE, WI
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: APRIL 2022

## GOAL: TO EXPLORE AND SELECT HEALTH VARIABLES THAT WILL BE FED INTO THE INDEX CALCULATION.
### HEALTH DATA WAS SOURCED FROM https://www.healthcompassmilwaukee.org/. 
### DATA DISCUSSIONS AND INDICATOR SELECTION WAS INFORMED BY CONVERSATIONS WITH 
### HEALTH PRACTITIONERS BASED IN THE MILWAUKEE AREA AND STAFF AT GROUNDWORKS MILWAUKEE.

## STEPS TAKEN:

## STEP 1: LOAD DATA OF PRE-SELECTED VARIABLES
## STEP 2: CORRELATION ANALYSIS TO DISCARD VARIABLES BASED ON COLLINEARITY
## STEP 3: EXPORT SELECTED VARIABLES AS A CENSUS TRACTS SHAPEFILE

source("src/FHVI_housekeeping_GIS_vars.R")

## STEP 1: LOAD DATA OF PRE-SELECTED VARIABLES
### THESE ARE VARIABLES THAT WERE DEEMED OF INTEREST, AND NEED SOME EXPLORATION TO DISCARD UNNECESARY VARIABLES

adults_with_cancer_ct <- read.csv("data/raw/adults_with_cancer_ct_2019.csv",
                                  stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         cancer_rate = Indicator.Rate.Value)

adults_experienced_heart_disease_ct <- read.csv("data/raw/adults_who_experienced_coronary_heart_disease_ct_2019.csv",
                                         stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         heartdis_rate = Indicator.Rate.Value)

adults_with_copd_ct <- read.csv("data/raw/adults_with_copd_ct_2019.csv",
                                stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         copd_rate = Indicator.Rate.Value)

adults_with_kidney_disease_ct <- read.csv("data/raw/adults_with_kidney_disease_ct_2019.csv",
                                          stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         kidneyd_rate = Indicator.Rate.Value)

adults_with_diabetes_ct <- read.csv("data/raw/adults_with_diabetes_ct_2019.csv",
                                          stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         addiab_rate = Indicator.Rate.Value)

adults_with_poor_mental_health_ct <- read.csv("data/raw/adults_poor_mental_health_ct_2019.csv",
                                    stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(GEOID = Location, 
         poormh_rate = Indicator.Rate.Value)

adult_mental_health_er_rate_zcs <- read.csv("data/raw/adult_mental_health_er_rate_zcs_2018_2020.csv",
                                            stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         admental_rate = Indicator.Rate.Value)

diabetes_er_rate_zcs <- read.csv("data/raw/diabetes_er_rate_zcs_2018_2020.csv",
                                 stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         diab_rate = Indicator.Rate.Value)


pedriatic_asthma_er_rate_zcs <- read.csv("data/raw/pediatric_asthma_er_rate_zcs_2014_2016.csv",
                                         stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2014-2016") %>% 
  select(zcs = Location, 
         pedast_rate = Indicator.Rate.Value)

pedriatic_mental_health_er_rate_zcs <- read.csv("data/raw/pediatric_mental_health_er_rate_zcs_2018_2020.csv",
                                                stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         pedmen_rate = Indicator.Rate.Value)

age_adjusted_asthma_zcs <- read.csv("data/raw/asthma_er_rate_zcs_2018_2020.csv",
                                                stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         asthma_rate = Indicator.Rate.Value)

heart_failure_rate_zcs <- read.csv("data/raw/heart_failure_er_rate_zcs_2018_2020.csv",
                                    stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         heartf_rate = Indicator.Rate.Value)

### GROUP ZIP CODE DATA AND CENSUS TRACT DATA TOGETHER

zcs_data <- adult_mental_health_er_rate_zcs %>% 
  left_join(diabetes_er_rate_zcs) %>% 
  left_join(age_adjusted_asthma_zcs) %>%
  left_join(pedriatic_asthma_er_rate_zcs) %>%
  left_join(pedriatic_mental_health_er_rate_zcs) %>% 
  left_join(heart_failure_rate_zcs) %>%
  mutate(zcs = as.character(zcs))

ct_data <- adults_experienced_heart_disease_ct %>%
  left_join(adults_with_cancer_ct) %>%
  left_join(adults_with_copd_ct) %>%
  left_join(adults_with_kidney_disease_ct) %>% 
  left_join(adults_with_diabetes_ct) %>%
  left_join(adults_with_poor_mental_health_ct) %>%
  mutate(GEOID = as.character(GEOID))

### DOWNLOAD GEOMETRIES FOR CENSUS TRACTS - AFTER CHECKING FOR DATA CONSISTENCY, IT SEEMS LIKE THE 
### APPROPRIATE CENSUS TRACTS TO PERFORM THE JOINS TO THE DATA ARE THE ONES LINKED TO THE 2010 CENSUS.

ct_data <- inner_join(select(MKE_cen10, GEOID),
  ct_data)

### ZIP CODE DATA, ON THE OTHER HAND, SEEMS TO REQUIRE THE ZCTAs FROM THE 2000 CENSUS.

zcs_data <- inner_join(
  st_make_valid(select(tigris::zctas(year=2000, state = "Wisconsin"), zcs = ZCTA5CE00)),
  zcs_data) %>% 
  st_transform(UTM_16N_meter)

### TO CONVERT DATA FROM ZIP CODE TO CENSUS TRACT, WE WILL CARRY OUT AN AREAL WEIGHED INTERPOLATION. THIS 
### METHODOLOGY IS NOT PERFECT, SINCE IT WILL WEIGH AREAS THAT MAY NOT HAVE POPULATION (E.G. PARKS). HOWEVER,
### THIS METHODOLOGY IS APPROPIATE TO DEAL WITH THE MINOR DATA GAPS EXPERIENCED IN SOME OF THE DATASETS,
### AS WELL AS THE FACT THAT OTHER TECHNIQUES SUCH AS DASYMETRIC MAPPING ARE CURRENTLY OUT OF SCOPE DUE 
### TO THE COMPLICATIONS THAT STEM FROM SUCH AN APPROACH.

zcs_complete_interpolated <- st_interpolate_aw(select(zcs_data, c(admental_rate, diab_rate)), ct_data, extensive = FALSE)
zcs_missing_interpolated <- st_interpolate_aw(filter(select(zcs_data, c(asthma_rate, pedast_rate, pedmen_rate)), !is.na(asthma_rate)), ct_data, extensive = FALSE)
zcs_missing2_interpolated <- st_interpolate_aw(filter(select(zcs_data, c(heartf_rate)), !is.na(heartf_rate)), ct_data, extensive = FALSE, keep_NA = TRUE)

### BIND DATA TO A SINGLE CENSUS TRACT DATASET
MWK_health_data <- cbind(ct_data, st_drop_geometry(zcs_complete_interpolated)) %>% 
  cbind(st_drop_geometry(zcs_missing_interpolated)) %>%
  cbind(st_drop_geometry(zcs_missing2_interpolated))

### SAVE TO INTERMEDIATE FOR RECORD
st_write(MWK_health_data, 
         "data/intermediate/ct_data_all.shp", 
         delete_dsn=TRUE)

## STEP 2: CORRELATION ANALYSIS TO DISCARD VARIABLES BASED ON COLLINEARITY

### DROP GEOMETRY AND CT CODES
df_correlate <- MWK_health_data %>% 
  select(-c(GEOID)) %>%
  st_drop_geometry

### CORRELATION MATRIX
# chart.Correlation(df_correlate, histogram=TRUE, pch=19)

### THE CHART THAT APPEARS SHOWS HEAVY CORRELATIONS FOR SOME VARIABLES! BUT THE CORRELATIONS SHOWN ARE 
### A SERIES OF 1to1 ASSESSMENTS BETWEEN VARIABLE PAIRS. USING THE VARIANCE INFLATION FACTOR (VIF), WE CAN
### ASSESS HOW EACH VARIABLE IS CORRELATED TO THE REST OF THE VARIABLES. WHEN DEVELOPING PREDICTIVE MODELS, 
### IT IS USUALLY RECOMMENDED THAT THE VIF DOES NOT EXCEED 5 FOR ANY VARIABLE CONSIDERED, AND SHOULD NOT
### EXCEED 10.

usdm::vif(df_correlate)

### THE VIF VALUES REPORTED BY THE ABOVE LINE ECHO THE RESULTS SHOWN IN THE CORRELATION MATRIX - SUPER HIGH!
### LET'S SEE HOW THE VIF VALUES CHANGE AS WE SELECT CERTAIN VARIABLES UNDER DIFFERENT SCENARIOS

### SCENARIO I: COPD, ADULTS WITH DIABETES, POOR MENTAL HEALTH IN ADULTS, PEDIATRIC ASTHMA
### MAXIMUM VIF IS 11 DUE TO THE HEAVY CORRELATION BETWEEN COPD AND DIABETES
# usdm::vif(dplyr::select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate)))

# chart.Correlation(select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate)), histogram=TRUE, pch=19)

### SCENARIO II: COPD, ADULTS WITH DIABETES, POOR MENTAL HEALTH IN ADULTS, PEDIATRIC ASTHMA, HEART FAILURE
### THE VIF FACTOR INCREASES A BIT (UP TO 12) DUE TO THE HIGH CORRELATION BETWEEN PEDIATRIC ASTHMA AND HEART FAILURE RATES.
### THIS INCREASE MAY NOT NECESSARILY BE RELEVANT.

# usdm::vif(dplyr::select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate, heartf_rate)))

# chart.Correlation(select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate, heartf_rate)), histogram=TRUE, pch=19)


### REPLACING COPD AND PEDIATRIC ASTHMA WITH AGE-ADJUSTED ASTHMA ER RATES
### VIF AND CORRELATIONS ARE LOWEST UNDER THIS SCENARIO, AND HENCE HAS BEEN SELECTED AS THE SET OF HEALTH
## VARIABLES TO CONSIDER IN THE INDEX ALONG WITH DISABILITY RATE (OBTAINED FROM THE ACS IN A SEPARATE SCRIPT)
# usdm::vif(dplyr::select(df_correlate, c(addiab_rate, poormh_rate, asthma_rate, heartf_rate)))

# chart.Correlation(select(df_correlate, c(addiab_rate, poormh_rate, asthma_rate, heartf_rate)), histogram=TRUE, pch=19)

## STEP 3: EXPORT SELECTED VARIABLES AS A CENSUS TRACTS SHAPEFILE
### SAVE SELECTED HEALTH VARIABLES, BEING:
#### % ADULTS WITH DIABETES
#### % ADULTS THAT REPORTED POOR MENTAL HEALTH DURING THE PAST 14 DAYS
#### AGE-ADJUSTED ER RATES DUE TO ASTHMA PER 10,000 PEOPLE

st_write(select(MWK_health_data, c(GEOID, addiab_rate, poormh_rate, asthma_rate)),
         "data/intermediate/selected/selected_health_variables.shp",
         delete_dsn = TRUE)

# # PCA 
# 
# myPr <- prcomp(drop_na(df_correlate), scale. = TRUE)
# myPr
# summary(myPr)
# biplot(myPr, scale = 0, choices = c(1,2))
# 
# # PCA WITH SELECTED VARIABLES
# 
# myPr_reduced <- prcomp(select(df_correlate, c(addiab_rate, poormh_rate, asthma_rate)), scale. = TRUE)
# myPr_reduced
# summary(myPr_reduced)
# biplot(myPr_reduced, scale = 0, choices = c(1,2))


rm(list = ls())