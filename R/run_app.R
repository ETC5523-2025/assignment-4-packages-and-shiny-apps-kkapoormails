#' Launch the Quarantine Breach Risk Dashboard
#'
#' This function starts the interactive Shiny app bundled with the
#' \code{CovidRiskExplorer} package.
#'
#' The dashboard allows you to:
#' \itemize{
#'   \item select an Australian state/territory,
#'   \item choose a risk type (overall quarantine risk vs breach-related risk),
#'   \item choose a date range,
#'   \item view how daily estimated risk changes over time,
#'   \item inspect a table of daily values,
#'   \item read an automatically generated plain-English summary that explains when risk was highest.
#' }
#'
#' The data used in the app is \code{covid_breach_data}, which is derived
#' from modelling of quarantine outbreak/breach risk during the Delta period
#' (Lydeamore et al., 2023, Science Advances) and provided in ETC5523.
#'
#' @return This function does not return a value; it launches the Shiny app.
#'
#' @examples
#' \dontrun{
#'   run_app()
#' }
#'
#' @importFrom shiny runApp
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "CovidRiskExplorer")
  shiny::runApp(app_dir, display.mode = "normal")
}
