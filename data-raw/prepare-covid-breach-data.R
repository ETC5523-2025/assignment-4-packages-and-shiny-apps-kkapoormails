library(readxl)
library(dplyr)
library(tidyr)
library(janitor)
library(usethis)

# 1. Read the Excel file

raw_data <- readxl::read_excel(
  "data-raw/sciadv.abm3624_table_data.xlsx",
  sheet = "Raw"
)

# 2. Clean column names: REPORT_DATE -> report_date, NSW_BREACH -> nsw_breach, etc.
cleaned <- raw_data |>
  janitor::clean_names()

# 3. Make sure report_date is stored as a Date
cleaned <- cleaned |>
  mutate(report_date = as.Date(report_date))

# 4. Reshape to tidy
#    We go from wide (NSW, NSW_BREACH, VIC, VIC_BREACH...) to long format:
#    report_date | state | metric | value
covid_breach_data <- cleaned |>
  tidyr::pivot_longer(
    cols = -report_date,
    names_to = "state_metric",
    values_to = "value"
  ) |>
  tidyr::separate(
    state_metric,
    into = c("state", "metric"),
    sep = "_",
    fill = "right"
  ) |>
  mutate(
    state = toupper(state),
    metric = ifelse(is.na(metric), "total", metric),
    value  = suppressWarnings(as.numeric(value))
  )

# 5. Save this cleaned dataset into the package data/ folder
usethis::use_data(covid_breach_data, overwrite = TRUE)
