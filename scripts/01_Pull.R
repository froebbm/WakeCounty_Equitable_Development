# Set Up ------------------------------------------------------------------
source('./scripts/00_setup.R', echo = TRUE)

# Data Pull ---------------------------------------------------------------
parcel_URL <- paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                             'SHAPEFILES/Wake_Property_',
                             year, '_', month, '.zip')

parcels <- url_shp_to_sf(parcel_URL)
parcels <- parcels %>% 
  filter(st_is_valid(parcels)) %>% 
  st_make_valid()

out_path <- paste0("./data/Parcels_", month_chr, "_", year)

write_sf(parcels, paste0(out_path, '.shp'))
write_rds(parcels, paste0(out_path, '.rds'))


city_URL <- paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                   'SHAPEFILES/Wake_Jurisdictions_',
                    year, '_', month, '.zip')

municipality <- url_shp_to_sf(city_URL)
out_path     <- paste0("./data/Municipal_", month_chr, "_", year)

write_sf(municipality, paste0(out_path, '.shp'))
write_rds(municipality, paste0(out_path, '.rds'))

wake_url <- paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                  'SHAPEFILES/Wake_Zoning_',
                  year, '_', month, '.zip')

wake <- url_shp_to_sf(wake_url)
wake <- st_sf(st_union(wake))

out_path <- paste0("./data/Wake_Zoning_", 
                   month_chr, "_", year)
write_sf(wake, paste0(out_path, '.shp'))
write_rds(wake, paste0(out_path, '.rds'))

