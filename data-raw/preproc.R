library(tidyverse)
library(here)
library(purrr)
library(lubridate)
library(stringi)
library(conflicted)

conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

# When available import hourly data otherwise sixhour and daily
path_data <- paste0(here::here(), "/data-raw/")
aggregation <- c("daily", "sixhour", "hourly")
files_data <- map(
  aggregation,
  ~ list.files(paste0(path_data, .x), full.names = TRUE)
) %>%
  setNames(aggregation)

# File import
pollen_raw <-
  map(aggregation, ~
  map(files_data[[.x]], ~ read_delim(
    paste0(.x),
    delim = ",",
    col_names = TRUE,
    col_types = cols("T", "n"),
    na = "nan"
  ) %>%
    setNames(c("datetime", "conc")) %>%
    mutate(
      trap = .x %>%
        stri_extract_last_regex("/[:alnum:]*") %>%
        str_replace("/", ""),
      date = date(datetime),
      hour = hour(datetime)
    )) %>%
    bind_rows() %>%
    select(datetime, date, hour, conc, trap)) %>%
  setNames(aggregation)

# Six-Hour aggregation of hourly values
sixhour <- pollen_raw$hourly %>%
  group_by(trap) %>%
  mutate(
    hms = format(datetime, "%H:%M:%S"),
    date = date(datetime),
    hour = case_when(
      hms >= "00:00:00" & hms < "06:00:00" ~ 6,
      hms >= "06:00:00" & hms < "12:00:00" ~ 12,
      hms >= "12:00:00" & hms < "18:00:00" ~ 18,
      hms >= "18:00:00" | hms <= "23:00:00" ~ 0
    )
  ) %>%
  group_by(date, hour, trap) %>%
  summarise(conc = mean(conc)) %>%
  ungroup() %>%
  mutate(datetime = as_datetime(
    paste0(
      as.character(date),
      " ",
      sprintf("%02d", hour),
      ":00:00"
    )
  )) %>%
  select(datetime, date, hour, conc, trap) %>%
  bind_rows(pollen_raw[["sixhour"]])

# Daily aggregation of hourly values
daily <- pollen_raw$hourly %>%
  group_by(trap, date) %>%
  summarise(conc = mean(conc)) %>%
  ungroup() %>%
  mutate(
    datetime = as_datetime(date),
    hour = 0
  ) %>%
  select(datetime, date, hour, conc, trap) %>%
  bind_rows(pollen_raw[["daily"]])


pollen_full <- list(
  daily = daily,
  sixhour = sixhour,
  hourly = pollen_raw[["hourly"]]
) %>%
  map(~ .x %>%
    filter(between(
      datetime,
      # This is the timespan used in the paper
      as_datetime("2019-04-19 00:00:00"),
      as_datetime("2019-05-31 23:00:00")
    )) %>%
    pivot_wider(names_from = trap, values_from = conc) %>%
    # The standard compare against - mean of 2 Hirst traps
    # Internal evaluation found that on average the sucking rate is higher
    # than described by the manufacturer
    mutate(hirst = (hirst1 + hirst2) / 2 / 1.35) %>%
    select(-hirst1, -hirst2) %>%
    pivot_longer(KHA:hirst, names_to = "trap", values_to = "conc"))

# To be very conservative, days with calibration events
# have been excluded for all traps. 2019 was the year of
# initial deployment, hence there are quite a few days to be excluded.
pollen <- pollen_full %>%
  map(~ .x %>%
    filter(
      !(date %in% c(
        # Here Poleno 1  was undergoing calibration
        date("2019-04-20"),
        date("2019-04-21"),
        date("2019-04-22"),
        date("2019-04-25"),
        date("2019-04-29"),
        date("2019-05-09"),
        date("2019-05-10"),
        date("2019-05-14"),
        date("2019-05-15"),
        date("2019-05-27"),
        date("2019-05-31"),
        # Here Poleno 1  was undergoing calibration
        date("2019-05-13"),
        date("2019-05-14"),
        date("2019-05-15"),
        date("2019-05-16"),
        date("2019-05-26"),
        date("2019-05-27"),
        # Here Hirst2 has missing data
        date("2019-04-23"),
        date("2019-05-31"),
        # Here Rapide had a software issue (values provided in chunks)
        date("2019-04-22"),
        date("2019-04-23"),
        date("2019-04-24"),
        date("2019-04-25"),
        date("2019-04-26"),
        date("2019-05-01"),
        date("2019-05-07"),
        date("2019-05-17"),
        date("2019-05-24")
      ))
    ))

usethis::use_data(pollen, overwrite = TRUE)
usethis::use_data(pollen_full, overwrite = TRUE)
