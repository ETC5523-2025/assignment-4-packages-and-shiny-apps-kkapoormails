# Load data from your package
data_for_app <- assignment4shinykkapoor::get_cars_data()

ui <- shiny::fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  shiny::includeCSS("www/style.css"),

  shiny::titlePanel("Car Performance & Fuel Efficiency Explorer"),

  shiny::sidebarLayout(
    shiny::sidebarPanel(
      width = 3,

      shiny::selectInput(
        "cyl_filter",
        "Number of cylinders:",
        choices = c("All", levels(data_for_app$cyl)),
        selected = "All"
      ),

      shiny::sliderInput(
        "hp_range",
        "Horsepower range:",
        min = floor(min(data_for_app$hp)),
        max = ceiling(max(data_for_app$hp)),
        value = c(floor(min(data_for_app$hp)), ceiling(max(data_for_app$hp)))
      ),

      shiny::helpText(
        "Use these filters to limit which cars are shown.",
        "This updates all tabs below.",
        "Cars with more horsepower usually consume more fuel per km."
      ),

      shiny::hr(),

      shiny::helpText(
        "Tip:",
        "Looking for 'best fuel economy for decent power'?",
        "Sort the table by km_per_litre or power_to_weight."
      )
    ),

    shiny::mainPanel(
      width = 9,

      shiny::tabsetPanel(
        shiny::tabPanel(
          "Fuel vs Power",
          shiny::h3("Fuel Efficiency vs Horsepower"),
          shiny::plotOutput("eff_plot"),
          shiny::p(
            "This chart compares horsepower (x-axis) and fuel efficiency (km per litre, y-axis).",
            "Each point is a car. Colour shows transmission type.",
            "Manual cars are often lighter, so for the same horsepower they can sometimes deliver better distance per litre."
          )
        ),

        shiny::tabPanel(
          "Filtered Cars",
          shiny::h3("Data Table"),
          DT::dataTableOutput("cars_table"),
          shiny::p(
            "This is the filtered subset of cars. You can sort any column.",
            "Use this to identify cars that are powerful but still relatively efficient."
          )
        ),

        shiny::tabPanel(
          "Summary",
          shiny::h3("Averages for Your Selection"),
          shiny::verbatimTextOutput("summary_text"),
          shiny::p(
            "This text block gives a quick verbal summary of the trade-offs",
            "you've currently selected. This is directly useful for communicating",
            "your story in plain English — not just dumping numbers."
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # reactive filtered data based on user controls
  filtered_data <- shiny::reactive({
    df <- data_for_app

    if (input$cyl_filter != "All") {
      df <- dplyr::filter(df, cyl == input$cyl_filter)
    }

    df <- dplyr::filter(df,
                        hp >= input$hp_range[1],
                        hp <= input$hp_range[2]
    )

    df
  })

  # main scatterplot: horsepower vs km_per_litre
  output$eff_plot <- shiny::renderPlot({
    df <- filtered_data()
    shiny::req(nrow(df) > 0)

    ggplot2::ggplot(df, ggplot2::aes(x = hp, y = km_per_litre, color = am)) +
      ggplot2::geom_point(size = 3, alpha = 0.8) +
      ggplot2::labs(
        x = "Horsepower",
        y = "Fuel efficiency (km per litre)",
        color = "Transmission"
      ) +
      ggplot2::theme_minimal()
  })

  # interactive table of filtered cars
  output$cars_table <- DT::renderDataTable({
    df <- filtered_data() |>
      dplyr::select(
        model,
        cyl,
        hp,
        wt,
        km_per_litre,
        am,
        gear,
        power_to_weight
      )

    DT::datatable(
      df,
      rownames = FALSE,
      options = list(pageLength = 10)
    )
  })

  # summary text
  output$summary_text <- shiny::renderText({
    df <- filtered_data()
    shiny::req(nrow(df) > 0)

    avg_hp <- round(mean(df$hp), 1)
    avg_kmL <- round(mean(df$km_per_litre), 2)
    avg_weight <- round(mean(df$wt), 2)

    paste0(
      "In your current selection:\n",
      "- Avg horsepower: ", avg_hp, "\n",
      "- Avg fuel efficiency: ", avg_kmL, " km/L\n",
      "- Avg weight: ", avg_weight, " (1000 lbs)\n\n",
      "Interpretation:\n",
      "As horsepower goes up, fuel efficiency usually goes down.\n",
      "But lighter cars and manual transmissions can still deliver",
      " decent km per litre at medium horsepower."
    )
  })
}

shiny::shinyApp(ui, server)
