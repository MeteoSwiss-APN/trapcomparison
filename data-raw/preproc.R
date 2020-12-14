library(tidyverse)
library(here)
library(lubridate)
library(stringi)
library(conflicted)

conflict_prefer("select", "dplyr")

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
    col_types = cols("T", "d"),
    na = "nan"
  ) %>%
    setNames(c("datetime", "conc")) %>%
    mutate(trap = .x %>%
      stri_extract_last_regex("/[:alnum:]*") %>%
      str_replace("/", ""))) %>%
    bind_rows()) %>%
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
  select(datetime, conc, trap)

pollen <- append(pollen_raw, list(sixhourly = sixhourly))
