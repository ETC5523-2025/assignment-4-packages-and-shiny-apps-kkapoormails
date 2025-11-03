# CovidRiskExplorer

**CovidRiskExplorer** is an R package built for the Monash University unit  
**ETC5523 – Communicating with Data**.

It provides an interactive dashboard and reproducible workflow for exploring **modelled quarantine breach risk in Australia** during the **Delta variant period (2020–2021)**.

---

### What it does

The package helps communicate **when and where quarantine systems were most vulnerable** to leakage into the community.  
It includes:
- A cleaned dataset `covid_breach_data` from *Lydeamore et al. (2023, Science Advances)*  
- A helper function `get_covid_data()`  
- An interactive dashboard launched by `run_app()`  
- A vignette explaining the data, methods, and interpretation

---

### Installation and use

# Install and load
```
```{r}

# install.packages("remotes")
remotes::install_github("etc5523-2025/assignment-4-packages-and-shiny-apps-kkapoormails")
library(CovidRiskExplorer)
run_app()
```

# Access the data
```
```{r}
head(get_covid_data())
```

# Launch the dashboard
```
```{r}
run_app()
```

## Data Source   
Lydeamore et al. (2023).
“Delta and quarantine risk: transmission-blocking and coverage thresholds.”
Science Advances, 9(3): abm3624.
Data provided via Monash ETC5523 teaching materials.


## Interpretation Example  

During the Delta period, states such as NSW and Victoria show clear spikes in quarantine breach risk — particularly around mid-2021 — aligning with real-world outbreaks and quarantine system pressure.
By contrast, Queensland and Western Australia remained relatively stable, suggesting stronger containment or lower exposure at the time.



## License 

MIT + file LICENSE
Author: Kunal Kapoor

## Website Link 
https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-kkapoormails/
