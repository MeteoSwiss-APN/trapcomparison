# Trapcomparison
What is really in the air? An evaluation of multiple automatic pollen monitors

# Setup
The project is set up as a minimal R-package to assure maximum reproducibility (https://r-pkgs.org/index.html).
It is using renv dependency management, for more info: https://cran.r-project.org/web/packages/renv/vignettes/renv.html
To install all packages needed in your local R-environment simply run: `renv::restore()` in your local clone of this git repo

Packages installed by renv might depend on some shared libraries not available on the reader's system. For that reason we added the environment YAML file of our conda environment to this repo. Be aware that some libraries in there are not required for this project (it is the default env we use for R analyses). This command would install the required libraries in a new conda env: `conda env create -n new_env -f environment.yml`

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
This first step of data preparation is not documented here.
Nine different Pollen Traps were situated on the roof in Payerne and continuously measured pollen 
grains between 19.04.2019 - 31.05.2019.
For the sake of simplicity we only look at concentrations of total pollen (i.e. the sum of all pollen taxa).
The concentrations were temporally averaged to obtain three different timeseries:

- Hourly averages
- 6-hour averages (hourly values from 00:00 to 05:00, 06:00 to 11:00, ...)
- Daily averages (hourly values from 00:00 to 23:00)

The preprocessed data is available to the reader in the /data folder. 
In /data-raw/preproc.R the preprocessing is documented.
The data has missing values in the Hirst2, Poleno(1 and 4) and Rapid-E timeseries. 
For Poleno1 calibration was carried out on 11 days.
For Poleno4 calibration was carried out on 6 days.
For Rapid-E software malfunctioned (it seems) during 9 days, as discussed with MDS (Meteoswiss - measurements and data).
If there was too much missing data present in a timeseries, all timeseries were set to NA for this period.
This allows for a fair comparison between traps, only when all of them measured.
For hourly values, every hour was investigated by itself. 
For sixhour and daily averages, "too much missing data" was defined as more than 50% of the hourly values in the period.
The whole analysis is based on the data excluding such windows with too much missing data, except for the timeseries plot (figure 1).
For the timeseries the full timeseries are displayed, which includes NAs for Poleno; Hirst and Rapid-E.

The following eight traps are being compared:

- Hirst = Mean(Hirst 1, Hirst 2) / 1.35 which will be the standard to compare against. Historically, we have the most experience with Hirst traps.
- BAA-500 (no hourly values)
- KH-3000-A
- KH-3000-B
- Poleno-1
- Poleno-4
- Rapid-E
- WIBS-NEO

The raw-data is stored in the /raw-data folder and was preprocessed using the preproc.R script in there. The script will create the two data sets located in the /data folder.
The data stored in /data is further documented in the /R folder.

# Vignette comparison.Rmd - The Statistical Analysis
Data preparation was carried out in R (R Core Team, 2021) using Tidyverse-packages, with data from the various devices obtained in raw form and converted into hourly, or six-hourly total pollen concentrations, depending on the instrument. The hourly concentrations were then aggregated into 6-hourly and daily averages to investigate differences between devices. At least 3 out of 6 hours or 12 out of 24 hours needed to have data for an average to be calculated for the 6-hourly or daily averages, respectively. Malfunction or maintenance of all devices was logged and to ensure a fair evaluation of all instruments, all time periods with missing data, no matter the reason, were removed from the time series’ of all devices. In total, this meant that 23.8% of all hourly averages, 22.1% of all 6-hourly averages and 18.6% of all daily averages were removed from the dataset (Table 1). Generally, each instrument in the analysis represents one measurement device, except for the manual measurements, where data from the two Hirst-type traps were averaged to obtain a more robust reference against which the other devices were compared. For the statistical analysis all time steps where the hirst-average was below 10 pollen grains/m3, were excluded from the data set.

After an initial residual analysis, the measurements were converted into logarithmic concentrations for statistical comparison. Even the log-concentrations did not fulfil the assumption of standard statistical methods (i.e. assuming normality of errors with constant variance and mean zero). Hence, robust statistical methods were applied. The Kruskal-Wallis test is considered a rank-based omnibus test, evaluating whether the variance among the different instruments is greater than the unexplained variance (i.e. the variance within a data set from a particular device). If the resulting explained variance is low, one can assume that the devices are similar. This omnibus test was then followed up by multiple pairwise tests between the instruments. The pairwise comparison and simultaneous confidence interval for the estimated effects were calculated using the nparcomp-package with the Dunnet method, where the Hirst-mean was chosen as the reference level. The resulting estimator can be interpreted as a proxy for the relative difference in median between two devices. If the estimator is > 0.5 then the second device tends to have higher values. The null hypothesis H0: p = 0.5 is assessed on an α = 5 %-level. The lower and upper bounds denote the confidence interval of the estimator.


The vignette can be knitted into any format (e.g. pdf or html), or investigated as-is.


