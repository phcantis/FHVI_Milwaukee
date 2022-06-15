## TITLE: PROCESSING RAW CENSUS DATA TO GENERATE A FLOOD-HEALTH RISK INDEX IN MILWAUKEE, WI
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: APRIL 2022

## GOAL: TO DOWNLOAD, PROCESS AND SELECT SOCIAL VULNERABILITY VARIABLES THAT WILL FEED THE INDEX CALCULATION.
### DATA DISCUSSIONS AND INDICATOR SELECTION WAS INFORMED BY CONVERSATIONS WITH 
### HEALTH PRACTITIONERS BASED IN THE MILWAUKEE AREA AND STAFF AT GROUNDWORKS MILWAUKEE.

## STEPS TAKEN:

## STEP 1: LOAD LISTS OF VARS TO DIG INTO CENSUS DATA VIA TIDYCENSUS
## STEP 2: DOWNLOAD CENSUS DATA FROM ACS AND DECENNIAL CENSUS 2010
## STEP 3: JOIN ACS AND DECENNIAL CENSUS TABLES INTO A SINGLE FILE
## STEP 4: LOAD RESIDENTIAL PARCELS AND CALCULATE % BUILT PRE-1950 PER CENSUS TRACT

source("src/FHVI_housekeeping_GIS_vars.R")

library(GGally)
library(plotly)

## STEP 1: LOAD LISTS OF VARS TO DIG INTO CENSUS DATA VIA TIDYCENSUS
source("src/FHVI_census_sovi_data_tidycensus_keys.R")

## STEP 2: DOWNLOAD CENSUS DATA FROM ACS AND DECENNIAL CENSUS 2010
MKE_ACS2019 <- get_acs(geography = "tract", variables = vi_total_incomeratio[1],
                       keep_geo_vars = TRUE,
                       state = "WI", county = "Milwaukee", 
                       year = 2019,
                       geometry = TRUE) %>% select(-c(variable, NAME.y, NAME.x, TRACTCE)) %>% rename (!!paste0(vi_total_incomeratio[2], "_e") := estimate, !!paste0(vi_total_incomeratio[2], "_m") := moe)

for(var in acs_vars){
  
  print(var[2])
  
  MKE_ACS2019.temp <- get_acs(geography = "tract", variables = var[1],
                              state = "WI", county = "Milwaukee", 
                              year = 2019,
                              geometry = FALSE) %>% 
    select(-c(variable, NAME)) %>% 
    rename(!!paste0(var[2], "_e") := estimate, !!paste0(var[2], "_s") := moe) %>%
    mutate(!!paste0(var[2], "_s") := .data[[!!paste0(var[2], "_s")]]/1.645)
  
  MKE_ACS2019 <- left_join(MKE_ACS2019, MKE_ACS2019.temp)
  
}

MKE_ACS2019_selection <- MKE_ACS2019 %>% 
  mutate(belpov200 = 100 * (incrat_50_e +
                              incrat_99_e +
                              incrat_124_e +
                              incrat_149_e +
                              incrat_184_e +
                              incrat_199_e
                              )/incrat_total_e,
         no_diploma = 100*(m_NoSch_e + 
                             m_4thg_e +
                             m_6thg_e +
                             m_8thg_e +
                             m_9thg_e +
                             m_10thg_e +
                             m_11thg_e +
                             m_12thg_e +
                             f_NoSch_e + 
                             f_4thg_e +
                             f_6thg_e +
                             f_8thg_e +
                             f_9thg_e +
                             f_10thg_e +
                             f_11thg_e +
                             f_12thg_e)/total_above25_e,
         no_hins = 100*(hins_19A_e +
                          hins_19B_e +
                          hins_64A_e +
                          hins_64B_e +
                          hins_65A_e +
                          hins_65B_e)/total_hins_e,
         lan_isol = 100*(sp517__wll_e + 
                            sp517__all_e +
                            ie517__wll_e +
                            ie517__all_e +
                            ap517__wll_e +
                            ap517__all_e +
                            ol517__wll_e +
                            ol517__all_e +
                            sp1864_nt_wll_e +
                            sp1864_nt_all_e +
                            ie1864_nt_wll_e +
                            ie1864_nt_all_e +
                            ap1864_nt_wll_e +
                            ap1864_nt_all_e +
                            ol1864_nt_wll_e +
                            ol1864_nt_all_e +
                            sp65_nt_wll_e +
                            sp65_nt_all_e +
                            ie65_nt_wll_e +
                            ie65_nt_all_e +
                            ap65_nt_wll_e +
                            ap65_nt_all_e +
                            ol65_nt_wll_e +
                            ol65_nt_all_e)/total_lang_e,
         disability = 100*(m_dis0_5_e +
                             m_dis5_17_e +
                             m_dis18_34_e +
                             m_dis35_64_e +
                             m_dis65_75_e +
                             m_dis75plus_e +
                             f_dis0_5_e +
                             f_dis5_17_e +
                             f_dis18_34_e +
                             f_dis35_64_e +
                             f_dis65_75_e +
                             f_dis75plus_e)/total_dis_e,
         hh_no_car = 100*(owned_nocar_e +
                            rented_nocar_e)/total_hh_nocar_e,
         live_alone = 100*(hh_f_livalone_e + 
                             hh_m_livalone_e)/total_hh_livealone_e) %>%
  select(GEOID, ALAND, belpov200, no_diploma, no_hins, lan_isol, disability, hh_no_car, live_alone)

