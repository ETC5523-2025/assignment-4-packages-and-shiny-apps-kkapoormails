# inst/app/app.R

library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(bslib)
library(CovidRiskExplorer)

data_for_app <- CovidRiskExplorer::get_covid_data()

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),

  titlePanel("Quarantine Breach Risk Explorer"),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      helpText(
        "This dashboard explores daily modelled quarantine breach risk in Australia ",
        "during the emergence of Delta. Data comes from Lydeamore et al. (2023, ",
        "Science Advances) and was provided in ETC5523."
      ),

      selectInput(
        "state_filter",
        "State / region:",
        choices = sort(unique(data_for_app$state)),
        selected = "NSW"
      ),

      selectInput(
        "metric_filter",
        "Risk type:",
        choices = sort(unique(data_for_app$metric)),
        selected = "total"
      ),

      dateRangeInput(
        "date_range",
        "Date range:",
        start = min(data_for_app$report_date),
        end   = max(data_for_app$report_date),
        min   = min(data_for_app$report_date),
        max   = max(data_for_app$report_date)
      ),

      hr(),
helpText(
        strong("How to read this:"),
        tags$ul(
          tags$li("Higher values = higher estimated outbreak or breach risk."),
          tags$li('"total" = overall quarantine risk for that state on that day.'),
          tags$li('"breach" = risk specifically linked to quarantine system failures.'),
          tags$li("Not every state/day has a reliable 'breach' estimate. If a combination has no usable values, the app will fall back to 'total' only.")
        )
      )
    ),

    mainPanel(
      width = 9,

      tabsetPanel(

        tabPanel(
          "Risk Over Time",
          h3("Daily risk trend"),
          plotOutput("risk_plot"),
          uiOutput("no_data_msg"),
          p(
            "This line shows how estimated risk changed over time for the selected state.",
            "Spikes indicate periods where the system was under more pressure and more vulnerable ",
            "to quarantine leakage into the community."
          )
        ),

        tabPanel(
          "Data Table",
          h3("Filtered daily values"),
          DTOutput("risk_table"),
          p(
            "These are the daily values after applying your filters.",
            "Sort by 'value' to identify the most concerning days."
          )
        ),

        tabPanel(
          "Summary",
          h3("Story for your selection"),
          verbatimTextOutput("summary_text"),
          p(
            "This narrative is meant for non-technical communication.",
            "It highlights when risk spiked, and whether the system looked stable or fragile."
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Dynamically restrict metric choices based on state
  observeEvent(input$state_filter, {
    valid_metrics <- data_for_app |>
      filter(state == input$state_filter) |>
      filter(!is.na(value)) |>
      distinct(metric) |>
      arrange(metric) |>
      pull(metric)

    # update the metric dropdown so we don't allow useless choices (e.g. AUS + breach if NA)
    updateSelectInput(
      session,
      "metric_filter",
      choices = valid_metrics,
      selected = if (input$metric_filter %in% valid_metrics) input$metric_filter else valid_metrics[1]
    )
  }, ignoreInit = FALSE)

  # Filter data reactively based on current inputs
  filtered_data <- reactive({
    data_for_app |>
      filter(
        state == input$state_filter,
        metric == input$metric_filter,
        report_date >= input$date_range[1],
        report_date <= input$date_range[2]
      )
  })

  # Helper: does user have any non-missing data?
  filtered_non_missing <- reactive({
    filtered_data() |>
      filter(!is.na(value))
  })

  # Risk trend plot
  output$risk_plot <- renderPlot({
    df <- filtered_non_missing()
    req(nrow(df) > 0)

    ggplot(df, aes(x = report_date, y = value)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2, alpha = 0.8) +
      labs(
        x = "Date",
        y = "Risk level (modelled)",
        title = paste(
          input$state_filter,
          "-", input$metric_filter,
          "risk over time"
        )
      ) +
      theme_minimal(base_size = 13)
  })

  # Message under the plot if there's no actual data to show
  output$no_data_msg <- renderUI({
    if (nrow(filtered_non_missing()) == 0) {
      div(
        style = "color:#a00; font-weight:500; margin-top:0.5rem;",
        "No non-missing data available for this combination of state, risk type, and dates."
      )
    } else {
      NULL
    }
  })

  # Data table
  output$risk_table <- renderDT({
    df <- filtered_data() |>
      arrange(desc(report_date))

    datatable(
      df,
      rownames = FALSE,
      options = list(pageLength = 10)
    )
  })

  # Narrative summary
  output$summary_text <- renderText({
    df_all <- filtered_data()
    df_clean <- filtered_non_missing()

    if (nrow(df_all) == 0) {
      return("No records in this date range.")
    }

    # average on non-missing values
    avg_val <- if (nrow(df_clean) > 0) round(mean(df_clean$value), 2) else NA

    if (nrow(df_clean) > 0) {
      peak_row <- df_clean |>
        slice_max(order_by = value, n = 1)
      peak_msg <- paste0(
        "The highest recorded value was ",
        round(peak_row$value, 2),
        " on ",
        format(peak_row$report_date, "%Y-%m-%d"),
        "."
      )
    } else {
      peak_msg <- "All values in this selection are missing, so no peak can be identified."
    }

    paste0(
      "You are looking at ", input$state_filter,
      ", focusing on '", input$metric_filter, "' risk.\n\n",
      "Date range: ",
      format(input$date_range[1], "%Y-%m-%d"),
      " to ",
      format(input$date_range[2], "%Y-%m-%d"),
      ".\n",

      if (!is.na(avg_val)) {
        paste0("- The average estimated risk was ", avg_val, ".\n")
      } else {
        "- The average estimated risk cannot be computed (all values are missing).\n"
      },

      "- ", peak_msg, "\n\n",
      "Interpretation:\n",
      "Higher spikes indicate days where quarantine systems were more stressed ",
      "or more likely to leak infection into the community. Consistently low values ",
      "suggest periods of strong control."
    )
  })
}

shinyApp(ui, server)
