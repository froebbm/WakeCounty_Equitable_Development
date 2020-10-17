# SetUp -------------------------------------------------------------------
source('./scripts/SetUp.R', echo = TRUE)

# Extracting Vacant -------------------------------------------------------
parcels            <- read_rds("./data/Parcels_October_2020.rds")
parcels$area       <- as.numeric(st_area(parcels))
parcels            <- st_centroid(parcels)
vacant_parcels     <- subset(parcels, parcels$LAND_CLASS == "VAC")
non_vacant_parcels <- subset(parcels, parcels$LAND_CLASS != "VAC")

non_vacant_parcels$landuse <- if_else(non_vacant_parcels$SITE == 6100,
                                      true  = "Residential",
                                      false = "Non-Residential")

exp_lu_join <- st_join(vacant_parcels, 
                       non_vacant_parcels[c("PIN_NUM", "landuse", 
                                            "area",    "geometry")],
                       join = st_is_within_distance, 
                       dist = 1000, 
                       suffix = c("", "_org")
                       ) %>%
               st_drop_geometry()

write_rds(exp_lu_join, "./data/vacant_join_October_2020.rds")






