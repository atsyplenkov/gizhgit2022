+-- data
|   +-- dem
|   |   +-- giz_2021_dem_1m.sgrd # DEM in SAGA format
|   |   +-- giz_2021_dem_1m.tif # Original DEM
|   |   +-- giz_2021_dem_r5-ca.sgrd # Catchment area
|   |   +-- giz_2021_dem_r5-f.sgrd # Filtered and filled DEM
|   |   +-- giz_2021_dem_r5-flow.sgrd # Flow accumulation layer
|   |   +-- giz_2021_dem_r5-flrcls.sgrd # Reclassified flow acc. layer
|   |   +-- giz_2021_dem_r5-slprad.sgrd # Slope in radians
|   |   +-- giz_2021_dem_r5.sgrd # Filtered DEM
|   |   \-- ls
|   |       \-- ls_dg96_rcls.sgrd # LS 
|   +-- gizh_ws-dem.shp # Watershed border
+-- gizhgit2022.qgz # QGIS project
+-- gizhgit2022.Rproj # Rproject
\-- R
    +-- 01_dem-preparation.R
    \-- 02_ls-calculation.R
