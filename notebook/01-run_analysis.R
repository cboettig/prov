
library(tidyverse)
library(fable)

rw_forecast <- function(df){
  ## read data, format as time-series for each siteID
  ## drops last 90 days (to enable scoring) & use explicit NAs
  ts <- df %>% 
    tsibble::as_tsibble(index=time, key=siteID) %>% 
    dplyr::filter(time < max(time) - 90) %>% 
    tsibble::fill_gaps()

  ## compute model, generate forecast with fable
  ts %>%
    fabletools::model(null = fable::RW(abundance)) %>%
    fabletools::forecast(h = "90 days") %>% 
    dplyr::mutate(sd = sqrt(distributional::variance(abundance))) %>% 
    tibble::as_tibble() %>%
    dplyr::select(time, siteID, model = .model, mean = .mean, sd)
}

read_csv("beetles-targets.csv.gz") %>%
  rw_forecast() %>%
  write_csv("beetles-forecast-rw.csv")

