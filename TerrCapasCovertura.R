library(raster)
library(terra)
library(tidyverse)
library(sf)

#unzip("LandCover CHILE 2014.zip")

Puntos_Hull <- read_csv("Coords.csv") %>% 
  mutate(geometry = str_remove_all(str_remove_all(str_remove_all(geometry, "c"), "\\("), "\\)")) 

Puntos_Hull$Lon <-  str_split(Puntos_Hull$geometry, pattern = ",", simplify = T)[,1] %>% as.numeric()
Puntos_Hull$Lat <-  str_split(Puntos_Hull$geometry, pattern = ", ", simplify = T)[,2] %>% as.numeric()

Puntos_Hull <- Puntos_Hull %>% dplyr::select(-geometry) %>% st_as_sf(coords = c(2,3), crs = 4326) %>% 
  st_transform(crs = "+proj=utm +zone=19 +south +datum=WGS84 +units=m +no_defs") %>%
  st_union() %>% 
  st_convex_hull() %>% 
  st_as_sf() %>% 
  st_buffer(5050)


LandCover <- raster("LC_CHILE_2014_b.tif") %>%
  crop(Puntos_Hull) %>% 
  mask(Puntos_Hull)
#LandCover <-  projectRaster(LandCover, crs = "+proj=longlat +datum=WGS84 +no_defs", method = "ngb") 
#beepr::beep(8)

LandCover <- readAll(LandCover)

m <- c(99, 199, 150,
       210, 230, 212,
       240, 260, 251,
       300, 399, 330,
       400, 499, 450,
       500, 599, 530)

m <- matrix(m, ncol = 3, byrow = T)

LandCover <- reclassify(LandCover, m)

saveRDS(LandCover, "LandCoverVRegion_Small.rds")

LandCover <- readRDS("LandCoverVRegion_Small.rds")

Codes <- readRDS("Codes.rds") %>% mutate_if(is.factor, as.character) %>% 
  mutate(Primary = ifelse(Primary == "0", "Cuerpos de agua", Primary), Selected = ifelse(Selected == "0", "Oceano", Selected))

Extras <- data.frame(Code = c(910, 1020), Primary = c("Salar", "Hielo"), Selected = c("Salar", "Hielo"), stringsAsFactors = F)

Codes <- bind_rows(Codes, Extras)

rm(Extras)
gc()


Codes$Selected <- make.names(Codes$Selected)

Landuse <- c("Bosque.Nativo", "Cultivos", "Grava","Oceano", "Pastizales", "Matorrales", "Sup.impermeables",  "Suelo.arenoso", "Plantación.de.árboles")

Distancias <- round(seq(from = 30, to = 5000, length.out = 10), -2)
Distancias[1] <- 30

LandCover <- rast(LandCover)

#for(i in 4:length(Distancias)){
for(i in 1:length(Distancias)){
  dir.create("TempTerra")
  terraOptions(tempdir = paste0(getwd(), "/TempTerra"))
  rasterOptions(tmpdir = paste0(getwd(), "/TempRaster"))
  print(paste("Starting distance", Distancias[i], "of", length(Distancias), Sys.time()))
  Props <- list()
  for(j in 1:length(Landuse)){
    message(paste("Starting landuse", Landuse[j], j, "of", length(Landuse), Sys.time()))
    TempCode <- dplyr::filter(Codes, Selected == Landuse[j])  %>% pull(Code)
    pclass <- function(x, y=c(TempCode)) {
      return( length(which(x %in% y)) / length(x) )
    }
    f <- terra::focalMat(LandCover, Distancias[i], "circle") 
    f[f > 0] <- 1
    Props[[j]] <- raster::focal(raster::raster(LandCover), w=f, pclass)
  }
  Props <- Props %>% purrr::reduce(stack)
  Props <- Props %>% raster::mask(Puntos_Hull)
  names(Props) <- Landuse %>% janitor::make_clean_names()
  Props <- round(rast(Props)*100)
  terra::writeRaster(Props, paste0("Proportions_", Distancias[i],".tif"), overwrite=TRUE)
  unlink(paste0(getwd(), "/TempTerra"), recursive = T, force = T)
  unlink(paste0(getwd(), "/TempRaster"), recursive = T, force = T)
}
