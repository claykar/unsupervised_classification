#####
# Clay Karnis
#####

# load used packages
require(terra)
require(ggplot2)
require(dplyr)
require(tidyr)
require(tmap)
require(sf)
require(raster)
# load in data
mon <- st_read("./data/wv_counties/counties_detailed.shp")
img <- rast("./data/landsat/LC09_L1TP_017033_20241018_20241018_02_T1_qb/LC09_L1TP_017033_20241018_20241018_02_T1_refl.tif")
img_ir <- rast("./data/landsat/LC09_L1TP_017033_20241018_20241018_02_T1_qb/LC09_L1TP_017033_20241018_20241018_02_T1_tir.tif")
lc <- rast("./data/wv_nlcd2021/w001001.adf")

# set crs
crs(img) <- crs(mon)
crs(img_ir) <- crs(mon)
crs(lc) <- crs(mon)

# resample to img
lc <- resample(lc, img, method="near")
# filter counties, to mon
mon <- mon |> filter(NAME == "Monongalia")
# mask rasters
img <- mask(img, mon, touches=T)
img_ir <- mask(img_ir, mon, touches=T)
lc <- mask(lc, mon, touches=T)

# bbox of viewing area
bbox <- st_bbox(mon)
# crop extent to box for better viewing
img <- crop(img, bbox)
img_ir <- crop(img_ir, bbox)
lc <- crop(lc, bbox)


# find total number of class and values for quant comp
lc_clsss <- extract(lc, mon, fun="table")
lc_values <- values(lc)

gc()

class_labels <- c(
  "11" = "Open Water", 
  "21" = "Developed, Open Space", 
  "22" = "Developed, Low Intensity", 
  "23" = "Developed, Medium Intensity", 
  "24" = "Developed, High Intensity", 
  "31" = "Barren Land", 
  "41" = "Deciduous Forest", 
  "42" = "Evergreen Forest", 
  "43" = "Mixed Forest", 
  "52" = "Shrub/Scrub", 
  "71" = "Grassland/Herbaceous", 
  "81" = "Pasture/Hay", 
  "82" = "Cultivated Crops", 
  "90" = "Woody Wetlands", 
  "95" = "Emergent Herbaceous Wetlands"
)

#####

stack_1 <- c(img, img_ir)

img_m <- tm_shape(stack_1, raster.downsample = F) +
  tm_rgb(r = 1, g = 2, b = 3, max.value = 1) +
  tm_layout(
    frame = FALSE,
    inner.margins = c(0.05, 0.05, 0.05, 0.05),  
    outer.margins = c(0, 0, 0, 0)           
  )

tmap_save(img_m, "./image_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(img)
rm(img_ir)
rm(img_m)
gc()

#####

lc_brks <- c(10.5, 11.5, 21.5, 
             22.5, 23.5, 24.5, 
             31.5, 41.5, 42.5, 
             43.5, 52.5, 71.5, 
             81.5, 82.5, 90.5, 95.5)

lc_clrs <- c("blue", "lightgrey", "grey48", 
             "grey28", "black","deeppink", 
             "forestgreen", "darkgreen", "yellowgreen",
             "gold4", "wheat", "gold3","tan3", 
             "darkslategray4", "lightblue")

lc_lbls <- c("Water", "Developed, Open Space","Developed, Low Intensity",
             "Developed, Medium Intensity","Developed, High Intensity","Barren Land", 
             "Deciduous Forest", "Evergreen Forest","Mixed Forest", "Shrub/Scrub",
             "Grassland/Herbaceous","Pasture/Hay","Cultivated Crops", "Woody Wetlands",
             "Emergent Herbaceous Wetlands")

lc_map <- tm_shape(lc, raster.downsample = F) +
  tm_raster(breaks = lc_brks,
            palette = lc_clrs,
            labels = lc_lbls,
            title = "Land Cover Types") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.4,   
            legend.title.size = 0.6,
            frame = FALSE,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),  
            outer.margins = c(0, 0, 0, 0))

tmap_save(lc_map, "./lc_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(lc_map)
rm(lc)
gc()

#####

set.seed(100) 


clstr_1 <- k_means(stack_1, centers=14, iter.max=300, nstart=150)

c1_brks <- c(0.5, 1.5, 2.5, 3.5, 4.5, 
             5.5, 6.5, 7.5, 8.5, 9.5, 
             10.5, 11.5, 12.5, 13.5, 14.5)

c1_clrs <- c("green3", "grey24",  "darkgreen",  "blue",
             "forestgreen","grey", "yellowgreen", "green4",
             "khaki", "limegreen", "black", "lightgrey",
             "tan3", "grey34")

c1_lbls <- c("1", "2", "3", "4",
             "5", "6", "7", "8",
             "9", "10", "11", "12",
             "13", "14")

c1_map <- tm_shape(clstr_1, raster.downsample = F) +
  tm_raster(breaks = c1_brks,
            palette = c1_clrs,
            labels = c1_lbls,
            title = "Clusters")+
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.5,   
            legend.title.size = 0.7,
            frame = FALSE,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),  
            outer.margins = c(0, 0, 0, 0))

