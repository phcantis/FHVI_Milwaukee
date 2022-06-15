## TITLE: PROCESSING PRE-SELECTED INDICATORS TO GENERATE A FINAL FLOOD-HEALTH RISK INDEX IN MILWAUKEE, WI
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: MAY 2022

## GOAL: TO PRODUCE A VULNERABILITY INDEX FOR EACH OF THE CATEGORIES CONSIDERED AND CARRY OUT A SPATIAL ANALYSIS

## STEPS TAKEN:

## STEP 1: LOAD THE 4 CATEGORIES CONSIDERED, MERGE INTO A SINGLE DATASET AND RENAME INDICATORS BY CATEGORY
## STEP 2: NORMALIZE, GROUP AND BLEND THE INDICATORS WITHIN EACH CATEGORY

## STEP 1: LOAD THE 4 CATEGORIES CONSIDERED, MERGE INTO A SINGLE DATASET AND RENAME INDICATORS BY CATEGORY
### CATEGORIES: SOCIOECONOMIC VULNERABILITY, HEALTH, HOUSING, EXPOSURE

source("src/FHVI_health_data.R")
source("src/FHVI_census_sovi_data.R")
source("src/FHVI_exposure_data.R")

source("src/FHVI_housekeeping_GIS_vars.R")

SES <- st_read("data/intermediate/selected/selected_sovi_variables.shp")
health <- st_read("data/intermediate/selected/selected_health_variables.shp")
exposure <- st_read("data/intermediate/selected/selected_exposure_variables.shp")

indicators_FHVI <- health %>%
  left_join(st_drop_geometry(SES), by = "GEOID") %>%
  left_join(st_drop_geometry(exposure), by = "GEOID") %>%
  select(GEOID, 
         ALAND, 
         TotPop10 = tt_p_10,
         HV_AdultDiabetesRate = addb_rt, 
         HV_PoorMentalHealthRate = prmh_rt,
         HV_AsthmaERRate = asthm_r,
         HV_Disability = disblty,
         HV_NoHIns = no_hins,
         SEV_BelPovx2 = blpv200,
         SEV_NoDiploma = no_dplm,
         SEV_LangIsol = lan_isl,
         SEV_BIPOC = bipoc,
         SEV_VulnAge = vuln_ag,
         HoV_LiveAlone = live_ln,
         HoV_Pre50 = pct_p50,
         HoV_HHNoCar = hh_n_cr,
         EXP_ExpHUnits = pct_xp_n,
         EXP_ExpRoadArea = pct_rd_,
         EXP_NSites = exp_sit,
         EXP_PSites = pct_xp_s,
         geometry)

# chart.Correlation(st_drop_geometry(select(indicators_FHVI, -c(GEOID, ALAND, TotPop10))), histogram=TRUE, pch=19)

### attempt 1 --> create normalized additions for each category

## STEP 2: NORMALIZE, GROUP AND BLEND THE INDICATORS WITHIN EACH CATEGORY

