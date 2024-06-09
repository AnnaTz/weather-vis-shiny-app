
# The dataframes that are needed for each feature of the app are created here by processing
# the given .csv files, and saved as .rds files (R will load .rds data faster than .csv).
# Since the app will run based on pre-defined data (as opposed to live weather data), the
# processing and structuring of that data can be implemented a single time before the start
# of the server. This will save time when running the app.


# libraries and environment ------------------------------------------------------------------------

library(rstudioapi)
library(dplyr)
library(lubridate)
library(stringr)
# requiredPackages = c('rstudioapi', 'dplyr', 'lubridate', 'stringr')
# for (i in requiredPackages) {
#   if (!require(i, character.only = TRUE)) install.packages(i)
# }

currentDir = dirname(getActiveDocumentContext()$path)
currentDir
setwd(currentDir)
dir.create('processed_data')

source("util.R")


# base datasets ------------------------------------------------------------------------------------

# combine weather data of individual sites to one dataset
all_sites = c()
site_file_list = list.files(path = "./data", pattern = "Site_")
for (site_file in site_file_list) {
  all_sites = rbind(
    all_sites,
    read.csv(paste0("./data/", site_file))
  )
}
all_sites = unique(all_sites)
names(all_sites) = tolower(names(all_sites))

# only numerical columns have missing values
sapply(all_sites, anyNA)
# so we can easily impute them by the mean of each column
for (var in names(all_sites)) {
  if (anyNA(all_sites[[var]])) {
    avg = mean(all_sites[[var]], na.rm = TRUE)
    all_sites[is.na(all_sites[[var]]), var] = avg
  }
}

# site-specific info
sites_info = read.csv("./data/Sites.csv")
names(sites_info) = tolower(names(sites_info))

# combine weather data and site info and add required date/time variables
data = merge(
  all_sites,
  sites_info,
  by.x = c("site"), by.y = c("site_id"), all = TRUE
) %>% mutate(time = to_number(ob_time)) %>%
  mutate(ob_time = dmy_hm(ob_time)) %>%
  mutate(date = date(ob_time)) %>%
  mutate(week_day = wday(ob_time, week_start = 1, label = TRUE)) %>%
  mutate(month = format_ISO8601(date, precision = "ym")) %>%
  mutate(week_hour = hour + 24 * (wday(ob_time, week_start = 1) - 1))
names(data) = tolower(names(data))

saveRDS(sites_info, "./processed_data/sites_info.rds")
saveRDS(data, "./processed_data/data.rds")


# datasets for plots -------------------------------------------------------------------------------

# dataset for the monthly averages plot
monthly_avg = data %>%
  group_by(month, site_name) %>%
  summarise_at(c("wind_speed", "air_temperature", "rltv_hum", "visibility"), mean) %>%
  left_join(select(data, c("month", "site_name", "time")), by = c("month", "site_name"))
monthly_avg = monthly_avg[!duplicated(monthly_avg[, c('month', 'site_name')]),]

# datasets for the daily averages, maxima and minima plots
daily_avg = get_daily(data, mean)
daily_min = get_daily(data, min)
daily_max = get_daily(data, max)

saveRDS(monthly_avg, "./processed_data/monthly_avg.rds")
saveRDS(daily_avg, "./processed_data/daily_avg.rds")
saveRDS(daily_min, "./processed_data/daily_min.rds")
saveRDS(daily_max, "./processed_data/daily_max.rds")


# summary dataset ----------------------------------------------------------------------------------

# dataset for the daily mean summary of the last seven days
summary = data %>%
  filter(time >= to_number("24/11/2022 00:00") & time <= to_number("30/11/2022 23:59"))
summary = get_daily(summary, mean) %>% select(-week_day, -time)

saveRDS(summary, "./processed_data/summary.rds")


# hutton dataset -----------------------------------------------------------------------------------

# data for the first hutton criterion
hutton_1 = data %>%
  group_by(date, site_name) %>%
  summarise_at(c("air_temperature"), min)

# data for the second hutton criterion
hutton_2 = data %>%
  mutate(high_hum = rltv_hum >= 90) %>%
  group_by(date, site_name) %>%
  summarise_at(c("high_hum"), sum)

# combining the two criteria
hutton = merge(hutton_1, hutton_2, by = c("site_name", "date")) %>%
  arrange(date) %>%
  group_by(site_name) %>%
  mutate(
    across(c("air_temperature", "high_hum"), ~lag(., n = 1), .names = '{.col}.1bef'),
    across(c("air_temperature", "high_hum"), ~lag(., n = 2), .names = '{.col}.2bef')
  ) %>%
  select(-air_temperature, -high_hum) %>%
  mutate(hutton = air_temperature.1bef >= 10 & air_temperature.2bef >= 10 & high_hum.1bef >= 6 & high_hum.2bef >= 6) %>%
  left_join(select(data, c("date", "site_name", "time")), by = c("date", "site_name")) %>%
  na.omit()
hutton = hutton[!duplicated(hutton[, c('date', 'site_name')]),]

saveRDS(hutton, "./processed_data/hutton.rds")
