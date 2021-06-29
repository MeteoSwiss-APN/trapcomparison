#' Measurements of the various pollen monitors
#'
#' A list of three data sets containing pollen measurements.
#' The list elements represent one dataframe each, containing
#' daily, sixhour and hourly pollen concentrations.
#' This data set does NOT contain missing values
#'
#' @format A list of three data frames with 280 (daily), 1072 (sixhour)
#' and 5502 (hourly) rows and 5 variables:
#' \describe{
#'   \item{datetime}{the date and time, in UTC}
#'   \item{date}{the date, in UTC}
#'   \item{hour}{the hour, in UTC}
#'   \item{trap}{the pollen monitor, name of the trap}
#'   \item{conc}{the measured pollen concentration, in [m^(-3)]}
#' }
"pollen"

#' Measurements of the various pollen monitors
#'
#' A list of three data sets containing pollen measurements.
#' The list elements represent one dataframe each, containing
#' daily, sixhour and hourly pollen concentrations.
#' This data set contains missing values, depicted as NA
#'
#' @format A list of three data frames with 344 (daily), 1376 (sixhour)
#' and 7224 (hourly) rows and 5 variables:
#' \describe{
#'   \item{datetime}{the date and time, in UTC}
#'   \item{date}{the date, in UTC}
#'   \item{hour}{the hour, in UTC}
#'   \item{trap}{the pollen monitor, name of the trap}
#'   \item{conc}{the measured pollen concentration, in [m^(-3)]}
#' }
"pollen_full"

#' Measurements of the various pollen monitors
#'
#' A list of three data sets containing pollen measurements.
#' The list elements represent one dataframe each, containing
#' daily, sixhour and hourly pollen concentrations.
#' This data set contains missing values, depicted as NA
#' This dataset is identical to pollen_full,
#' except for the fact that it contains both Hirst traps separately.
#'
#' @format A list of three data frames with 344 (daily), 1376 (sixhour)
#' and 7224 (hourly) rows and 5 variables:
#' \describe{
#'   \item{datetime}{the date and time, in UTC}
#'   \item{date}{the date, in UTC}
#'   \item{hour}{the hour, in UTC}
#'   \item{trap}{the pollen monitor, name of the trap}
#'   \item{conc}{the measured pollen concentration, in [m^(-3)]}
#' }
"pollen_full_with_hirst"

