# assignment4shinykkapoor

This package was developed for ETC5523 (Communicating with Data).

It provides:
- a cleaned dataset `covid_breach_data`, which summarises estimated daily quarantine outbreak / breach risk for Australian states and territories during the Delta period (Oct 2020 – Jul 2021). This data was supplied in ETC5523 and is based on modelling reported in Lydeamore et al. (2023, *Science Advances*).
- a helper function `get_covid_data()` that returns the data as a tidy tibble: one row per (date × state × metric).
- an interactive Shiny dashboard, launched with `run_app()`, that:
  - lets you select a state/territory (e.g. NSW, VIC, QLD, AUS),
  - choose a risk type (`total` vs `breach`),
  - choose a date range,
  - see how daily estimated risk changes over time,
  - view a filtered table of the values,
  - and read an automatically generated plain-English summary of when risk was highest.

## Why this app exists

The goal is not just plotting numbers. The goal is communication.

- `"total"` represents overall quarantine outbreak / leakage risk for that region on that date.
- `"breach"` focuses on risk attributed specifically to quarantine system failures (leakage).

Spikes in these time series suggest periods when the system was under stress and more likely to leak infection into the community. Long flat low periods suggest control/stability.

Not every region has non-missing `"breach"` values for all dates (for example, `AUS` breach is mostly `NA`).  
The app reacts to this — it only offers you combinations of state + metric that actually have data, and if there’s nothing to plot it tells you that clearly.

This is deliberate: the dashboard is designed to help a non-technical audience understand *when* and *where* the system looked fragile.

## Installing (development version)

```r
# from inside the repo directory
devtools::install(".")
```

