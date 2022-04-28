if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, readxl, ggcorrplot, PerformanceAnalytics, usdm, stars, geojsonsf, geojsonio, raster, tidyr, ggplot2, ggthemes, ggpubr, gdalUtils, sf, dplyr, tidycensus, tidyverse)

options(tigris_class = "sf")

options(scipen=999)

`%nin%` = Negate(`%in%`)

UTM_16N_meter <- "EPSG:26916"
epsg_latlon <- "EPSG:4326"

city_limit <- st_read("data/raw/citylimit.shp") %>% st_transform(UTM_16N_meter)

normalize <- function(x, output_range=c(0,1)) {
  
  a <- output_range[1]
  b <- output_range[2]
  
  norm_range <- b-a
  
  max_min <- (max(x, na.rm = TRUE)-min(x, na.rm = TRUE))
  
  return(a + ((x-min(x, na.rm = TRUE))*norm_range)/(max_min))

}

write_closest_flooding <- function(x, flooding, name_field, centroids = FALSE){
  
  if (centroids == TRUE){
    
    data_input <- st_centroid(x)
    
  } else {data_input <- x}
  
  print("calculating nearest features")
  nearest_features <- st_nearest_feature(data_input, flooding)
  
  print("slicing")
  flooding_sliced <- slice(flooding, nearest_features)
  
  print("calculating distances")
  x[name_field] <- as.numeric(st_distance(data_input, flooding_sliced, by_element = TRUE))
  
  return(x)
  
}

second_zero_NAs <- function(df){
  
  boro_cd <- df[,"boro_cd"]
  
  df_e <- df[,grepl('_e', names(df))]
  df_m <- df[,grepl('_s', names(df))]
  
  df_m[df_e==0 & (apply(df_e, 2, duplicated))] <- NA
  
  df_output <- data.frame(df_e, df_m)
  
  df_output["boro_cd"] <- boro_cd
  
  return(df_output)
  
}

quintile_label <- function(df, field_quantilize, positive=TRUE, stars=FALSE, drop_geom=TRUE){
  
  if(stars==TRUE) {
    
    input_save <- df
    
    df <- st_as_sf(df)
    
  } 
    
  if(drop_geom==TRUE){
    
    df_aux <- (df[,field_quantilize]) %>% st_drop_geometry()
    
  } else {
    df_aux <- (df[,field_quantilize])}
    
    Q5 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.8, na.rm = TRUE))
    Q4 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.6, na.rm = TRUE))
    Q3 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.4, na.rm = TRUE))
    Q2 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.2, na.rm = TRUE))
    Q1 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.0, na.rm = TRUE))
    
    if (positive == TRUE){
      df_aux[, "Quintile"] <- 1
      df_aux[df_aux[,field_quantilize] > Q2,"Quintile"] <- 2
      df_aux[df_aux[,field_quantilize] > Q3,"Quintile"] <- 3
      df_aux[df_aux[,field_quantilize] > Q4,"Quintile"] <- 4
      df_aux[df_aux[,field_quantilize] > Q5,"Quintile"] <- 5
    } else {
      df_aux[, "Quintile"] <- 5
      df_aux[df_aux[,field_quantilize] > Q2,"Quintile"] <- 4
      df_aux[df_aux[,field_quantilize] > Q3,"Quintile"] <- 3
      df_aux[df_aux[,field_quantilize] > Q4,"Quintile"] <- 2
      df_aux[df_aux[,field_quantilize] > Q5,"Quintile"] <- 1
    }
    
    if(stars == TRUE) {
      
      df$Quintile <- df_aux$Quintile
      df <- dplyr::select(df, Quintile)
      
      df_rasterized <- st_rasterize(df, template = input_save)
      
      return(df_rasterized)
      
    }
    
    
    
    return (as.integer(df_aux$Quintile))
  
}


quartile_label <- function(df, field_quantilize, positive=TRUE, stars=FALSE, drop_geom=TRUE){
  
  if(stars==TRUE) {
    
    input_save <- df
    
    df <- st_as_sf(df)
    
  } 
  
  if(drop_geom==TRUE){
    df_aux <- (df[,field_quantilize]) %>% st_drop_geometry()
    } else {df_aux <- (df[,field_quantilize])}
  
  Q4 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.75, na.rm = TRUE))
  Q3 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.50, na.rm = TRUE))
  Q2 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.25, na.rm = TRUE))
  Q1 <- as.numeric(quantile(df_aux[,field_quantilize,] ,.0, na.rm = TRUE))
  
  if (positive == TRUE){
    df_aux[, "Quintile"] <- 1
    df_aux[df_aux[,field_quantilize] > Q2,"Quintile"] <- 2
    df_aux[df_aux[,field_quantilize] > Q3,"Quintile"] <- 3
    df_aux[df_aux[,field_quantilize] > Q4,"Quintile"] <- 4
  } else {
    df_aux[, "Quintile"] <- 4
    df_aux[df_aux[,field_quantilize] > Q2,"Quintile"] <- 3
    df_aux[df_aux[,field_quantilize] > Q3,"Quintile"] <- 2
    df_aux[df_aux[,field_quantilize] > Q4,"Quintile"] <- 1
  }
  
  return (as.integer(df_aux$Quintile))
}

