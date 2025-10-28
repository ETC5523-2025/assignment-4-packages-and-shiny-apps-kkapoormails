#' Launch the Quarantine Breach Risk Dashboard
#'
#' Starts the interactive Shiny dashboard bundled with the
#' \code{assignment4shinykkapoor} package.
#'
#' The dashboard lets you:
#' \itemize{
#'   \item choose an Australian state / territory (e.g. NSW, VIC, WA, ...),
#'   \item choose a risk type:
#'         \itemize{
#'           \item \code{total}: overall modelled quarantine outbreak risk,
#'           \item \code{breach}: risk attributed specifically to quarantine system failures
#'                 (not always available for every state or every date),
#'         }
#'   \item pick a date range,
#'   \item visualise how daily estimated risk changes over time,
#'   \item view a sortable table of the filtered daily values,
#'   \item read an automatically generated plain-English summary highlighting
#'         when risk was highest.
#' }
#'
#' Data comes from \code{covid_breach_data}, derived from modelling of
#' quarantine breach / outbreak risk during the emergence of Delta
#' (Lydeamore et al., 2023, \emph{Science Advances}), provided in ETC5523.
#'
#' Important limitation: some combinations of state and risk type do not have
#' non-missing values (for example, national "breach" is mostly NA). The app
#' will warn you when there is no usable data for your selection.
#'
#' @return Invisibly launches the Shiny app; no R object is returned.
#'
#' @examples
#' \dontrun{
#'   run_app()
#' }
#'
#' @importFrom shiny runApp
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "assignment4shinykkapoor")
  shiny::runApp(app_dir, display.mode = "normal")
}
