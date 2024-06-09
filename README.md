
This project was developed for the 'R Programming' course, part of the MSc in Data Analytics at the University of Glasgow in 2022. It involves the development of a Shiny application designed to visualize and summarize meteorological data collected from 20 weather stations across the United Kingdom, spanning from 1st January 2020 to 30th November 2022. The application will provide insights into weather patterns and offer a diagnostic tool for assessing the risk of potato blight, based on the Hutton Criteria.

## Data Source
The data originates from the Met Office Integrated Data Archive System ([CEDA Catalogue](https://catalogue.ceda.ac.uk/uuid/220a65615218d5c9cc9e4785a3234bd0)). The `Sites.csv` file contains details of each weather station, and individual CSV files (`Site_<Site_ID>.csv`) hold hourly weather measurements including air temperature, wind speed, relative humidity, and visibility.

## Weather Variables
- **Wind Speed:** Average speed in knots.
- **Air Temperature:** Measured in °C, rounded to the nearest 0.1 °C.
- **Relative Humidity (rltv hum):** Percentage (%).
- **Visibility:** Measured in metres.

## Application Features
- **Time Series Plots:** Produce time series plots for selected weather variables from up to five stations, with options for raw hourly data, daily averages, monthly averages, daily maxima, and daily minima.
- **Time Aggregation and X-axis Representation:** Users can choose the aggregation level for plots and how time is represented (calendar time, day/hour within the week, hour in the day).
- **Mapping Weather Stations:** Display weather station locations on a map of the United Kingdom.
- **Daily Mean Summary Table:** Provide a summary table for the last seven days of available data, with the option for users to download this table as a CSV file.
- **Hutton Criteria Reporting:** Offer a diagnostic tool for potato blight risk, reporting the Hutton Criteria on a monthly basis.

## Installation and Setup
1. **Download Data:** Ensure all CSV files from Moodle are downloaded and stored in a designated folder within the project directory.
2. **Install Required Packages:** The app relies on several R packages including `shiny`, `ggplot2`, `maps`, `ggmaps`, and `rmarkdown`. Install these packages using R commands like `install.packages("shiny")`.
3. **Launch App:** Run the app by executing the script within the RStudio environment or another R interface.

## Usage Instructions
- **Select Weather Variables and Stations:** Through the app's UI, choose the weather variables and stations you wish to analyse.
- **Choose Data Aggregation and Time Representation:** Specify your preferences for data aggregation and how time should be displayed in plots.
- **Interact with the Map:** The map view allows you to visually identify the location of selected weather stations.
- **Download Data and Reports:** Users can download the daily mean summary table as a CSV file and export plots and tables as a Word document via rmarkdown.

## ShinyApp.io Access
The app is hosted on ShinyApp.io for easy access. Visit [weather-vis-shiny-app](https://annatz.shinyapps.io/stats5078_project_-_anna_tzatzopoulou/) to explore the application.
