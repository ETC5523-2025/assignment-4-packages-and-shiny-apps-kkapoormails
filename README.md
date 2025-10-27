# assignment4shinykkapoor

## Overview
`assignment4shinykkapoor` is an R package created for ETC5523 (Communicating with Data).
It packages:
- a cleaned car performance dataset (`cars_data`),
- documented helper functions,
- and an interactive Shiny dashboard for exploring fuel efficiency vs power.

The goal is to communicate insights, not just dump numbers:
- Which cars are powerful but still fuel-efficient?
- How does horsepower relate to km per litre?
- Do manual cars behave differently to automatics?

## Data
The dataset `cars_data` is derived from the built-in `mtcars` dataset.
I added:
- `km_per_litre` (fuel efficiency in km/L),
- `power_to_weight` (hp divided by weight),
- readable labels for transmission (Automatic / Manual),
- `model` as an explicit column.

You can load it with:
```r
library(assignment4shinykkapoor)
head(get_cars_data())
