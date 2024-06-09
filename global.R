
# libraries ----------------------------------------------------------------------------------------

library(shiny)
library(ggplot2)
library(markdown)
library(rstudioapi)
library(leaflet)
library(shinyFiles)
library(shinyWidgets)
library(dplyr)
library(lubridate)
library(DT)
library(plotly)
library(scales)
# requiredPackages = c('shiny', 'ggplot2', 'markdown', 'rstudioapi', 'leaflet', 'shinyFiles',
#                      'shinyWidgets', 'dplyr', 'lubridate', 'DT', 'plotly', 'scales')
# for (i in requiredPackages) {
#     if (!require(i, character.only = TRUE)) install.packages(i)
# }


# dictionaries -------------------------------------------------------------------------------------

stringVar = c("Wind Speed" = "wind_speed",
              "Air Temperature" = "air_temperature",
              "Relative Humidity" = "rltv_hum",
              "Visibility" = "visibility")

varString = c("wind_speed" = "Wind Speed (knots)",
              "air_temperature" = "Air Temperature (°C)",
              "rltv_hum" = "Relative Humidity (%)",
              "visibility" = "Visibility (metres)")


# datasets -----------------------------------------------------------------------------------------

sites_info = readRDS("./processed_data/sites_info.rds")
data = readRDS("./processed_data/data.rds")

monthly_avg = readRDS("./processed_data/monthly_avg.rds")
daily_avg = readRDS("./processed_data/daily_avg.rds")
daily_min = readRDS("./processed_data/daily_min.rds")
daily_max = readRDS("./processed_data/daily_max.rds")

summary = readRDS("./processed_data/summary.rds")

hutton = readRDS("./processed_data/hutton.rds")
