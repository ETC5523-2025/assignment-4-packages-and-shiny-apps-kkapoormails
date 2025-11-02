#' Launch the Quarantine Breach Risk Explorer
#'
#' This function starts the interactive Shiny dashboard included with the
#' \pkg{CovidRiskExplorer} package. The dashboard allows users to:
#' \itemize{
#'   \item select an Australian state or territory,
#'   \item choose a risk type (overall quarantine risk vs. breach-related risk),
#'   \item adjust a date range to focus on specific time periods,
#'   \item explore interactive plots of daily modelled risk over time,
#'   \item inspect tabular daily values, and
#'   \item read automatically generated narrative summaries describing
#'         risk peaks and average levels.
#' }
#'
#' The data visualised in the app is sourced from the \code{covid_breach_data}
#' dataset, derived from Lydeamore et al. (2023), *Science Advances 9(3): abm3624*,
#' supplied in the ETC5523 unit at Monash University.
#'
#' @return Invisibly returns the Shiny app object.
#'
#' @examples
#' \dontrun{
#'   run_app()
#' }
#'
#' @import shiny
#' @export
run_app <- function() {
  # Locate the app directory within the installed package
  app_dir <- system.file("app", package = "CovidRiskExplorer")

  # Guard clause — ensure the app directory exists
  if (app_dir == "" || !dir.exists(app_dir)) {
    stop(
      "Could not find the Shiny app directory inside the package.\n",
      "Expected path: inst/app/",
      call. = FALSE
    )
  }

  # Launch the Shiny application
  shiny::shinyAppDir(appDir = app_dir)
}
