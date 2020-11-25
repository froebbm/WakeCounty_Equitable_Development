#### SetUp ####
source('./scripts/SetUp.R', echo = TRUE)
#### Functions ####
url_shp_to_sf <- function(URL) {
  
  require(sf)
  
  wd <- getwd()
  td <- tempdir()
  setwd(td)
  
  temp <- tempfile(fileext = ".zip")
  download.file(URL, temp)
  unzip(temp)
  
  shp <- dir(tempdir(), "*.shp$")
  lyr <- sub(".shp$", "", shp)
  
  if(length(shp) > 1){
    y <- read_sf(shp[1], quiet = TRUE)
  } else {
    y <- read_sf(shp, quiet = TRUE)
    
  }

  unlink(dir(td))
  setwd(wd)
  return(y)
}
#### Data Pulls ####
parcel_URL = paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                    'SHAPEFILES/Wake_Property_2020_10.zip')
parcels  = url_shp_to_spdf(parcel_URL)
parcels  = st_make_valid(parcels)
parcels  = subset(parcels, st_is_valid(parcels))

out_path = "./data/Parcels_October_2020"
write_sf(parcels, paste0(out_path, '.shp'))
write_rds(parcels, paste0(out_path, '.rds'))


city_URL = paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                  'SHAPEFILES/Wake_Jurisdictions_2020_10.zip')
municipality = url_shp_to_sf(city_URL)
out_path     = "./data/Municipal_October_2020"
write_sf(municipality, paste0(out_path, '.shp'))
write_rds(municipality, paste0(out_path, '.rds'))

wake_url = paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                  'SHAPEFILES/Wake_Zoning_2020_10.zip')
wake = url_shp_to_sf(wake_url)
wake =st_sf(st_union(wake))
out_path     = "./data/Wake_October_2020"
write_sf(municipality, paste0(out_path, '.shp'))
write_rds(municipality, paste0(out_path, '.rds'))