tmap_save(c1_map, "./c1_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(clstr_1)
rm(c1_map)
gc()

#####

set.seed(100) 

clstr_2 <- k_means(stack_1, centers=16, iter.max=300, nstart=150)

c2_brks <- c(0.5, 1.5, 2.5, 3.5, 4.5, 
             5.5, 6.5, 7.5, 8.5, 9.5,
             10.5, 11.5, 12.5, 13.5, 14.5, 
             15.5, 16.5)

c2_clrs <- c("green", "green4",  "grey35",  "darkgreen",
             "mediumseagreen","olivedrab", "tan3", "forestgreen",
             "purple", "grey", "yellow3", "black",
             "green3", "grey23", "blue", "yellow4")

c2_lbls <- c("1", "2", "3", "4",
             "5", "6", "7", "8",
             "9", "10", "11", "12",
             "13", "14", "15", "16")

c2_map <- tm_shape(clstr_2, raster.downsample = F) +
  tm_raster(breaks = c2_brks,
            palette = c2_clrs,
            labels = c2_lbls,
            title = "Clusters")+
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.5,   
            legend.title.size = 0.7,
            frame = FALSE,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),  
            outer.margins = c(0, 0, 0, 0))

tmap_save(c2_map, "./c2_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(clstr_2)
rm(c2_map)
gc()

#####

set.seed(100) 

clstr_3 <- k_means(stack_1, centers=18, iter.max=300, nstart=150)

c3_brks <- c(0.5, 1.5, 2.5, 3.5, 4.5, 
             5.5, 6.5, 7.5, 8.5, 9.5, 
             10.5, 11.5, 12.5, 13.5, 14.5, 
             15.5, 16.5, 17.5, 18.5)

c3_clrs <- c("green4", "blue",  "tan3",  "palegreen4",
             "grey35","grey25", "darkgreen", "limegreen",
             "green", "olivedrab2", "black", "purple",
             "green3", "yellow3", "lightgrey", "yellowgreen",
             "forestgreen", "khaki")

c3_lbls <- c("1", "2", "3", "4",
             "5", "6", "7", "8",
             "9", "10", "11", "12",
             "13", "14", "15", "16",
             "17", "18")

c3_map <- tm_shape(clstr_3, raster.downsample = F) +
  tm_raster(breaks = c3_brks,
            palette = c3_clrs,
            labels = c3_lbls,
            title = "Clusters")+
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.5,   
            legend.title.size = 0.7,
            frame = FALSE,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),  
            outer.margins = c(0, 0, 0, 0))

tmap_save(c3_map, "./c3_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(clstr_3)
rm(c3_map)
gc()

##### 

set.seed(100) 

clstr_4 <- k_means(stack_1, centers=20, iter.max=300, nstart=150)

c4_brks <- c(0.5, 1.5, 2.5, 3.5, 4.5, 
             5.5, 6.5, 7.5, 8.5, 9.5, 
             10.5, 11.5, 12.5, 13.5, 14.5, 
             15.5, 16.5, 17.5, 18.5, 19.5, 20.5)

c4_clrs <- c("blue", "darkgreen",  "seagreen4",  "grey35",
             "tan3","forestgreen", "green3", "yellow3",
             "yellow", "gold3", "gold4", "limegreen",
             "yellow4", "olivedrab4", "grey25", "tan",
             "black", "grey45", "palegreen3", "grey")

c4_lbls <- c("1", "2", "3", "4",
             "5", "6", "7", "8",
             "9", "10", "11", "12",
             "13", "14", "15", "16",
             "17", "18", "19", "20")

c4_map <- tm_shape(clstr_4, raster.downsample = F) +
  tm_raster(breaks = c4_brks,
            palette = c4_clrs,
            labels = c4_lbls,
            title = "Clusters")+
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.5,   
            legend.title.size = 0.7,
            frame = FALSE,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),  
            outer.margins = c(0, 0, 0, 0))


tmap_save(c4_map, "./c4_map.jpg", 
          width =  8, 
          height = 5, 
          units = "in", 
          dpi = 600)

rm(clstr_4)
rm(c4_map)
gc()
