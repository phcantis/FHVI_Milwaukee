## TITLE: PROCESSING FLOOD EXPOSURE DATA TO GENERATE A FLOOD-HEALTH RISK INDEX IN MILWAUKEE, WI
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: APRIL 2022

## GOAL: TO PREPARE ONE OR MORE LAYERS SHOWING FLOOD RISK AND SUMMARIZE EXPOSURE DATA AT THE CT LEVEL
## THAT WILL FEED THE INDEX CALCULATION.

## STEPS TAKEN:

## STEP 1: 
## STEP 2: 
## STEP 3: 

source("src/FHVI_housekeeping_GIS_vars.R")

## LOAD FLOODING DATA AND REMOVE WATER BODIES // USE MODEL BOUNDARIES TO SUBSET DATA

depth100 <- rast("data/raw/R100_C1_max_depth_LZW.tiff") 
crs(depth100) <- proj

waterbodies <- sf::st_as_sf(st_geometry(st_read("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/NHDPLUS_H_0404_HU4_GDB/NHDPLUS_H_0404_HU4_GDB.gdb", layer = "NHDWaterbody"))) %>% st_transform(crs = proj)
waterAreas <- sf::st_as_sf(st_geometry(st_read("C:/Users/herrerop/Desktop/Kresge/GIS/Wisconsin/NHDPLUS_H_0404_HU4_GDB/NHDPLUS_H_0404_HU4_GDB.gdb", layer = "NHDArea"))) %>% st_transform(crs = proj)

water <- rbind(waterbodies, waterAreas)
water <- st_intersection(water, model_boundaries)

depth100 <- terra::mask(x = depth100, mask = vect(water), inverse = TRUE)
depth100[depth100 < 0.1] <- NA
depth100[depth100 >= 0.1] <- 1

depth100_sf <- st_as_sf(st_as_stars(depth100)) %>%
  st_dissolve() 

rm(depth100)
gc()

fema_fp <- st_read("data/raw/Wisconsin_NFHL_55_20220303/NFHL_55_20220303.gdb", layer = "S_FLD_HAZ_AR") %>% 
  filter(SFHA_TF == "T") %>% 
  st_transform(UTM_16N_meter) %>% 
  st_intersection(model_boundaries) %>% 
  st_cast("MULTIPOLYGON") %>% 
  st_cast("POLYGON")

# sink_points <- st_read("data/raw/points_closed_depressions/Depression_Pt.shp") %>% 
#   st_transform(UTM_16N_meter) %>%
#   select(grid_code, Depth)
# 
# sinks <- st_read("data/raw/MMSD_depressions_polygons/Depression_Ply.shp") %>% 
#   st_transform(UTM_16N_meter) %>% 
#   st_join(sink_points) %>%
#   st_intersection(model_boundaries) %>%
#   st_cast("MULTIPOLYGON") %>%
#   st_cast("POLYGON") %>% 
#   filter(Depth > 4)

### MERGE ALL DATA INTO A SINGLE FLOOD HAZARD LAYER -- LEAVE SINKS OUT FOR NOW DUE TO DUBIOUS DEPTH DATA ENTRIES

flood_layer <- rbind(st_as_sf(st_geometry(depth100_sf)),
                     st_as_sf(st_geometry(fema_fp))) %>%
  st_dissolve()

rm(fema_fp, depth100_sf, water, waterAreas, waterbodies)
gc()

### EXPOSURE TO RESIDENTIAL PARCELS

res_parcels <- st_read("data/raw/MPROPArchive2021.shp") %>%
  filter(FK_LandUse %in% c(8810, 8811, 8820, 8830, 8890, 8899)) %>%
  st_transform(UTM_16N_meter) %>%
  select(TAXKEY = Taxkey, FK_LandUse, YearBuilt)

res_parcels_GEOID <- st_join(res_parcels,
                       select(MKE_cen10, GEOID),
                       largest = TRUE) %>%
  select(TAXKEY, GEOID)

### SOME PARCELS NEED TO BE JOINED USING A THRESHOLD DISTANCE BECAUSE THEY ARE SLIGHTLY OUT OF THE TRACTS

res_parcels_naGEOID <- res_parcels_GEOID %>%
  filter(is.na(GEOID)) %>%
  select(-GEOID) %>%
  st_join(., select(MKE_cen10, GEOID), join = st_nn, maxdist = 120) %>% 
  st_drop_geometry()

res_parcels_GEOID <- res_parcels_GEOID %>%
  left_join(res_parcels_naGEOID, by = "TAXKEY") %>%
  mutate(GEOID = ifelse(.$GEOID.y %in% res_parcels_naGEOID$GEOID, .$GEOID.y, res_parcels_GEOID$GEOID)) %>% 
  select(TAXKEY, GEOID) %>% 
  st_drop_geometry()

res_parcels <- res_parcels %>% left_join(res_parcels_GEOID, by = "TAXKEY")

mprop <- read_csv("data/raw/mprop.csv") %>% 
  select(c(TAXKEY, NR_UNITS))

### LEFT JOIN WITH NR UNITS DATA SO THAT NAs ARE REPLACED WITH 1 
### AT LEAST THIS WAY WE ENSURE THEY ARE NOT LOST
res_parcels <- left_join(res_parcels, mprop, by = "TAXKEY") %>% 
  replace_na(list(NR_UNITS = 1))

res_parcels <- write_closest_flooding(res_parcels, flood_layer, "d_f", centroids = FALSE)

