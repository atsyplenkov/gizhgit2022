library(RSAGA)
library(tidyverse)
library(sf)
library(terra)
library(here)

# Set SAGA env
env <- rsaga.env()

# LSalpine factor calculation https://doi.org/10.1016/j.mex.2019.01.004

# 1) Slope mask -----------------------------------------------------------
# load basin shape
ws <- st_read(here("data", "gizh_ws-dem.shp"))

# load preprocessed dem
dem <- rast(here("data/dem/giz_2021_dem_r5-f.sdat")) %>% 
  mask(vect(ws))

# calculate slope
slope <-  terrain(dem,
                  "slope",
                  unit = "degrees")

# create slope mask
slope_mask <- ifel(slope >= 50,
                   NA_real_,
                   1)

# Plot
# Since most of the area is less than 50°,
# we calculated the slope as always
slope_mask %>% 
  as.data.frame(xy = T) %>% 
  ggplot() +
  geom_sf(data = ws,
          fill = NA) +
  geom_raster(aes(x, y,
                  fill = slope)) +
  coord_sf()

# 2) LS factor calculation ------------------------------------------------
# Inspired and modified version from
# https://hess.copernicus.org/preprints/hess-2021-231/

# Catchment area
rsaga.topdown.processing(in.dem = here("data", "dem", "giz_2021_dem_r5-f.sgrd"),
                         out.carea = here("data", "dem", "giz_2021_dem_r5-ca.sgrd"),
                         env = env)


# Catchment area (Multiple flow direction)
rsaga.geoprocessor(lib = "ta_hydrology", 0,
                   list(ELEVATION = here("data", "dem", "giz_2021_dem_r5-f.sgrd"),
                        FLOW = here("data", "dem", "giz_2021_dem_r5-flow.sgrd"),
                        METHOD = 4, 
                        LINEAR_DO = F),
                   env = env) 

# Reclassify catchment area for LS factor
# If contributing area >= 240 m² (flow 120 m length), 240,
# else keep original value
rsaga.geoprocessor(lib = "grid_tools", 15,
                   list(INPUT = here("data", "dem", "giz_2021_dem_r5-flow.sgrd"),
                        RESULT = here("data", "dem", "giz_2021_dem_r5-flrcls.sgrd"),
                        OLD = 120,
                        NEW = 120,
                        SOPERATOR = 4),
                   env = env)

# Calculate LS factor

# Slope(rad)
rsaga.geoprocessor(lib = "ta_morphometry", 0,
                   list(ELEVATION = here("data", "dem", "giz_2021_dem_r5-f.sgrd"),
                        SLOPE = here("data", "dem", "giz_2021_dem_r5-slprad.sgrd")),
                   env = env)

# LS Desmet & Govers 1996
rsaga.geoprocessor(lib = "ta_hydrology", 22,
                   list(SLOPE = here("data", "dem", "giz_2021_dem_r5-slprad.sgrd"),
                        AREA = here("data", "dem", "giz_2021_dem_r5-flrcls.sgrd"),
                        LS = here("data", "dem", "ls", "ls_dg96_rcls.sgrd"),
                        METHOD = 1), env = env)

# 3) Explore results ------------------------------------------------------
ls <- rast( here("data", "dem", "ls", "ls_dg96_rcls.sdat")) %>% 
  mask(vect(ws))

ls %>% 
  as.data.frame(xy = T) %>% 
  dplyr::rename(LS = 3) %>% 
  ggplot() +
  geom_raster(aes(x, y,
                  fill = LS)) +
  scale_fill_viridis_c(direction = -1) +
  coord_fixed() +
  theme_void()

# Median values
global(ls, median, na.rm = T)
