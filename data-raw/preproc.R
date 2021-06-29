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
        stri_extract_last_regex("([^/]+_)") %>%
        str_replace("_", ""),
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
  summarise(conc = if_else(sum(is.na(conc)) <= 3,
    mean(conc, na.rm = TRUE),
    NA_real_
  )) %>%
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
  mutate(missing_values = sum(is.na(conc))) %>%
  summarise(conc = if_else(sum(is.na(conc)) <= 12,
    mean(conc, na.rm = TRUE),
    NA_real_
  )) %>%
  ungroup() %>%
  mutate(
    datetime = as_datetime(date),
    hour = 0
  ) %>%
  select(datetime, date, hour, conc, trap) %>%
  bind_rows(pollen_raw[["daily"]])


pollen_full_with_hirst <- list(
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
    arrange(desc(trap), date) %>%
    pivot_wider(names_from = trap, values_from = conc) %>%
    # The standard compare against - mean of 2 Hirst traps
    # Internal evaluation found that on average the sucking rate is higher
    # than described by the manufacturer
    mutate(Hirst1 = Hirst1 / 1.35,
           Hirst2 = Hirst2 / 1.35,
           Hirst = (Hirst1 + Hirst2) / 2) %>%
    pivot_longer("WIBS-NEO":Hirst, names_to = "trap", values_to = "conc") %>%
    arrange(trap))


pollen_full <- map(pollen_full_with_hirst, ~.x %>%
  filter(!trap %in% c("Hirst1", "Hirst2")))

# After peer-review it was suggested to not exclude the full days, 
# but rather calculate the mean concentrations as long as enough values are present.
# For the sixhour averages we at least 3 values must be !na and for the daily averages at least 12 must be !na.
# This threshold of 50% availability of data is somewhat arbitrary, but achieves a good balance between 
# being overly conservative and still having all characteristic 
# peaks in the pollen season available in the data.
pollen <- map(pollen_full, ~.x %>%
  group_by(datetime) %>%
  mutate(set_na = if_else(any(is.na(conc)), TRUE, FALSE)) %>%
  ungroup() %>%
  mutate(conc = if_else(set_na, NA_real_, conc)) %>%
  filter(!is.na(conc)) %>%
  arrange(trap))

# Ordering traps for optimal display in Plots and Tables
traps_names <- pollen$daily$trap %>%
  unique() %>%
  sort()
traps_names <- c(traps_names[traps_names == "Hirst"], traps_names[traps_names != "Hirst"])

traps_names_hirst <- pollen_full_with_hirst$daily %>%
  filter(trap != "Hirst") %>%
  select(trap) %>%
  unique() %>%
  pull() %>%
  sort()
traps_names_hirst <- c(traps_names_hirst[traps_names_hirst %in% c("Hirst1", "Hirst2")], traps_names_hirst[!traps_names_hirst %in% c("Hirst1", "Hirst2")])


pollen <- map(pollen, ~.x %>% 
  select(-set_na) %>%
  mutate(trap = factor(trap, levels = traps_names, ordered = TRUE)))

pollen_full <- map(pollen_full, ~.x %>% 
  mutate(trap = factor(trap, levels = traps_names, ordered = TRUE)))

pollen_full_with_hirst <- map(pollen_full_with_hirst, ~.x %>% 
  filter(trap != "Hirst") %>%
  mutate(trap = factor(trap, levels = traps_names_hirst)))

usethis::use_data(pollen, overwrite = TRUE)
usethis::use_data(pollen_full, overwrite = TRUE)
usethis::use_data(pollen_full_with_hirst, overwrite = TRUE)
