#' Cleaned car performance dataset
#'
#' `cars_data` is a cleaned and enriched version of the classic `mtcars`
#' dataset. It includes model names, factors for engine configuration,
#' and derived performance metrics.
#'
#' @format A data frame with 32 rows and the following columns:
#' \describe{
#'   \item{model}{Car model name}
#'   \item{mpg}{Miles per gallon}
#'   \item{km_per_litre}{Fuel efficiency in km per litre}
#'   \item{cyl}{Number of cylinders}
#'   \item{disp}{Engine displacement (cubic inches)}
#'   \item{hp}{Gross horsepower}
#'   \item{drat}{Rear axle ratio}
#'   \item{wt}{Weight of the car in 1000 lbs}
#'   \item{power_to_weight}{Horsepower divided by weight}
#'   \item{qsec}{1/4 mile time in seconds}
#'   \item{vs}{Engine shape (0 = V-engine, 1 = straight/inline)}
#'   \item{am}{Transmission type ("Automatic" or "Manual")}
#'   \item{gear}{Number of forward gears}
#'   \item{carb}{Number of carburetors}
#' }
#'
#' @details
#' The dataset extends the built-in `mtcars` with:
#' \itemize{
#'   \item `km_per_litre`: fuel efficiency in km/L
#'   \item `power_to_weight`: horsepower divided by weight
#'   \item `am`: transmission relabeled to "Automatic"/"Manual"
#'   \item `model`: car model name as its own column
#' }
#'
#' @source Derived from base R `mtcars` and cleaned in
#' `data-raw/prepare_cars_data.R` as part of ETC5523 Assignment 4.
#'
#' @name cars_data
#' @usage data(cars_data)
NULL


# Let R CMD check know that `cars_data` is a real object provided by the package
utils::globalVariables("cars_data")


#' Access the cleaned car dataset
#'
#' This helper function returns the packaged dataset `cars_data`.
#' It gives users and the Shiny app a stable accessor.
#'
#' @return A data frame containing car specifications and derived variables.
#'
#' @examples
#' head(get_cars_data())
#'
#' @export
get_cars_data <- function() {
  cars_data
}
