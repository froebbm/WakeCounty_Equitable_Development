# Set Up ------------------------------------------------------------------
library(tidyverse)
library(tmap)
library(sf)
tmap_mode("view")

# Functions ---------------------------------------------------------------
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
# Date Values -------------------------------------------------------------
current_date <- Sys.Date()

month_chr  <- lubridate::month(current_date,
                               label = TRUE,
                               abbr  = FALSE) %>% 
  as.character()

month      <- lubridate::month(current_date, label = FALSE)

year       <- lubridate::year(current_date) %>% 
  as.character()