#-- DETAILS --#
#SLM
#Created: 07022023
#Updated: 07022023

#-- LIBRARIES --#
#library(leaflet) #mapping 
library(rjson) #json wrangling and requests
library(jsonlite) #json wrangling
library(httr) #http request
library(tidyverse) #data wrangling


###---OCCURRENCE DATA ---###
link <- "https://biocache-ws.ala.org.au/ws/occurrences/search?q=taxa%3A%22galahs%22&qualityProfile=ALA&pageSize=20000"

#Get data
response <- GET(link)

#Turn list of lists into simple vectors and obtain content from response into JSON
df <- purrr::flatten(fromJSON(content(response, as = "text")))

#Convert list into a dataframe
df <- as_tibble(df)

###---CLEAN OCCURRENCE DATASET ---###
df_cleaned <- df %>%
    filter(scientificName=='Eolophus roseicapilla',
           basisOfRecord=='HUMAN_OBSERVATION',
            year == 2018) %>%
    select(uuid, scientificName, decimalLatitude, decimalLongitude, year, basisOfRecord, dataProviderName) 