hotspot_classifier <- function(df, field_quantilize, threshold=0.8, positive=TRUE, stars=FALSE, drop_geom=TRUE){
  
  if(stars==TRUE) {
    
    input_save <- df
    
    df <- st_as_sf(df)
    
  } 
  
  if(drop_geom==TRUE){
    df_aux <- (df[,field_quantilize]) %>% st_drop_geometry()
  } else {df_aux <- (df[,field_quantilize])}
  
  Q_hotspot <- as.numeric(quantile(df_aux[,field_quantilize,], threshold, na.rm = TRUE))
  
  if (positive == TRUE){
    df_aux[, "Quintile"] <- 0
    df_aux[df_aux[,field_quantilize] > Q_hotspot,"Quintile"] <- 1
  } else {
    df_aux[, "Quintile"] <- 1
    df_aux[df_aux[,field_quantilize] > Q_hotspot,"Quintile"] <- 0
  }
  
  return (as.integer(df_aux$Quintile))
  
}

mapper_function_quintile <- function(data_df, fieldname, map_title, legend_position="none", title_size=36){
  
  
  if(length(unique(quintile_label(data_df, fieldname)))== 5)  {
    scale_palette <- c("#CCE0EB", "#99C2D6", "#67A3C2","#3485AD", "#016699")
  } else if (length(unique(quintile_label(data_df, fieldname)))== 4) {
    scale_palette <- c("#CCE0EB", "#99C2D6","#3485AD", "#016699")
  } else if (length(unique(quintile_label(data_df, fieldname)))== 3) {
    scale_palette <- c("#CCE0EB", "#67A3C2","#016699")
  } else if (length(unique(quintile_label(data_df, fieldname)))== 2) {
    scale_palette <- c("#CCE0EB", "#016699")
  }
  
  plot <- ggplot() +
    geom_sf(data = data_df, aes(fill = factor(quintile_label(data_df, fieldname)))) +
    theme_map() +
    theme(legend.position = legend_position,
          title = element_text(size = title_size)) + 
    labs(title = map_title) +
    scale_fill_manual(values = scale_palette, name= "Quintile")
  
  return(plot)
  
}

mapper_function_equal_breaks <- function(data_df, fieldname, map_title, legend_position="none", title_size=36, n_breaks=5){
  
  
  if(n_breaks == 5)  {
    scale_palette <- c("#CCE0EB", "#99C2D6", "#67A3C2","#3485AD", "#016699")
    my_breaks <- c(0, 0.2, 0.4, 0.6, 0.8, 1)
  } else if (n_breaks == 4) {
    scale_palette <- c("#CCE0EB", "#99C2D6","#3485AD", "#016699")
    my_breaks <- c(0, 0.25, 0.5, 0.75)
  } else if (n_breaks== 3) {
    scale_palette <- c("#CCE0EB", "#67A3C2","#016699")
    my_breaks <- c(0, 0.33, 0.4)
  } else if (n_breaks == 2) {
    scale_palette <- c("#CCE0EB", "#016699")
    my_breaks <- c(0, 0.5)
  }
  
  plot <- ggplot() +
    geom_sf(data = data_df, aes_string(fill = fieldname)) +
    theme_map() +
    theme(title = element_text(size = title_size),
          legend.position = legend_position,
          legend.text = element_text(size = 25),
          legend.title = element_text(size = 30),
          legend.spacing.x = unit(0.2, "cm"),
          legend.key.size = unit(2, "cm")) + 
    labs(title = map_title) +
    scale_fill_gradientn(colours = scale_palette, 
                         breaks = my_breaks,
                         labels = my_breaks,
                         name= "Hotspot \nScore")
  
  return(plot)
  
}

mapper_legender_frame <- function(data_df, fieldname, legend_position="top", text_size=25, text_title_size=30, legend_name="Quintile", key_size_cm=1.5, div_quint=1){
  
  plotted_legend <- ggplot() +
  geom_sf(data = data_df, aes(fill = factor(quintile_label(data_df, fieldname)/div_quint))) +
  lims(x = c(0,0), y = c(0,0))+
  theme_void()+
  theme(legend.position = legend_position, #c(0.5,0.5),
        legend.key.size = unit(key_size_cm, "cm"),
        legend.text = element_text(size =  text_size),
        legend.title = element_text(size = text_title_size, face = "bold")) +
  scale_fill_manual(values = c("#CCE0EB", "#99C2D6", "#67A3C2","#3485AD", "#016699"), name= "Quintile", 
                    guide=guide_legend(reverse=T))
  
  return(plotted_legend)

}

pg <- function(sf_obj){
  
  return(plot(st_geometry(sf_obj)))
  
}

st_dissolve <- function(sf_obj, field.var, cast_to="POLYGON"){
  
  field.var <- enquo(field.var)
  
  dissolved <- sf_obj %>% group_by(!!field.var) %>% summarize() %>% st_make_valid() %>% st_cast(cast_to)
  
  return(dissolved)
  
}
