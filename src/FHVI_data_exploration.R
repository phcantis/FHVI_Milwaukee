library(data.table)
library(ggplot2)
library(ggcorrplot)
library(tigris)
library(tidycensus)
library(PerformanceAnalytics)
library(usdm)
library(pca3d)
library(sf)
library(dplyr)

source("C:/Users/herrerop/Desktop/GIS/housekeeping_GIS_vars.R")

options(tigris_class = "sf")

# OPEN DATA

adults_with_cancer_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_with_cancer_ct_2019.csv",
                                  stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         cancer_rate = Indicator.Rate.Value)

adults_experienced_heart_disease_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_who_experienced_coronary_heart_disease_ct_2019.csv",
                                         stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         heartdis_rate = Indicator.Rate.Value)

adults_with_copd_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_with_copd_ct_2019.csv",
                                stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         copd_rate = Indicator.Rate.Value)

adults_with_kidney_disease_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_with_kidney_disease_ct_2019.csv",
                                          stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         kidneyd_rate = Indicator.Rate.Value)

adults_with_diabetes_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_with_diabetes_ct_2019.csv",
                                          stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         addiab_rate = Indicator.Rate.Value)

adults_with_poor_mental_health_ct <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adults_poor_mental_health_ct_2019.csv",
                                    stringsAsFactors = FALSE) %>%
  filter(Period.of.Measure == 2019) %>% 
  select(ct = Location, 
         poormh_rate = Indicator.Rate.Value)

adult_mental_health_er_rate_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/adult_mental_health_er_rate_zcs_2018_2020.csv",
                                            stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         admental_rate = Indicator.Rate.Value)

diabetes_er_rate_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/diabetes_er_rate_zcs_2018_2020.csv",
                                 stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         diab_rate = Indicator.Rate.Value)


pedriatic_asthma_er_rate_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/pediatric_asthma_er_rate_zcs_2014_2016.csv",
                                         stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2014-2016") %>% 
  select(zcs = Location, 
         pedast_rate = Indicator.Rate.Value)

pedriatic_mental_health_er_rate_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/pediatric_mental_health_er_rate_zcs_2018_2020.csv",
                                                stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         pedmen_rate = Indicator.Rate.Value)

age_adjusted_asthma_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/asthma_er_rate_zcs_2018_2020.csv",
                                                stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         asthma_rate = Indicator.Rate.Value)

heart_failure_rate_zcs <- read.csv("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/heart_failure_er_rate_zcs_2018_2020.csv",
                                    stringsAsFactors = FALSE) %>% 
  filter(Period.of.Measure == "2018-2020") %>% 
  select(zcs = Location, 
         heartf_rate = Indicator.Rate.Value)

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
  mutate(ct = as.character(ct))

ct_data <- inner_join(
  st_make_valid(select(tigris::tracts(state = "Wisconsin", "Milwaukee", year = 2010), ct=GEOID10)),
  ct_data)

zcs_data <- inner_join(
  st_make_valid(select(tigris::zctas(year=2000, state = "Wisconsin"), zcs = ZCTA5CE00)),
  zcs_data)

zcs_complete_interpolated <- st_interpolate_aw(select(zcs_data, c(admental_rate, diab_rate)), ct_data, extensive = FALSE)
zcs_missing_interpolated <- st_interpolate_aw(filter(select(zcs_data, c(asthma_rate, pedast_rate, pedmen_rate)), !is.na(asthma_rate)), ct_data, extensive = FALSE)
zcs_missing2_interpolated <- st_interpolate_aw(filter(select(zcs_data, c(heartf_rate)), !is.na(heartf_rate)), ct_data, extensive = FALSE, keep_NA = TRUE)

MWK_health_data <- cbind(ct_data, st_drop_geometry(zcs_complete_interpolated)) %>% 
  cbind(st_drop_geometry(zcs_missing_interpolated)) %>%
  cbind(st_drop_geometry(zcs_missing2_interpolated))

st_write(MWK_health_data, 
         "C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/FHVI/Health_Indicators_Data/ct_data_all.shp", 
         delete_dsn=TRUE)

# CORRELATION MATRIX FOR ALL

df_correlate <- MWK_health_data %>% 
  select(-c(ct)) %>%
  st_drop_geometry

corr <- round(cor(df_correlate), 2)

ggcorrplot(corr, p.mat = cor_pmat(df_correlate), hc.order = TRUE,
           type = "lower", insig = "blank", lab = TRUE,
           colors = c("#6D9EC1", "white", "#E46726"))

chart.Correlation(df_correlate, histogram=TRUE, pch=19)


# CORRELATION MATRIX REMOVING BASED ON VIF

usdm::vif(df_correlate)

# suggested scenarios 
usdm::vif(dplyr::select(df_correlate, c(copd_rate, pedast_rate, diab_rate, admental_rate, pedmen_rate)))
usdm::vif(dplyr::select(df_correlate, c(diab_rate, pedast_rate, admental_rate, pedmen_rate)))
usdm::vif(dplyr::select(df_correlate, c(copd_rate, pedast_rate, admental_rate, pedmen_rate)))
usdm::vif(dplyr::select(df_correlate, c(asthma_rate, diab_rate, admental_rate, pedmen_rate)))

# post meeting scenario
usdm::vif(dplyr::select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate)))
usdm::vif(dplyr::select(df_correlate, c(copd_rate, addiab_rate, poormh_rate, pedast_rate, heartf_rate)))
usdm::vif(dplyr::select(df_correlate, c(addiab_rate, poormh_rate, asthma_rate, heartf_rate)))
usdm::vif(dplyr::select(df_correlate, c(addiab_rate, poormh_rate, asthma_rate)))

df_correlate_reduced <- MWK_health_data %>% 
  select(c(addiab_rate, poormh_rate, asthma_rate)) %>%
  st_drop_geometry

# corr <- round(cor(df_correlate_reduced), 2)
# 
# ggcorrplot(corr, p.mat = cor_pmat(df_correlate_reduced), hc.order = TRUE,
#            type = "lower", insig = "blank", lab = TRUE,
#            colors = c("#6D9EC1", "white", "#E46726"))

chart.Correlation(df_correlate_reduced, histogram=TRUE, pch=19)

# PCA 

myPr <- prcomp(df_correlate, scale. = TRUE)
myPr
summary(myPr)
biplot(myPr, scale = 0, choices = c(1,2))

# PCA reduced

myPr_reduced <- prcomp(df_correlate_reduced, scale. = TRUE)
myPr_reduced
summary(myPr_reduced)
biplot(myPr_reduced, scale = 0)


# PCA no cancer

myPr_no_cancer <- prcomp(dplyr::select(df_correlate, -cancer_rate), scale. = TRUE)
myPr_no_cancer
summary(myPr_no_cancer)
biplot(myPr_no_cancer, scale = 0)

