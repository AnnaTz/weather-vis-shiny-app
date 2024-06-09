
source("util.R")


shinyServer(function(input, output, session) {


# update axis selection ----------------------------------------------------------------------------

    Nchoices = reactive({case_when(
        grepl("hourly", input$aggregation) ~c("Hour in the day", "Calendar time", "Hour in the week"),
        grepl("Daily", input$aggregation) ~c("Calendar time", "Day in the week", ""),
        grepl("Monthly", input$aggregation) ~c("Calendar time")
    )})
    observeEvent(input$aggregation,{updateSelectInput(session, "time_axis", choices = Nchoices())})


# variable plot ------------------------------------------------------------------------------------

    output$plot = renderPlotly({
        plot_selection(data, input)
    })


# hutton table -------------------------------------------------------------------------------------

    output$hutton  = renderDataTable(
        filter_by_input(hutton, input) %>%
            format_hutton() %>%
            DT::datatable(
                options = list(
                    dom = 'l<"sep">Bfrtip',
                    initComplete = JS(
                        "function(settings, json) {",
                        "$(this.api().table().header()).css({
                        'background-color': '#3388DD', 'color': 'white'});}"
                    ),
                    columnDefs = list(list(className = 'dt-center', targets = "_all"))
                ),
                rownames = FALSE
            )
    )


# map ----------------------------------------------------------------------------------------------

    output$map = renderLeaflet({
        sites_info %>%
            filter(site_name %in% input$stations) %>%
            leaflet() %>%
            addTiles(urlTemplate = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") %>%
            setView(lng = -4.4, lat = 55.946, zoom = 5) %>%
            addMarkers(lng = ~longitude, lat = ~latitude, label = ~site_name)
    })


# summary table ------------------------------------------------------------------------------------

    output$table  = renderDataTable(
        summary %>%
            filter(site_name %in% input$stations) %>%
            format_summary() %>%
            DT::datatable(
                options = list(
                    dom = 'l<"sep">Bfrtip',
                    initComplete = JS(
                        "function(settings, json) {",
                        "$(this.api().table().header()).css({
                        'background-color': '#3388DD', 'color': 'white'});}"
                    ),
                    columnDefs = list(list(className = 'dt-center', targets = "_all"))
                ),
                rownames = FALSE
            )
    )


# save buttons -------------------------------------------------------------------------------------

    output$save1 = downloadHandler(
        filename = 'summary_table.csv',
        content = function(file) {write.csv(summary, file)}
    )

    output$save2 = downloadHandler(
        filename = "report.docx",
        content = function(file) {
            rmarkdown::render(
                "report.Rmd",
                output_file = file,
                params = list(
                    input = list(
                        aggregation = input$aggregation,
                        variable = input$variable,
                        time_axis = input$time_axis,
                        stations = input$stations,
                        date_range = input$date_range
                    )
                )
            )
        }
    )

})
