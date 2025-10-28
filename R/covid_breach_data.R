#' COVID-19 Quarantine Breach Risk Dataset
#'
#' Daily modelled quarantine risk metrics for Australian states and territories,
#' derived from the analysis in Lydeamore et al. (Science Advances, 2023).
#'
#' Each row represents one day for one state, with values corresponding
#' to the total quarantine risk or the subset relating to breaches.
#'
#' @format A data frame with four variables:
#' \describe{
#'   \item{report_date}{Date of observation (YYYY-MM-DD).}
#'   \item{state}{Australian state or territory (AUS, NSW, VIC, QLD, etc.).}
#'   \item{metric}{Risk type — either \code{"total"} (overall risk) or
#'     \code{"breach"} (risk related to system breaches).}
#'   \item{value}{Numeric value representing modelled risk.}
#' }
#'
#' @source Lydeamore et al. (2023), *Science Advances*, DOI: 10.1126/sciadv.abm3624
"covid_breach_data"
utils::globalVariables("covid_breach_data")
#' Access the COVID-19 breach dataset
#'
#' This helper function returns the internal dataset \code{covid_breach_data}.
#' It allows the Shiny app and other functions to load the data
#' without manually attaching package internals.
#'
#' @return A tibble with four columns: report_date, state, metric, value.
#' @examples
#' head(get_covid_data())
#' @export
get_covid_data <- function() {
  covid_breach_data
}