st_write(res_parcels, 
         "data/intermediate/res_parcels_exposure.shp",
         delete_dsn = TRUE)

# SUMMARIZE TO GEOID LEVEL (% UNITS EXPOSED TO FLOODING)
exposed_units_GEOID <- res_parcels %>%
  st_drop_geometry() %>%
  mutate(is_exposed = case_when(d_f <= 30 ~ "exp_unit",
                             d_f > 30 ~ "unexp_unit")) %>%
  dplyr::group_by(GEOID, is_exposed) %>%
  dplyr::summarise(n_res = sum(NR_UNITS, na.rm = TRUE)) %>%
  pivot_wider(names_from = is_exposed, values_from = n_res) %>% 
  mutate(total_res = sum(exp_unit, unexp_unit, na.rm = TRUE)) %>%
  mutate(exp_unit = case_when(is.na(exp_unit) ~ 0,
                             !is.na(exp_unit)~ exp_unit)) %>%
  mutate(pct_exp_unit = 100 * exp_unit / total_res)

### EXPOSURE BY ROAD
roads <- st_read("data/raw/TopoPlanimetric_-_Transportation_Polygons.shp") %>% 
  st_transform(UTM_16N_meter) %>% 
  st_make_valid() %>% 
  st_intersection(MKE_cen10) %>%
  filter(subtypenam %in% c("Paved Driveway", "Paved Parking", "Paved Road", "Paved Shoulder", "Unimproved Road", "Unpaved Driveway", "Unpaved Parking", "Unpaved Shoulder")) %>%
  mutate(road_m2 = as.numeric(st_area(.)))

# int_roads_flood_layer <- flood_layer %>%
#   st_intersection(roads) %>%
#   mutate(flood_m2 = as.numeric(st_area(.))) %>%
#   st_drop_geometry() %>%
#   select(GEOID, flood_m2)
# 
# write_csv(int_roads_flood_layer, "data/intermediate/int_roads_flood_layer.csv")

int_roads_flood_layer <- read_csv("data/intermediate/int_roads_flood_layer.csv") %>%
  mutate(GEOID = as.character(GEOID))

flood_roads_areas_GEOID <- int_roads_flood_layer %>%
  group_by(GEOID) %>%
  summarize(flood_m2 = sum(flood_m2, na.rm = TRUE))

road_areas_GEOID <- roads %>%
  st_drop_geometry() %>%
  group_by(GEOID) %>%
  summarize(road_m2 = sum(road_m2, na.rm = TRUE)) %>% 
  inner_join(flood_roads_areas_GEOID) %>%
  mutate(pct_road_flood = 100 * flood_m2/ road_m2)

### EXPOSURE OF BROWNFIELDS

# Superfund sites

solid_waste_landfills_historics <- st_read("data/raw/polluted_points/Solid_Waste_%E2%80%93_Landfills_and_Historic_Waste_Site_Points.shp") %>%
  st_transform(UTM_16N_meter) %>%
  st_intersection(select(MKE_cen10, GEOID)) %>%
  mutate(type = "Solid waste landfill, active or historic") %>%
  select(GEOID, type) %>%
  write_closest_flooding(., flooding = flood_layer, name_field = "d_f")

open_remediation_sites <- st_read("data/raw/polluted_points/Remediation_-_Open_Site_Points.shp") %>%
  st_transform(UTM_16N_meter) %>%
  st_intersection(select(MKE_cen10, GEOID)) %>%
  mutate(type = "Open remediation site") %>%
  select(GEOID, type) %>%
  write_closest_flooding(., flooding = flood_layer, name_field = "d_f")

superfund_sites <- st_read("data/raw/polluted_points/WI_Superfund_NPL_Site_Points_2022.shp") %>%
  st_transform(UTM_16N_meter) %>%
  st_intersection(select(MKE_cen10, GEOID)) %>%
  mutate(type = "Superfund site") %>%
  select(GEOID, type) %>%
  write_closest_flooding(., flooding = flood_layer, name_field = "d_f")

polluted_sites <- rbind (solid_waste_landfills_historics, 
                         open_remediation_sites,
                         superfund_sites)

st_write(polluted_sites, 
         "data/intermediate/polluted_sites.shp",
         delete_dsn = TRUE)

polluted_sites_GEOID <- polluted_sites %>%
  st_drop_geometry() %>%
  mutate(is_exposed = case_when(d_f <= 30 ~ "exp_site",
                                d_f > 30 ~ "unexp_site")) %>%
  group_by(GEOID, is_exposed) %>%
  summarise(total_sites = n()) %>%
  pivot_wider(names_from = is_exposed, values_from = total_sites) %>%
  mutate(total_sites = sum(exp_site, unexp_site, na.rm = TRUE)) %>%
  replace_na(list(exp_site = 0, unexp_site = 0)) %>%
  mutate(pct_exp_site = 100 * exp_site / total_sites)

exposure_GEOID <- MKE_cen10 %>%
  select(GEOID) %>%
  left_join(exposed_units_GEOID) %>%
  left_join(road_areas_GEOID) %>%
  left_join(polluted_sites_GEOID) %>%
  replace_na(list(exp_site = 0, unexp_site = 0, total_sites = 0, pct_exp_site = 0)) %>%
  relocate(geometry, .after = last_col())

st_write(exposure_GEOID,
         "data/intermediate/selected_exposure_variables.shp",
         delete_dsn = TRUE)
