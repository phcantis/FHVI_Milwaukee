## TITLE: PLOTTING FHVI OUTPUTS FOR SHARING WITH WORKING GROUP
## DEVELOPER: PABLO HERREROS CANTIS (phcantis@gmail.com | herrerop@newschool.edu)
## DATE: MAY 2022

## GOAL: TO PRODUCE A VULNERABILITY INDEX FOR EACH OF THE CATEGORIES CONSIDERED AND CARRY OUT A SPATIAL ANALYSIS

## STEPS TAKEN:

## STEP 1:
## STEP 2:

source("src/FHVI_housekeeping_GIS_vars.R")

library(colorspace)

## STEP 1: 

indicators_FHVI <- st_read("data/output/final_FHVI.geojson")

mapper_function_0_100(indicators_FHVI, "HV_n", "HEALTH \nVULNERABILITY", palette = sequential_hcl(5, "Lajolla"))

ggsave(filename = "data/output/HV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_0_100(indicators_FHVI, "SEV_n", "SOCIOECONOMIC \nVULNERABILITY", palette = rev(sequential_hcl(5,"Teal")))

ggsave(filename = "data/output/SEV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_0_100(indicators_FHVI, "HoV_n", "HOUSING \nVULNERABILITY", palette = rev(sequential_hcl(5, "BuPu")))

ggsave(filename = "data/output/HoV_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

mapper_function_0_100(indicators_FHVI, "EXP_RES_n", "FLOODING \nEXPOSURE", palette = rev(sequential_hcl(5, "Blues")))

ggsave(filename = "data/output/EXP_RES_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)


mapper_function_0_100(indicators_FHVI, "EXP_ROAD_n", "FLOODING \nEXPOSURE", palette = rev(sequential_hcl(5, "BuPu")))

ggsave(filename = "data/output/EXP_ROAD_n.png", 
       dpi = 1000,
       width = 15,
       height = 22,
       units = "cm",
       limitsize = FALSE)

