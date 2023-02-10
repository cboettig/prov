library(jsonlite)
library(tidyverse)

## Parse the prov data
prov <- jsonlite::read_json("https://data.ecoforecast.org/forecasts/terrestrial/prov.json")
graph <- prov[["@graph"]]
df <- graph %>% toJSON() %>% fromJSON() %>%
  select(id, description, format, title, byteSize, 
         endedAtTime, used,
         type) %>%
  tidyr::unnest(everything())

## Unique code runs
code_runs <- df %>% filter(type == "Activity")
dim(code_runs)[[1]]

## unique files
files <- df %>% filter(type == "Distribution")
dim(files)[[1]]

## Total entries of documents by type:
files %>%   count(description, sort=TRUE)

## Unique documents by type: 
files %>% select(id, description) %>% distinct() %>%  count(description, sort=TRUE)

# all code files:
files %>% filter(description=="R code") %>% pull(id) %>% unique()
