# Trapcomparison

What is really in the air? An evaluation of multiple automatic pollen monitors
Comparison of eight pollen monitors during the 2019 Blooming Season in Payerne CH

# Setup

The project is set up as a minimal R-package to assure maximum reproducibility.
It is using renv dependency management, for more info: https://cran.r-project.org/web/packages/renv/vignettes/renv.html

The analysis was conducted in R-4.0.3.
If running and old R-Version some packages must be installed from CRAN Archive. Here for MeteoSwiss-default R-3.5.2:
  - caTools@1.17.1.1
  - pbkrtest@0.4-7
  - nloptr@1.2.2
  - foreign@0.8-76
  - usethis@1.5.1

The .RProfile is optimized for an interactive session in VSCode. Feel free to uncomment the respective lines if working in VS-Code.

# Data

The data was prepared by Fiona Tummon (main author of paper) and stored in the /data-raw Folder.
Nine different Pollen Traps were situated on the roof in Payerne and continuously measured pollen 
grains between 19.04.2019 - 31.05.2019.
For the sake of simplicity we only look at concentrations of total pollen (i.e. the sum of all pollen taxa).
The concentrations were temporally averaged to obtain three different timeseries:

- Hourly averages
- 6-hour averages (hourly values from 00:00 to 05:00, 06:00 to 11:00, ...)
- Daily averages (hourly values from 00:00 to 23:00)

The preprocessed data is available to the reader in the /data folder. 
In /data-raw/preproc.R the preprocessing is documented.
The data has missing values in the Hirst2, Poleno(1 and 3) and RapidE timeseries. 
To be as conservative as possible all dates with missing pollen measurements were removed.
For Poleno1 calibration was carried out on 11 days.
For Poleno3 calibration was carried out on 6 days.
For RapidE software malfunctioned (it seems) during 9 days, as discussed with MDS.
These full 21 unique days were excluded from the analysis for all traps and temporal resolutions.
The whole analysis is based on the data excluding these 21 days, except for the timeseries plot (figure 1).
For the timeseries the full timeseries are displayed, which includes NAs for Poleno; Hirst and Rapid-E.

The following eight traps are being compared:

- Hirst = Mean(Hirst 1, Hirst 2) / 1.35 which will be the standard to compare against. Historically, we have the most experience with Hirst traps.
- Hund (no hourly values)
- KH-A
- KH-B
- Poleno 1
- Poleno 3
- Rapide
- WIBS (no hourly values)



