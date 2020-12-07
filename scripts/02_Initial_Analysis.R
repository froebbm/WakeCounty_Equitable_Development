# SetUp -------------------------------------------------------------------
source('./scripts/00_setup.R', echo = TRUE)

# Extracting Vacant -------------------------------------------------------
parcels_path       <- paste0("./data/Parcels_", month_chr, 
                             "_", year, ".rds")

parcels            <- read_rds(parcels_path)
parcels$area       <- as.numeric(st_area(parcels))
vacant_parcels     <- subset(st_centroid(parcels), 
                             parcels$LAND_CLASS == "VAC")
non_vacant_parcels <- subset(st_centroid(parcels), 
                             parcels$LAND_CLASS != "VAC")

non_vacant_parcels$landuse <- if_else(non_vacant_parcels$SITE == 6100,
                                      true  = "Residential",
                                      false = "Non-Residential")

out_path <- paste0("./data/vacant_join_", month_chr, 
                   "_", year, ".rds")

exp_lu_join <- st_join(vacant_parcels, 
                       non_vacant_parcels[c("PIN_NUM", "landuse", 
                                            "area",    "geometry")],
                       join = st_is_within_distance, 
                       dist = 1000, 
                       suffix = c("", "_org")
                       ) %>%
               st_drop_geometry() %>%
               write_rds(out_path)

exp_lu_join <- 
  exp_lu_join %>%
    group_by(PIN_NUM, landuse) %>%
    summarise(landuse_sqft = sum(area_org)) %>%
    group_by(PIN_NUM) %>%
    arrange(desc(landuse_sqft)) %>%
    summarise(exp_land_use = first(landuse)) 

vacant_parcels <- inner_join(parcels, exp_lu_join)

# Joining Vacant to Municipalities and Agg --------------------------------
munici_path    <- paste0("./data/Municipal_", month_chr, 
                         "_", year, ".rds")
municipalities <- read_rds(munici_path)

wake_co_path <- paste0("./data/Wake_Zoning_", 
                       month_chr, "_", year, ".shp")
wake_co <- read_sf(wake_co_path)  %>% 
  st_union() %>% 
  st_sf() %>% 
  transmute(ACRES      = NA,
            JURISDICTI = "Wake County",
            PLAN_JURIS = NA,
            CREATED_US = NA,
            CREATED_DA = NA ,
            LAST_EDITE = NA,
            LAST_EDI_1 = NA,
            SHAPE_AREA = NA,
            SHAPE_LEN  = NA)
wake_co$SHAPE_AREA = as.numeric(st_area(wake_co))

Wake_Shapes <- rbind(municipalities, wake_co) %>% 
  mutate(JURISDICTI = if_else(JURISDICTI == "RDU" | JURISDICTI == "RTP",
                              JURISDICTI, 
                              str_to_title(JURISDICTI)))

final_parcels <- st_join(vacant_parcels[c("geometry", "area", "exp_land_use")],
                         municipalities[c("JURISDICTI", "geometry")], 
                         join = st_within,
                         left = TRUE)


# Finding Total Area, Total Vacant Area, and TotalVacant Area Housing ------
Total_Area <- st_drop_geometry(municipalities) %>% 
  rbind(st_drop_geometry(wake_co)) %>% 
  mutate(JURISDICTI = if_else(JURISDICTI == "RDU" | JURISDICTI == "RTP",
                              JURISDICTI, 
                              str_to_title(JURISDICTI))) %>% 
  group_by(JURISDICTI) %>%
  summarise(area = sum(SHAPE_AREA)) 
  
Total_Affordable_Area <- final_parcels %>%
  st_drop_geometry() %>% 
  mutate(JURISDICTI = replace_na(JURISDICTI, "Wake County")) %>%
  filter(exp_land_use == "Residential") %>%
  group_by(JURISDICTI) %>%
  summarise(affordable_area = sum(area)) %>%
  mutate(JURISDICTI = if_else(JURISDICTI == "RDU" | JURISDICTI == "RTP",
                              JURISDICTI, 
                              str_to_title(JURISDICTI))) 

Total_Vacant_Area <- final_parcels %>% 
  st_drop_geometry() %>% 
  mutate(JURISDICTI = replace_na(JURISDICTI, "Wake County")) %>%
  mutate(JURISDICTI = if_else(JURISDICTI == "RDU" | JURISDICTI == "RTP",
                              JURISDICTI, 
                              str_to_title(JURISDICTI))) %>%  
  group_by(JURISDICTI) %>%
  summarise(vacant_area = sum(area)) 

out_path <- paste0("./data/Affordable_Area_by_Town_",
                   year, "_", month,".csv")
Area_Variables <- left_join(Total_Area, Total_Vacant_Area) %>% 
  left_join(Total_Affordable_Area) %>% 
  mutate(JURISDICTI = replace_na(JURISDICTI, "Wake County"),
         JURISDICTI = if_else(JURISDICTI == "RDU" | JURISDICTI == "RTP",
                              JURISDICTI, 
                              str_to_title(JURISDICTI)),
         Tot_Proportion = (affordable_area / area) * 100,
         Vac_Proportion = (affordable_area / vacant_area)* 100) %>%
  write_csv(out_path)

out_path <- paste0("./data/map_data_",
                   year, "_", month,".rds")
map_data <- left_join(Wake_Shapes, Area_Variables) %>% 
  write_rds(out_path)
  

 
                         
