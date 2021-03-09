#' Measurements of the various pollen monitors
#'
#' A list of three data sets containing pollen measurements.
#' The list elements represent one dataframe each, containing
#' daily, sixhour and hourly pollen concentrations.
#' This data set does NOT contain missing values
#'
#' @format A list of three data frames with 176 (daily), 704 (sixhour)
#' and 3168 (hourly) rows and 5 variables:
#' \describe{
#'   \item{datetime}{the date and time, in UTC}
#'   \item{date}{the date, in UTC}
#'   \item{hour}{the hour, in UTC}
#'   \item{trap}{the pollen monitor, name of the trap}
#'   \item{conc}{the measured pollen concentration, in [m^(-3)]}
#' }
"pollen"