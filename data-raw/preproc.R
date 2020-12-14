library(tidyverse)
library(here)
library(lubridate)
library(stringi)
library(conflicted)

conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

path_data <- paste0(here::here(), "/data-raw/")
aggregation <- c("daily", "hourly")
files_data <- map(
  aggregation,
  ~ list.files(paste0(path_data, .x), full.names = TRUE)
) %>%
  setNames(aggregation)

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
    mutate(trap = .x %>%
      stri_extract_last_regex("/[:alnum:]*") %>%
      str_replace("/", ""),
      date = date(datetime),
      hour = hour(datetime))) %>%
    bind_rows() %>%
    select(datetime, date, hour, conc, trap)) %>%
  setNames(aggregation)

sixhourly <- pollen_raw$hourly %>%
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
  select(datetime, date, hour, conc, trap)

pollen <- append(pollen_raw, list(sixhourly = sixhourly)) %>%
  map(~ .x %>%
    filter(between(
      datetime,
      as_datetime("2019-04-19 00:00:00"),
      as_datetime("2019-05-31 23:00:00")),
      !(date %in% c(
        date("2019-05-13"),
        date("2019-05-14"),
        date("2019-05-15"),
        date("2019-05-16"),
        date("2019-05-26"),
        date("2019-05-27")
      ))
    ))

usethis::use_data(pollen, overwrite = TRUE)