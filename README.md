# Lorenz Curve and Gini Coefficient Analysis for Brazil

## Description
This project analyzes income inequality in Brazil using the Lorenz Curve (LC) and Gini coefficients. It uses real microdata from IBGE's PNAD Contínua survey to graph the country’s LC for 2024 (Q4) with World Bank data to compare Brazil's inequality to Latin American countries and the world average over time.

## Structure
The script is divided into 5 sections:

1.	**Data Download** – downloads and saves PNAD Contínua microdata for 2012 and to graph the LC and compare the change in Brazil’s Gini coefficient.
2.	**Cleaning, Computing, and Plotting** – extracts income data, computes the Lorenz Curve and Gini coefficient, and plots the results.
3.	**Comparing to Latin America** – downloads World Bank Gini data and calculates yearly LATAM and world averages.
4.	**Comparison Graph** – plots Brazil's Gini against the LATAM and world averages from 2000 to 2023.
5.	**Comparison Tables** – creates a ranked table of Latin American countries by Gini coefficient in 2023.

## Data Sources
- **IBGE PNAD Contínua** – Brazilian household survey microdata (Sections 1 – 2)
  - Variable VD4020: effective income from all jobs
  - Years: 2012 (Q1) and 2024 (Q4)
- **World Bank – World Development Indicators** – Gini coefficients for international comparisons (Sections 3 – 5)
  - Indicator: SI.POV.GINI
  - Years: 2000 – 2023

## Requirements

### Packages
```r
install.packages(c("PNADcIBGE",       # downloads IBGE PNAD microdata
                   "ineq",         		# computes inequality measures
                   "ggplot2",      		# plots charts and graphs
                   "survey",       		# handles survey weights
                   "dplyr",        		# data manipulation
                   "tidyr",        		# data reshaping
                   "wbstats",      		# downloads World Bank data
                   "DT",           		# interactive tables
                   "htmlwidgets",  		# exports tables as HTML
                   "webshot2"))       # converts HTML to PNG
```

### Notes
- PNAD microdata files are large (~200MB each) and are downloaded directly from IBGE's FTP server.
- After the first download, files are saved locally as `.rds` and loaded from disk on subsequent runs.
- World Bank data for Brazil's Gini in 2024 was not yet available at the time of writing (March 2026), so the international comparison is limited to 2000 – 2023.

## How to Run
1. Install all required packages listed above.
2. Set your working directory at the top of the script:
```r
setwd("your/path/here")
```
3. Run **Section 1** to download and save PNAD data – this only needs to be 
   done once. Comment out the download lines after the first run and use 
   `readRDS()` available on the first lines of Section 2 instead.
4. Run **Sections 2 – 5** to compute and visualize the results.

## Output
- **Lorenz Curve** for Brazil in 2024 (Q4) with Gini annotated.
- **Time series** of Gini coefficients – Brazil vs. LATAM average vs. World average (2000 – 2023).
- **Ranked table** of Latin American countries by Gini coefficient in 2023, 
  exported as a high-resolution PNG.

## Methodological Notes
- Brazil is excluded from both the LATAM and world averages to avoid circular comparisons.
- PNAD-based Gini values (Sections 1 – 2) and World Bank Gini values (Sections 3 – 5) use different methodologies and should not be directly compared.
  - PNAD measures income from work only (wages + self-employment).
  - World Bank uses total household income or consumption.
- Only Latin American countries with available World Bank data for 2023 are included in the comparison table.

## Author
Lukas Marques

March 2026
