#' Launch the Shiny dashboard
#'
#' This function starts the interactive Shiny app that is bundled
#' with the assignment4shinykkapoor package.
#'
#' The app lets you:
#' \itemize{
#'   \item filter cars by cylinder count and horsepower,
#'   \item see how horsepower relates to fuel efficiency,
#'   \item inspect a sortable table of matching cars,
#'   \item read an English summary of the trade-offs.
#' }
#'
#' The data used in the app is the cleaned \code{cars_data} dataset
#' included in this package.
#'
#' @return This function does not return a value; it launches a Shiny app.
#' @examples
#' \dontrun{
#'   run_app()
#' }
#' @importFrom shiny runApp fluidPage tabsetPanel tabPanel sidebarLayout sidebarPanel mainPanel selectInput sliderInput plotOutput dataTableOutput renderPlot renderTable
#' @importFrom DT datatable
#' @importFrom dplyr filter mutate select
#' @importFrom ggplot2 ggplot aes geom_point labs theme_minimal
#' @importFrom tibble tibble
#' @importFrom bslib bs_theme
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "assignment4shinykkapoor")
  shiny::runApp(app_dir, display.mode = "normal")
}
