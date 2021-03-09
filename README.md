# Trapcomparison
What is really in the air? An evaluation of multiple automatic pollen monitors
Comparison of eight pollen monitors during the 2019 Blooming Season in Payerne CH

# Setup
The project is set up as a minimal R-package to assure maximum reproducibility (https://r-pkgs.org/index.html).
It is using renv dependency management, for more info: https://cran.r-project.org/web/packages/renv/vignettes/renv.html
To install all packages needed in your local R-environment simply run: renv::restore() in your local clone of this git repo

Packages installed by renv might depend on some shared libraries not available on the reader's system. For that reason we added the environment YAML file of our conda environment to this repo. Be aware that some libraries in there are not required for this project (it is the default env we use for R analyses).

The analysis was conducted in R-4.0.3.
If running and old R-Version some packages must be installed from CRAN Archive. Here for MeteoSwiss-default R-3.5.2:
 - caTools@1.17.1.1
 - pbkrtest@0.4-7
 - nloptr@1.2.2
 - foreign@0.8-76
 - usethis@1.5.1

The .RProfile is optimized for an interactive session in VSCode. Feel free to uncomment the respective lines if working in VS-Code.

# Branches
There are currently two branches:
 - Main: The status of the analysis when the paper was published
 - Develop: A branch for later updates to source code

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

The raw-data is stored in the /raw-data folder and was preprocessed using the preproc.R script in there. The script will create the two data sets located in the /data folder.
The data stored in /data is further documented in the /R folder.

# Vignette comparison.Rmd - The Statistical Analysis
Data preparation was carried out in R (R Core Team, 2021) using Tidyverse-packages (Wickham et al., 2019), with data obtained from the various traps in raw form and converted into hourly total pollen concentrations. Generally, each instrument in the analysis represents one measurement device, except for manual measurements, where data from the two Hirst-type traps were averaged to obtain a more robust reference against which the other devices were compared to. After an initial residual analysis, the measurements were converted into logarithmic concentrations for statistical comparison. Even the log-concentrations did not fulfil the assumption of standard statistical methods (i.e. assuming normality of errors with constant variance and mean zero). Hence robust statistical methods were applied. The Kruskal-Wallis test (Kruskal and Wallis, 1952) is considered a rank-based omnibus test, evaluating whether the variance among the different traps is greater than the unexplained variance (i.e. the variance within a dataset from a particular device). If the resulting explained variance is low, one can assume that the devices are similar. This omnibus test was then followed up by multiple pairwise tests between the instruments. The pairwise comparison and simultaneous confidence interval for the estimated effects was calculated using the nparcomp-package (Konietschke et al., 2015) with the Dunnet method; where the Hirst-mean was chosen as the reference level. The resulting estimator can be interpreted as a proxy for the relative difference in median between two devices. If the estimator is > 0.5 then the second device tends to have higher values. The null hypothesis H0: p = 0.5 is assessed on an α = 5 %-level. The lower and upperbounds denote the confidence interval of the estimator.

The vignette can be knitted into any format (e.g. pdf or html), or investigated as-is.


