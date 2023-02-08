#-- DETAILS --#
#SLM
#Created: 07022023
#Updated: 09022023

#-- LIBRARIES --#
#library(leaflet) #mapping 
#library(rjson) #json wrangling and requests
#library(jsonlite) #json wrangling
#library(httr) #http request
library(tidyverse) #data wrangling
library(sp) #wrangle spatial data points
library(raster) #rasterise ocurrence data
library(ggthemes) #theme for ggpplots
#library(rnaturalearth) #world map data
#library(rnaturalearthdata)
library(ozmaps)
#library(ggnewscale) #ggplot with 2 fills
#library(ggThemeAssist) #improve layout of ggmap

###---OCCURRENCE DATA ---###
#link <- "https://biocache-ws.ala.org.au/ws/occurrences/search?q=taxa%3A%22galahs%22&qualityProfile=ALA&pageSize=20000"

#Get data
#response <- GET(link)

#Turn list of lists into simple vectors and obtain content from response into JSON
#df <- purrr::flatten(fromJSON(content(response, as = "text")))

#Convert list into a dataframe
#df <- as_tibble(df)

###---CLEAN OCCURRENCE DATASET ---###
#df_cleaned <- df %>%
    #filter(scientificName=='Eolophus roseicapilla',
            #basisOfRecord=='HUMAN_OBSERVATION',
            #year == 2018) %>%
     #dplyr::select(uuid, scientificName, decimalLatitude, decimalLongitude, year, basisOfRecord, dataProviderName) 

#write.csv(df_cleaned,'data/data.csv')

df_cleaned <- read_csv('data/data.csv')

occu <- df_cleaned %>%
        dplyr::select(decimalLatitude, decimalLongitude)

### --- SAMPLING BIAS ---###
coordinates(occu)<- c("decimalLongitude", "decimalLatitude") #obtain coordinates

raster1 <- extent(occu) #define the extent
res1 <- 0.75 #degrees resolution
grid <- raster(raster1, res = res1) #convert data into grid

galah_raster <- rasterize(occu, grid, fun="count") #develop raster

#Convert NAs into 0 to highlight sampling bias
galah_raster[is.na(galah_raster[])] <- 0


#Convert raster into a dataframe for ggpplot
galah_r_df <- as.data.frame(galah_raster, xy=TRUE) %>%
    rename(long = x, lat = y)

#Obtain base map and polygons
oz_states <- ozmaps::ozmap_states

#Plot
ggplot() +
  geom_sf(data = oz_states, fill = "white", color = "black") +
  coord_sf() +
  geom_tile(mapping = aes(long, lat, fill=layer), data=galah_r_df) +
  scale_fill_gradient(low = "#ffffff00", high="red") +
  theme_map() +
  theme(legend.position = "bottom") +
  labs(title = "Galah Occurrence in 2018",
       fill = "Occurrence")

#Save plot
ggsave('assets/samp_bias_2018.png')
