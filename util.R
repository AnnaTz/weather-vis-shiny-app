

# convert date to a numerical variable (posix time)
to_number = function(time_str) {
    as.numeric(as.POSIXct(time_str, format = "%d/%m/%Y  %H:%M"))
}


# filter a dataframe given selected weather stations and date range
filter_by_input = function(data, input) {
    data[data$site_name %in% input$stations &
             data$time >= to_number(input$date_range[1]) &
             data$time <= to_number(input$date_range[2]),]
}


# get daily summary of dataframe given a statistical function
get_daily = function(data, stat_func) {
    daily = data %>%
        group_by(date, site_name) %>%
        summarise_at(c("wind_speed", "air_temperature", "rltv_hum", "visibility"), stat_func) %>%
        left_join(select(data, c("date", "site_name", "week_day", "time")), by = c("date", "site_name"))
    daily = daily[!duplicated(daily[, c('date', 'site_name')]),]
}


# format hutton data to display in table
format_hutton = function(hutton) {
    hutton %>%
        select(-time) %>%
        `colnames<-`(c("site", "date", "minimum temperature one day ago",
                       "high humidity #hours one day ago", "minimum temperature two days ago",
                       "high humidity #hours two days ago", "hutton")) %>%
        select(date, everything())
}


# format summary data to display in table
format_summary = function(summary) {
    summary %>%
        mutate_at(vars(wind_speed, air_temperature, rltv_hum, visibility), list(~round(., 2))) %>%
        `colnames<-`(c("date", "site", "wind speed", "air temperature", "relative humidity", "visibility"))
}


# plot weather data given user's input
# commonly used in the app's server and in the rmarkdown report
plot_selection = function(data, input) {

    if (input$aggregation == "Raw hourly data") {

        plot_object = ggplot(na.omit(filter_by_input(data, input)))

        if (input$time_axis == "Calendar time") {
            plot_object = plot_object +
                geom_line(aes(x = ob_time, y = !!rlang::sym(input$variable), colour = site_name)) +
                xlab("Calendar time")

        } else if (input$time_axis == "Hour in the week") {
            plot_object = plot_object +
                geom_count(aes(x = week_hour, y = !!rlang::sym(input$variable), colour = site_name)) +
                scale_size_area(max_size = 2) +
                xlab("Hour in the week")

        } else if (input$time_axis == "Hour in the day") {
            plot_object = plot_object +
                geom_count(aes(x = hour, y = !!rlang::sym(input$variable), colour = site_name)) +
                scale_size_area(max_size = 2) +
                xlab("Hour in the day")
        }

    } else if (grepl("Daily", input$aggregation)) {

        if (input$aggregation == "Daily averages") {
            plot_object = ggplot(filter_by_input(daily_avg, input))

        } else if (input$aggregation == "Daily maxima") {
            plot_object = ggplot(filter_by_input(daily_max, input))

        } else if (input$aggregation == "Daily minima") {
            plot_object = ggplot(filter_by_input(daily_min, input))
        }

        if (input$time_axis == "Calendar time") {
            plot_object = plot_object +
                geom_line(aes(x = date, y = !!rlang::sym(input$variable), colour = site_name)) +
                xlab("Date")

        } else if (input$time_axis == "Day in the week") {
            plot_object = plot_object +
                geom_count(aes(x = week_day, y = !!rlang::sym(input$variable), colour = site_name)) +
                scale_size_area(max_size = 2) +
                xlab("Day in the week")
        }

    } else if (input$aggregation == "Monthly averages") {

        plot_object = ggplot(filter_by_input(monthly_avg, input))

        if (input$time_axis == "Calendar time") {
            plot_object = plot_object +
                geom_point(aes(x = month, y = !!rlang::sym(input$variable), colour = site_name)) +
                geom_line(aes(x = as.numeric(factor(month)), y = !!rlang::sym(input$variable), colour = site_name)) +
                xlab("Month")
        }

    }

    plot_object +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
        ggtitle(input$aggregation) +
        theme(plot.title = element_text(hjust = 0.5)) +
        ylab(varString[input$variable]) +
        guides(colour = guide_legend(title = "Stations")) +
        paletteer::scale_color_paletteer_d("ggthemes::Tableau_20")

}
