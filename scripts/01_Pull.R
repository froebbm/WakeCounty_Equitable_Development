#### SetUp ####
dir = "C:/Users/brian/OneDrive/Documents/GitHub/WakeCounty_Affordable_Housing"
setwd(dir)
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
  y <- read_sf(shp, quiet = TRUE)

  unlink(dir(td))
  setwd(wd)
  return(y)
}
#### Data Pulls ####
Parcel_URL = paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                    'SHAPEFILES/Wake_Property_2020_10.zip')
Parcels  = url_shp_to_spdf(Parcel_URL)
Parcels  = st_make_valid(Parcels)
Parcels  = subset(Parcels, st_is_valid(Parcels))

out_path = "./data/Parcels_October_2020"
write_sf(Parcels, paste0(out_path, '.shp'))
write_rds(Parcels, paste0(out_path, '.rds'))


City_URL = paste0('ftp://wakeftp.co.wake.nc.us/gis/Webdownloads/',
                  'SHAPEFILES/Wake_Jurisdictions_2020_10.zip')
Municipality = url_shp_to_sf(City_URL)
out_path     = "./data/Municipal_October_2020"
write_sf(Municipality, paste0(out_path, '.shp'))
write_rds(Municipality, paste0(out_path, '.rds'))