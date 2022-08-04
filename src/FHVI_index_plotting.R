## TITLE: PLOTTING FHVI OUTPUTS FOR SHARING WITH WORKING GROUP
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: MAY 2022

## GOAL: TO PRODUCE A VULNERABILITY INDEX FOR EACH OF THE CATEGORIES CONSIDERED AND CARRY OUT A SPATIAL ANALYSIS

source("src/FHVI_housekeeping_GIS_vars.R")

## STEP 1: 

indicators_FHVI <- st_read("data/output/final_FHVI.geojson")

mapper_function_quintile(indicators_FHVI, fieldname = "HV_n", legend_position = "right", map_title = "HEALTH \nVULNERABILITY", palette = sequential_hcl(5,"Lajolla"))

ggsave(filename = "data/output/HV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "SEV_n", legend_position = "right", map_title="SOCIOECONOMIC \nVULNERABILITY", palette = rev(sequential_hcl(5,"Teal")))

ggsave(filename = "data/output/SEV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname="HoV_n",legend_position = "right", map_title = "HOUSING \nVULNERABILITY", palette = rev(sequential_hcl(5, "BuPu")))

ggsave(filename = "data/output/HoV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "EXP_RES_n", legend_position = "right", map_title =  "FLOODING \nEXPOSURE \nRESIDENTIAL", palette = rev(sequential_hcl(5, "Blues")))

ggsave(filename = "data/output/EXP_RES_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)


mapper_function_quintile(indicators_FHVI, fieldname = "EXP_ROAD_n", legend_position = "right", map_title = "FLOODING \nEXPOSURE \nROADS", palette = rev(sequential_hcl(5, "Blues")))

ggsave(filename = "data/output/EXP_ROAD_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "EXP_n_sum", legend_position = "right", map_title = "FLOODING \nEXPOSURE", palette = rev(sequential_hcl(5, "Blues")))

ggsave(filename = "data/output/EXP_ROADandRES_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "V_n_sum", legend_position = "right", map_title="Social Vulnerability", palette = rev(sequential_hcl(5, "YlOrRd")))

ggsave(filename = "data/output/SVI_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "V_x_EXP_n", legend_position = "right", map_title="FHVI - Prototype \n[confidential]", palette = rev(sequential_hcl(5, "Reds")))

ggsave(filename = "data/output/FHVI_x_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

indicators_FHVI$Hotspot_SV <- hotspot_classifier(indicators_FHVI, "V_n_sum", threshold = 0.75)
indicators_FHVI$Hotspot_EXP <- hotspot_classifier(indicators_FHVI, "EXP_n_sum", threshold = 0.75)

mapper_function_quintile(indicators_FHVI, fieldname = "Hotspot_SV", legend_position = "none", map_title="SVI \nHotspots", palette = rev(sequential_hcl(5, "Reds")))
ggsave(filename = "data/output/SVI_HOTSPOTS.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_quintile(indicators_FHVI, fieldname = "Hotspot_EXP", legend_position = "none", map_title="Exposure \nHotspots", palette = rev(sequential_hcl(5, "Blues")))
ggsave(filename = "data/output/EXP_HOTSPOTS.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)


### Plot Flood Layer + brownfields 

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
        st_dissolve() %>%
        st_intersection(st_dissolve(MKE_cen10))

rm(depth100)
gc()

## FEMA SPECIAL FLOOD HAZARD AREA

fema_fp <- st_read("data/raw/Wisconsin_NFHL_55_20220303/NFHL_55_20220303.gdb", layer = "S_FLD_HAZ_AR") %>% 
        filter(SFHA_TF == "T") %>% 
        st_transform(UTM_16N_meter) %>% 
        st_intersection(model_boundaries) %>% 
        st_cast("MULTIPOLYGON") %>% 
        st_cast("POLYGON") %>%
        st_intersection(st_dissolve(MKE_cen10))

st_write(depth100_sf,
         "data/output/precipitation_flooding_4inches_100years.geojson",
         delete_dsn=TRUE)

st_write(fema_fp,
         "data/output/FEMA_flooding_100yrs_SFHA.geojson",
         delete_dsn=TRUE)



polluted_sites <- st_read("data/intermediate/polluted_sites.shp")

ggplot() +
        geom_sf(data = indicators_FHVI, aes(fill = EXP_SITES) , alpha = 0.5) +
        scale_fill_gradientn(colours = rev(sequential_hcl(5,"Grays")), 
                             breaks = c(0, 20, 40, 60, 80, 100), 
                             labels = c(0, 20, 40, 60, 80, 100),
                             name = "% Sites Exposed",
                             limits = c(0,100)) +
        geom_sf(data = depth100_sf, fill = "#1a8bc4", color = NA) +
        geom_sf(data = fema_fp, fill = "#004466", color = NA) +
        geom_sf(data = polluted_sites, aes(color = type)) + 
        theme_map() + 
        labs(title = "FLOOD RISK \nAND BROWNFIELDS") +
        scale_color_manual(values = c("#FFC466", "#ED3D95", "#3dedaa"),
                           name = "Type of brownfield",
                           labels = c("Open Remediation \nSite", "Solid \nWaste Landfill", "Superfund Site")) +
        theme(title = element_text(size = 26),
              legend.position = "right",
              legend.text = element_text(size = 10),
              legend.title = element_text(size = 15),
              legend.spacing.x = unit(0.2, "cm"),
              legend.key.size = unit(1, "cm",),
              plot.background = element_rect(fill = "white", color = NA))

ggsave(filename = "data/output/EXP_SITES.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

### COMPARISON BETWEEN FEMA AND PLUVIAL LAYERS

ggplot() +
        geom_sf(data = depth100_sf, fill = "#1a8bc4", color = NA) +
        geom_sf(data = fema_fp, fill = "#004466", color = NA) +
        geom_sf(data = city_limit, fill = NA, color = "black") + 
        theme_map() + 
        labs(title = "FEMA RISK \n VS PLUVIAL") +
        theme(title = element_text(size = 26),
              legend.position = "none",
              legend.text = element_text(size = 10),
              legend.title = element_text(size = 15),
              legend.spacing.x = unit(0.2, "cm"),
              legend.key.size = unit(1, "cm",),
              plot.background = element_rect(fill = "white", color = NA))

ggsave(filename = "data/output/FEMA_VS_PLUVIAL.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

hotspots_dataset <- st_read("data/output/final_FHVI_hotspots.geojson")
hotspots_dataset$Hotspot <- factor(hotspots_dataset$Hotspot, levels = c("Vulnerability and Exposure Hotspot",
                                                                        "Vulnerability Hotspot",
                                                                        "Exposure Hotspot",
                                                                        "Not a Hotspot"))

ggplot() +
        geom_sf(data = hotspots_dataset, aes(fill = Hotspot)) +
        theme_map()  +
        theme(title = element_text(size = 26),
              legend.text = element_text(size = 10),
              legend.title = element_text(size = 15),
              legend.spacing.x = unit(0.2, "cm"),
              legend.key.size = unit(1, "cm",),
              legend.position = c(0.64,0.7),
              plot.background = element_rect(fill = "white", color = NA)) +
        scale_fill_manual(values = c("#BE3526", "#F99C1C", "#004466", "#DDDDDD"),
                          name = "FHVA - Hotspots",
                          labels = c("Vulnerability and Exposure",
                                     "Vulnerability",
                                     "Exposure",
                                     "Not a Hotspot"))
        

ggsave(filename = "data/output/HOTSPOTS.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)
