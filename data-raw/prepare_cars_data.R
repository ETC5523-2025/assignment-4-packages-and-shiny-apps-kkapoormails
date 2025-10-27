## code to prepare `prepare_cars_data` dataset goes here

usethis::use_data(prepare_cars_data, overwrite = TRUE)
# data-raw/prepare_cars_data.R

library(dplyr)
library(tibble)
library(usethis)

# Start from the built-in mtcars dataset
cars_data <- mtcars |>
  tibble::rownames_to_column("model") %>%
  mutate(
    cyl = factor(cyl),
    gear = factor(gear),
    am = factor(am, levels = c(0, 1), labels = c("Automatic", "Manual")),
    km_per_litre = mpg * 0.425144,
    power_to_weight = hp / wt
  )

# Save it into the package's data/ folder as an .rda for users
usethis::use_data(cars_data, overwrite = TRUE)
