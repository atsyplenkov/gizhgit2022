library(tidyverse)
library(RSAGA)
library(terra)
library(here)

# Set SAGA env
env <- rsaga.env()

# 1) Load data ------------------------------------------------------------
# Load DEM as terra::rast
dem <- rast(here("data", "dem", "giz_2021_dem_1m.tif"))

# Save it to SAGA format
writeRaster(dem,
            filename = here("data", "dem", "giz_2021_dem_1m.sdat"),
            filetype = "SAGA",
            overwrite = T)

# 2) Filter dem -----------------------------------------------------------
rsaga.filter.simple(
  in.grid = here("data", "dem", "giz_2021_dem_1m.sgrd"), 
  out.grid = here("data", "dem", "giz_2021_dem_r5.sgrd"), 
  method = 'smooth', radius = 5, mode = 'square', 
  env = env
)

# 3) Fill sinks -----------------------------------------------------------
rsaga.fill.sinks(
  in.dem = here("data", "dem", "giz_2021_dem_r5.sgrd"),
  out.dem = here("data", "dem", "giz_2021_dem_r5-f.sgrd"),
  method = "wang.liu.2006",
  env = env
)