for(var in decennial_vars){
  
  print(var[2])
  
  MKE_cen10.temp <- get_decennial(geography = "tract", variables = var[1],
                              state = "WI", county = "Milwaukee", 
                              year = 2010,
                              geometry = FALSE) %>% 
    select(-c(variable, NAME)) %>% 
    rename (!!var[2] := value)
  
  MKE_cen10 <- left_join(MKE_cen10, MKE_cen10.temp)
  
}

MKE_cen10_selection <- MKE_cen10 %>%
  mutate(bipoc = 100-(100*White/tot_pop_cen10),
         vuln_age = 100*(m_0_5 +
                           m_6_9 +
                           m_10_14 +
                           m_15_17 +
                           m_65_66 +
                           m_67_69 +
                           m_70_74 +
                           m_75_79 +
                           m_80_84 +
                           m_85plus +
                           f_0_5 +
                           f_6_9 +
                           f_10_14 +
                           f_15_17 +
                           f_65_66 +
                           f_67_69 +
                           f_70_74 +
                           f_75_79 +
                           f_80_84 +
                           f_85plus)/tot_pop_cen10) %>%
  select(GEOID, tot_pop_cen10, bipoc, vuln_age)

## STEP 3: JOIN ACS AND DECENNIAL CENSUS TABLES INTO A SINGLE FILE
MKE_ct_data_vulnerability <- inner_join(MKE_ACS2019_selection, st_drop_geometry(MKE_cen10_selection)) %>%
  st_transform(UTM_16N_meter)

### CORRELATION PLOT / VIF TO CHECK HO COLLINEAR VARIABLES ARE
# graf <- ggpairs(st_drop_geometry(select(MKE_ct_data_vulnerability, -c(ALAND, GEOID))), 
#                 upper = list(continuous = wrap("cor", size = 2.5)))

# ggplotly(graf)

# usdm::vif(st_drop_geometry(select(MKE_ct_data_vulnerability, -c(ALAND, GEOID))))

### LOOKS GOOD! 

## STEP 4: LOAD RESIDENTIAL PARCELS AND CALCULATE % BUILT PRE-1950 PER CENSUS TRACT
### RESIDENTIAL PARCELS BUILT BEFORE 1800 WILL BE EXCLUDED ASSSUMING DATA IS WRONG

### SPATIAL PARCEL DATA IS EXTRACTED FROM HERE https://data.milwaukee.gov/dataset/parcel-outlines
parcels_pre_1950 <- st_read("data/raw/MPROPArchive2021.shp") %>%
  filter(FK_LandUse %in% c(8810, 8811, 8820, 8830, 8890, 8899) & YearBuilt > 1800) %>%
  mutate(pre50 = case_when(YearBuilt < 1950 ~ "pre50",
                           YearBuilt >= 1950 ~ "post50")) %>%
  st_transform(UTM_16N_meter) %>%
  st_join(select(MKE_ct_data_vulnerability, GEOID), largest = TRUE) %>%
  st_drop_geometry %>%
  rename(TAXKEY = Taxkey)

### ADDITIONAL PARCEL DATA WITH RESIDENTIAL UNITS NR EXTRACTED FROM HERE https://data.milwaukee.gov/dataset/mprop 
mprop <- read_csv("data/raw/mprop.csv") %>% 
  select(c(TAXKEY, NR_UNITS))

parcels_pre_1950 <- inner_join(parcels_pre_1950, mprop)

ct_pre50_dweellings <- parcels_pre_1950 %>%
  dplyr::group_by(GEOID, pre50) %>% 
  dplyr::summarise(n_res = sum(NR_UNITS, na.rm = TRUE)) %>%
  pivot_wider(names_from = pre50, values_from = n_res) %>% 
  mutate(total_res = sum(post50, pre50, na.rm = TRUE)) %>%
  mutate(pre50 = case_when(is.na(pre50) ~ 0,
                           !is.na(pre50)~ pre50)) %>%
  mutate(pct_pre50 = 100 * pre50 / total_res)

MKE_ct_data_vulnerability_housing <- left_join(MKE_ct_data_vulnerability, ct_pre50_dweellings)

st_write(MKE_ct_data_vulnerability_housing, 
         "data/intermediate/selected/selected_sovi_variables.shp",
         delete_dsn = TRUE)

rm(list = ls())