# inst/app/app.R

library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(bslib)
library(lubridate)
library(CovidRiskExplorer)

# Data
data_for_app <- CovidRiskExplorer::get_covid_data()

# Theme
app_theme <- bs_theme(
  version = 5,
  base_font    = font_google("Inter"),
  heading_font = font_google("Inter"),
  primary = "#4C6EF5",
  success = "#1E7A46",
  warning = "#F4A259",
  bg = "#F8FAFC", fg = "#0F172A",
  "card-bg"  = "#FFFFFF", "input-bg" = "#FFFFFF", "navbar-bg" = "#FFFFFF"
)

ui <- page_sidebar(
  title    = "Quarantine Breach Risk Explorer",
  theme    = app_theme,
  fillable = TRUE,

  # --- global CSS ---
  tags$style(HTML("
    .card-body { overflow: visible !important; }
    pre, .shiny-text-output { white-space: pre-wrap; overflow: visible !important; }
    .kpi-row {
      display: flex; justify-content: center; align-items: stretch; gap: 2em; margin: .5rem 0 1.25rem 0;
      flex-wrap: nowrap;
    }
    .kpi-card {
      min-height: 130px; max-width: 360px; width: 100%;
      display: flex; flex-direction: column; justify-content: center; align-items: center;
      border-radius: 16px; border: none;
      box-shadow: 0 2px 8px rgba(0,0,0,.06);
      padding: 15px 18px 12px 18px;
      background: #FFF;
    }
    .kpi-title { font-weight: 600; font-size: 1.1rem; color: #0F172A; margin-bottom: 4px; text-align: center; }
    .kpi-num   { font-size: 1.85rem; font-weight: 700; color: #0F172A; text-align: center; line-height: 1.2; }
    .kpi-bg-avg  { background: #E9EDFC; }
    .kpi-bg-peak { background: #FEF3E2; }
    .kpi-bg-n    { background: #E9F7EF; }
    .card { margin-bottom: 2rem; }

    /* widen the date range inputs a bit */
    .date-range-input input { width: 125px !important; }
  ")),

  # --- replace default sidebar arrow with a hamburger icon ---
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const btn = document.querySelector('.bslib-page-sidebar-toggle');
      if (btn) {
        btn.innerHTML = '&#9776;';        // ☰
        btn.style.fontSize = '20px';
        btn.title = 'Toggle sidebar';
      }
    });
  ")),

  # --- sidebar controls ---
  sidebar = sidebar(
    radioButtons(
      "chart_style", "Chart style:",
      choices = c("Line" = "line", "Compare (weekly bars)" = "compare_bars")
    ),
    selectInput("state_filter", "State / region:",
                choices = sort(unique(data_for_app$state)), selected = "NSW"),
    selectInput("metric_filter", "Risk type:",
                choices = sort(unique(data_for_app$metric)), selected = "total"),
    div(class = "date-range-input",
        dateRangeInput(
          "date_range", "Date range:",
          start = min(data_for_app$report_date),
          end   = max(data_for_app$report_date),
          min   = min(data_for_app$report_date),
          max   = max(data_for_app$report_date)
        )
    ),
    div(class = "mt-3",
        downloadButton("download_csv", "Download filtered CSV", class = "btn-primary"))
  ),

  # KPI tiles (visible on all tabs)
  div(class = "kpi-row",
      div(class = "kpi-card kpi-bg-avg",
          div(class = "kpi-title", "Average Risk"),
          div(class = "kpi-num", textOutput("kpi_avg", inline = TRUE))
      ),
      div(class = "kpi-card kpi-bg-peak",
          div(class = "kpi-title", "Peak Risk"),
          div(class = "kpi-num", textOutput("kpi_peak", inline = TRUE))
      ),
      div(class = "kpi-card kpi-bg-n",
          div(class = "kpi-title", "Data Points"),
          div(class = "kpi-num", textOutput("kpi_n", inline = TRUE))
      )
  ),

  # ---- MAIN NAV TABS ----
  navs_tab_card(
    nav_panel(
      "Plots",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Risk Over Time (Interactive)"),
          plotlyOutput("risk_plotly", height = "430px")
        ),
        card(
          card_header("Narrative Summary"),
          div(
            style = "white-space: normal; padding: 1rem;",
            verbatimTextOutput("summary_text")
          )
        )
      )
    ),
    nav_panel(
      "Data table",
      card(
        card_header("Filtered Daily Values"),
        DTOutput("risk_table")
      )
    ),
    nav_panel(
      "Guide & Notes",
      card(
        card_header("Guide: Controls & Interpretation"),
        layout_columns(
          col_widths = c(6,6),
          div(
            tags$h4("What the controls mean", class = "mt-0"),
            tags$ul(
              tags$li(tags$b("State / region:"), " Choose an Australian state/territory or AUS."),
              tags$li(tags$b("Risk type:"), " ", tags$code("total"), " = overall quarantine-related risk; ",
                      tags$code("breach"), " = risk attributed to quarantine failures."),
              tags$li(tags$b("Date range:"), " Focus on a window of interest."),
              tags$li(tags$b("Chart style:"), " ",
                      tags$b("Line:"), " daily values; ",
                      tags$b("Compare:"), " weekly bars for ", tags$code("total"), " vs ", tags$code("breach"), ".")
            )
          ),
          div(
            tags$h4("How to read the outputs", class = "mt-0"),
            tags$ul(
              tags$li(tags$b("KPIs:"), " average risk, peak value/date, and number of valid data points."),
              tags$li(tags$b("Plot:"), " spikes = higher leakage likelihood; flat/low = stronger control."),
              tags$li(tags$b("Table:"), " sortable/filterable daily values."),
              tags$li(tags$b("Summary:"), " plain-English narrative of your selection.")
            ),
            div(class="text-muted small mt-2",
                "Data: Lydeamore et al. (2023), Science Advances 9(3): abm3624; provided via Monash ETC5523.")
          )
        )
      ),
      div(class = "mt-4 text-muted small",
          tags$hr(),
          tags$b("Data Source: "),
          "Lydeamore et al. (2023), Science Advances 9(3): abm3624. ",
          "Provided via Monash ETC5523 teaching materials.")
    )
  )
)

server <- function(input, output, session) {

  # Keep metric choices valid for selected state
  observeEvent(input$state_filter, {
    valid_metrics <- data_for_app |>
      filter(state == input$state_filter, !is.na(value)) |>
      distinct(metric) |>
      arrange(metric) |>
      pull(metric)

    updateSelectInput(
      session, "metric_filter",
      choices  = valid_metrics,
      selected = if (input$metric_filter %in% valid_metrics) input$metric_filter else valid_metrics[1]
    )
  }, ignoreInit = FALSE)

  # Reactives
  filtered_data <- reactive({
    data_for_app |>
      filter(
        state == input$state_filter,
        metric == input$metric_filter,
        report_date >= input$date_range[1],
        report_date <= input$date_range[2]
      )
  })

  filtered_non_missing <- reactive({
    filtered_data() |> filter(!is.na(value))
  })

  # KPIs
  output$kpi_avg  <- renderText({ df <- filtered_non_missing(); if (!nrow(df)) "—" else round(mean(df$value), 2) })
  output$kpi_peak <- renderText({ df <- filtered_non_missing(); if (!nrow(df)) "—" else round(max(df$value), 2) })
  output$kpi_n    <- renderText({ df <- filtered_non_missing(); if (!nrow(df)) "0" else format(nrow(df), big.mark = ",") })

  # Plot
  output$risk_plotly <- renderPlotly({
    style <- input$chart_style
    state <- input$state_filter

    df_all <- filtered_data()
    df     <- filtered_non_missing()
    req(nrow(df_all) > 0)

    if (style == "compare_bars") {
      df_cmp <- data_for_app |>
        filter(
          state == state,
          report_date >= input$date_range[1],
          report_date <= input$date_range[2],
          metric %in% c("total", "breach")
        ) |>
        mutate(week = floor_date(report_date, "week")) |>
        group_by(metric, week) |>
        summarise(value = mean(value, na.rm = TRUE), .groups = "drop") |>
        filter(is.finite(value))

      validate(need(nrow(df_cmp) > 0, "No data available to compare for this selection."))

      p <- ggplot(df_cmp, aes(week, value, fill = metric)) +
        geom_col(position = position_dodge(width = 6), width = 6) +
        scale_fill_manual(values = c(total = "#4C6EF5", breach = "#1E7A46")) +
        labs(x = "Week", y = "Avg risk (weekly mean)", title = paste(state, "- weekly comparison: total vs breach")) +
        theme_minimal(base_size = 14) +
        theme(legend.position = "top")

    } else {
      validate(need(nrow(df) > 0, "No non-missing data for this selection."))
      p <- ggplot(df, aes(report_date, value)) +
        geom_line(linewidth = 1.3, color = "#4C6EF5") +
        labs(x = "Date", y = "Risk level (modelled)", title = paste(state, "-", input$metric_filter, "risk over time")) +
        theme_minimal(base_size = 14)
    }

    ggplotly(p, dynamicTicks = TRUE) |>
      layout(hovermode = "x unified", margin = list(l = 60, r = 40, t = 70, b = 60))
  })

  # Table
  output$risk_table <- renderDT({
    filtered_data() |>
      arrange(desc(report_date)) |>
      datatable(rownames = FALSE, options = list(pageLength = 25))
  })

  # Narrative summary
  output$summary_text <- renderText({
    df_all <- filtered_data()
    df     <- filtered_non_missing()
    if (!nrow(df_all)) return("No records in this date range.")
    avg_val <- if (nrow(df)) round(mean(df$value), 2) else NA
    peak_msg <- if (nrow(df)) {
      peak_row <- df |> slice_max(order_by = value, n = 1)
      paste0("Peak = ", round(peak_row$value, 2), " on ", format(peak_row$report_date, "%Y-%m-%d"), ".")
    } else "All values are missing; no peak can be identified."
    paste0(
      "Selection: ", input$state_filter, " / '", input$metric_filter, "'.\n",
      "Date range: ", format(input$date_range[1], "%Y-%m-%d"), " to ", format(input$date_range[2], "%Y-%m-%d"), ".\n",
      if (!is.na(avg_val)) paste0("Average estimated risk = ", avg_val, ".\n") else "Average risk not available.\n",
      peak_msg, "\n\n",
      "Interpretation: spikes suggest higher leakage likelihood; sustained low values suggest stronger control.\n"
    )
  })

  # Download
  output$download_csv <- downloadHandler(
    filename = function() paste0("covid_risk_", input$state_filter, "_", input$metric_filter, ".csv"),
    content  = function(file) write.csv(filtered_data(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