indicators_FHVI <- indicators_FHVI %>% 
  mutate(HV = normalize(HV_AdultDiabetesRate, output_range = c(0,100)) +
           normalize(HV_PoorMentalHealthRate, output_range = c(0,100)) +
           normalize(HV_AsthmaERRate, output_range = c(0,100)) +
           normalize(HV_Disability, output_range = c(0,100)) +
           normalize(HV_NoHIns, output_range = c(0,100)),
         SEV = normalize(SEV_BelPovx2, output_range = c(0,100)) +
           normalize(SEV_NoDiploma, output_range = c(0,100)) +
           normalize(SEV_LangIsol, output_range = c(0,100)) +
           normalize(SEV_BIPOC, output_range = c(0,100)) +
           normalize(SEV_VulnAge, output_range = c(0,100)),
         HoV = normalize(HoV_LiveAlone, output_range = c(0,100)) +
           normalize(HoV_Pre50, output_range = c(0,100)) +
           normalize(HoV_HHNoCar, output_range = c(0,100)),
         EXP_RES = normalize(EXP_ExpHUnits, output_range = c(0,100)),
         EXP_ROAD = normalize(EXP_ExpRoadArea, output_range = c(0,100)),
         EXP_SITES = normalize(EXP_PSites, output_range = c(0,100))) %>%
  mutate(HV_n = normalize(HV, output_range = c(0, 100)),
         SEV_n = normalize(SEV, output_range = c(0, 100)),
         HoV_n = normalize(HoV, output_range = c(0, 100)),
         EXP_RES_n = normalize(EXP_RES, output_range = c(0, 100)),
         EXP_ROAD_n = normalize(EXP_ROAD, output_range = c(0, 100)),
         EXP_SITES_n = normalize(EXP_SITES, output_range = c(0, 100))) %>%
  mutate(HV_Q5 = quintile_label(., "HV"),
         SEV_Q5 = quintile_label(., "SEV"),
         HoV_Q5 = quintile_label(., "HoV"),
         EXP_RES_Q5 = quintile_label(., "EXP_RES"),
         EXP_ROAD_Q5 = quintile_label(., "EXP_ROAD"),
         EXP_SITES_Q5 = quintile_label(., "EXP_NSites")) %>%
  mutate(V_n_sum = (HV_n + SEV_n + HoV_n)/3,
         EXP_n_sum = (EXP_RES_n + EXP_ROAD_n)/2) %>%
  mutate(V_Q5_sum = (HV_Q5 + SEV_Q5 + HoV_Q5)/(5*3),
         EXP_Q5_sum = (EXP_RES_Q5 + EXP_ROAD_Q5)/(5*2)) %>%
  mutate(V_x_EXP_Q5 = V_Q5_sum * EXP_Q5_sum,
         V_x_EXP_n = normalize((V_n_sum * EXP_n_sum), output_range = c(0,100)))

### CATEGORIZE AS HOTSPOT BASED ON SV AND EXP
indicators_FHVI$V_H <- hotspot_classifier(indicators_FHVI, "V_n_sum", threshold = 0.75)
indicators_FHVI$E_H <- hotspot_classifier(indicators_FHVI, "EXP_n_sum", threshold = 0.75)

### Save all data:
st_write(indicators_FHVI, 
         "data/output/final_FHVI.geojson",
         delete_dsn = TRUE)

### Save hotspots data
hotspots_dataset <- indicators_FHVI %>% 
  select(c(GEOID, V_H, E_H)) %>%
  mutate(Hotspot = "") %>%
  mutate(Hotspot = case_when(V_H == 1 & E_H == 1 ~ "Vulnerability and Exposure Hotspot",
                             V_H == 1 & E_H == 0 ~ "Vulnerability Hotspot",
                             V_H == 0 & E_H == 1 ~ "Exposure Hotspot",))

st_write(hotspots_dataset, 
         "data/output/final_FHVI_hotspots.geojson",
         delete_dsn = TRUE)

### Save Exposure data
st_write(select(indicators_FHVI, c(GEOID, EXP_RES, EXP_RES_n, EXP_ROAD, EXP_ROAD_n, EXP_n_sum)), 
         "data/output/final_FHVI_exposure.geojson",
         delete_dsn = TRUE)

### Save SV data
st_write(select(indicators_FHVI, c(GEOID, V_n_sum, HV_n, SEV_n, HoV_n)), 
         "data/output/final_FHVI_SV.geojson",
         delete_dsn = TRUE)

### Save SV_Health data
st_write(select(indicators_FHVI, c(GEOID, HV_n, HV_AdultDiabetesRate, HV_PoorMentalHealthRate, HV_AsthmaERRate, HV_Disability, HV_NoHIns)), 
         "data/output/final_FHVI_HV.geojson",
         delete_dsn = TRUE)

### Save SV_SEV data
st_write(select(indicators_FHVI, c(GEOID, SEV_n, SEV_BelPovx2, SEV_NoDiploma, SEV_LangIsol, SEV_BIPOC, SEV_VulnAge)), 
         "data/output/final_FHVI_SEV.geojson",
         delete_dsn = TRUE)

### Save SV_Housing data
st_write(select(indicators_FHVI, c(GEOID, HoV_n, HoV_LiveAlone, HoV_Pre50, HoV_HHNoCar)), 
         "data/output/final_FHVI_HoV.geojson",
         delete_dsn = TRUE)
