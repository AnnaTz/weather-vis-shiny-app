
shinyUI(

    fluidPage(

        # html styling -----------------------------------------------------------------------------

        tags$style(
            HTML("
            body{background: url('./bg.jpg') no-repeat center center fixed; background-size: cover;}
            .sep {width: 20px; height: 1px; float: left;}
            ")
        ),


        # title ------------------------------------------------------------------------------------

        br(),

        h4(
            "Meteorological Data across the UK",
            align = 'center',
            style = 'color:white; font-size: 25px; font-weight: bold;'
        ),

        br(),


        # inputs and variable plot -----------------------------------------------------------------

        fluidRow(

            column(4,
                   wellPanel(
                       selectizeInput(
                           "stations",
                           "Select Weather Stations:",
                           choices = sites_info$site_name,
                           multiple = TRUE,
                           selected = c("Heathrow", "Dyce"),
                           options = list(placeholder = 'select at most 5', maxItems = 5)
                       ),
                       radioButtons(
                           "variable",
                           "Select Weather Variable:",
                           choices = stringVar,
                           selected = c("Air Temperature" = "air_temperature")
                       ),
                       selectInput(
                           "aggregation",
                           "Select Data Aggregation:",
                           choices = c("Raw hourly data", "Daily averages",
                                       "Daily maxima", "Daily minima", "Monthly averages")
                       ),
                       selectInput(
                           "time_axis",
                           "Select Time Axis:",
                           choices = c("Calendar time", "Day in the week",
                                       "Hour in the week", "Hour in the day"),
                           selected = c("Hour in the day")
                       ),
                       dateRangeInput(
                           "date_range",
                           "Date range:",
                           start = "2022-10-28",
                           end = "2022-11-22",
                           min = "2022-01-01",
                           max = "2022-11-30",
                           format = "dd/mm/yy"
                       )
                   )),

            column(8,
                   wellPanel(
                       plotlyOutput("plot", height = 442)
                   )
            )
        ),


        # hutton table -----------------------------------------------------------------------------

        fluidRow(
            column(12,
                   wellPanel(
                       p(
                           "Hutton Criteria",
                           align = 'center',
                           style = 'color:black; font-size: 17px'
                       ),
                       dataTableOutput("hutton"),
                   )
            )
        ),


        # map and summary --------------------------------------------------------------------------

        fluidRow(
            column(5,
                   wellPanel(
                       tags$style(type = "text/css", "#map {height: 553px !important;}"),
                       leafletOutput("map")
                   )
            ),
            column(7,
                   wellPanel(
                       p(
                           "Daily Mean Summary - last week",
                           align = 'center',
                           style = 'color:black; font-size: 17px'
                       ),
                       dataTableOutput("table"),
                       tags$div(
                           downloadBttn(
                               outputId = "save1",
                               size = "sm",
                               label = "Download Table",
                               style = "gradient",
                               color = "default",
                               icon = shiny::icon("file-csv")
                            ),
                            align = 'center'
                       )
                   )
            )
        ),


        # report save button -----------------------------------------------------------------------

        fluidRow(
            column(12,
                   downloadBttn(
                       outputId = "save2",
                       size = "sm",
                       label = "Download Report",
                       style = "gradient",
                       color = "default",
                       icon = shiny::icon("file-word")
                   ),
                   align = 'center'
            )
        ),

        br()

    )
)
