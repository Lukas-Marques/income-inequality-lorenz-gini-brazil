# ==============================================================================
# Title:   Lorenz Curve and Gini Coefficient — Brazil & LATAM
# Author:  Lukas Marques
# Date:    March 13th, 2025
# Data:    IBGE PNAD Contínua + World Bank WDI
# Description: Analyzes income inequality in Brazil using the
#              Lorenz Curve and Gini coefficients, comparing
#              Brazil to Latin American countries and the world average
# ==============================================================================


# 1. Downloading data and loading packages =====================================

# Set working directory in your computer
#setwd("your/path/here")

# Installing packages
  # Remove the # to install the packages on you computer
#install.packages(c("PNADcIBGE", "ineq", "ggplot2", "survey", "dplyr", 
 #                  "tidyr", "wbstats", "DT", "htmlwidgets", "webshot2"))

# Loading packages
library(PNADcIBGE)    # gets IBGE's PNAD microdata
library(ineq)         # computes the inequality measures
library(ggplot2)      # plots charts and graphs
library(survey)       # weights survey data
library(dplyr)        # cleans the data
library(wbstats)      # downloads World Bank data
library(DT)           # interactive table
library(htmlwidgets)  # exports tables as HTML
library(webshot2)     # converts HTML to PNG

# NOTE: PNAD data is available starting 2012

# Downloading and saving real PNAD data
  # If running for the first time, remove #
#pnad_2012 <- get_pnadc(year = 2012, quarter = 1)
#saveRDS(pnad_2012, file = "pnad_2012_q1.rds")
#pnad_2024 <- get_pnadc(year = 2024, quarter = 4)
#saveRDS(pnad_2024, file = "pnad_2024_q4.rds")


# 2. Cleaning, computing, and plotting =========================================
  # This section processes PNAD microdata for 2012 and 2024 to calculate the Gini 
  # coefficient for Brazil in both years, compare the change over time, and 
  # compute and plot the Lorenz Curve

# After downloading and saving for the first time, just load from the disk with:
pnad_2012 <- readRDS("pnad_2012_q1.rds")
pnad_2024 <- readRDS("pnad_2024_q4.rds")

# Extracting income data
  # Note: VD4020 is effective income from all jobs (wages + self-employment)

income_data_2012 <- pnad_2012$variables %>%     # Takes the data, and then...
  select(income = VD4020) %>%                   # select income column, then...
  filter(!is.na(income), income > 0) %>%        # keep only rows with values, then...
  pull(income)                                  # extracts column as a plain vector

income_data_2024 <- pnad_2024$variables %>%     
  select(income = VD4020) %>%                   
  filter(!is.na(income), income > 0) %>%        
  pull(income)                                  

# Computing the Lorenz Curve
  # Lc() calculates the cumulative population and income shares
lc_2012 <- Lc(income_data_2012)
lc_2024 <- Lc(income_data_2024)

lorenz_2012 <- data.frame(
  population = lc_2012$p,        # get the population share vector
  income = lc_2012$L,            # get the income share vector
  year = "2012"
)

lorenz_2024 <- data.frame(
  population = lc_2024$p,        
  income = lc_2024$L,            
  year = "2024"
)

# Combining both years into one dataframe
lorenz_all <- bind_rows(lorenz_2012, lorenz_2024)

# Calculating the Gini coefficient
gini_2012 <- round(ineq(income_data_2012, type = "Gini"), 3)
gini_2024 <- round(ineq(income_data_2024, type = "Gini"), 3)

cat("Gini 2012:", gini_2012, "\n")
cat("Gini 2024:", gini_2024, "\n")

# Plotting the Lorenz Curve for 2024
ggplot(lorenz_2024, aes(x = population, y = income)) +
  
  # Shading between Lorenz Curve and equality line
  geom_ribbon(aes(ymin = income, ymax = population),
              fill = "#2E8B57", alpha = 0.15) +                          # shaded inequality gap
  
  geom_abline(slope = 1, intercept = 0,
              linetype = "dashed", color = "gray40", linewidth = 0.8) +  # line of perfect equality
  
  geom_line(color = "#2E8B57", linewidth = 1.2) +                        # lorenz curve for 2024
  
  annotate("text", x = 0.3, y = 0.75,
           label = paste("Gini:", gini_2024),
           color = "#2E8B57", size = 4, fontface = "bold") +             # gini 2024 annotated on plot
  
  # Labels
  labs(
    title    = "Lorenz Curve — Brazil (2024, Q4)",
    subtitle = "Based on real IBGE microdata (VD4020 - income from all jobs)",
    x        = "Cumulative Share of Population (poorest → richest)",
    y        = "Cumulative Share of Income",
    caption  = "Source: IBGE — PNAD Contínua"
  ) +
  
  scale_x_continuous(labels = scales::percent) +                         # formats x axis as percentages
  scale_y_continuous(labels = scales::percent) +                         # formats y axis as percentages
  
  theme_minimal(base_size = 14) +                                        # clean background style
  theme(plot.title = element_text(face = "bold"))                        # bold title

# Save with high resolution, remove #
#ggsave("lorenz_curve_brazil.png",
   #    width  = 10,      # width in inches
   #    height = 6,       # height in inches
   #    dpi    = 300)     # 300 DPI is standard for print quality


# 3. Comparing to other Latin American countries ===============================
  # This section uses World Bank data to compare Brazil's Gini coefficient to
  # the average of other Latin American countries and the world from 2000 to 2023.
  # Brazil is excluded from both the LATAM and world averages. 
    # Note: World Bank data for Brazil's Gini in 2024 is not yet available 
    # as of 03/09/2026, so the analysis is limited to 2000-2023.


# Download Gini data for all countries
gini_world <- wb_data("SI.POV.GINI",
                      start_date = 2000,
                      end_date = 2024)

# Yearly world average for comparison
gini_world_avg <- gini_world %>%
  filter(!is.na(SI.POV.GINI)) %>%                 # remove blanks
  filter(country != "Brazil") %>%                 # exclude Brazil
  mutate(SI.POV.GINI = SI.POV.GINI / 100) %>%     # turn into decimals
  group_by(date) %>%                              # calculate one average per year
  summarise(gini_avg = mean(SI.POV.GINI), group = "World Average")

# Filter Latin American countries
latam_countries <- c("Brazil", "Argentina", "Chile", "Colombia", "Mexico",
                     "Peru", "Uruguay", "Paraguay", "Bolivia", "Ecuador",
                     "Venezuela", "Costa Rica", "Panama", "Honduras",
                     "Guatemala", "El Salvador", "Nicaragua", "Dominican Republic")

gini_latam <- gini_world %>%
  filter(country %in% latam_countries) %>%    # filtering countries
  filter(!is.na(SI.POV.GINI)) %>%             # remove blanks
  mutate(SI.POV.GINI = SI.POV.GINI / 100)     # turn into decimals

# Calculate LATAM average excluding Brazil
gini_latam_avg <- gini_latam %>%
  filter(date >= 2000 & date <= 2023) %>%
  filter(!is.na(SI.POV.GINI)) %>%
  filter(country != "Brazil") %>%             # exclude Brazil
  group_by(date) %>%
  summarise(gini_latam_avg = mean(SI.POV.GINI))

print(gini_latam_avg, n = Inf)


# 4. Comparison graph (2000 - 2023) ============================================
  # This section combines Brazil's Gini and both LATAM and the world averages into
  # a single dataframe and plots them together over time.

# Download Brazil's Gini
gini_brazil <- wb_data("SI.POV.GINI",
                       country = "Brazil",
                       start_date = 2000,
                       end_date = 2024)

gini_brazil <- gini_brazil %>%
  filter(!is.na(SI.POV.GINI)) %>%              # remove blanks
  mutate(SI.POV.GINI = SI.POV.GINI / 100) %>%  # turn into decimals
  mutate(date = as.numeric(date))              # ensure date is numeric

# Combining the data
latam_label <- gini_latam_avg %>%
  rename(gini_avg = gini_latam_avg) %>%
  mutate(group = "LATAM Average")

world_label <- gini_world_avg %>%
  filter(date >= 2000 & date <= 2023) %>%
  mutate(group = "World Average")

brazil_label <- gini_brazil %>%
  filter(date >= 2000) %>%
  rename(gini_avg = SI.POV.GINI) %>%
  mutate(group = "Brazil")

gini_combined <- bind_rows(latam_label,
                  world_label,
                  brazil_label)

# Plotting
gini_labels <- gini_combined %>%
  group_by(group) %>%
  filter(date == max(date)) %>%              # get last year for each group
  ungroup()

ggplot(gini_combined, aes(x = date, y = gini_avg, color = group)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_text(data = gini_labels,
            aes(label = round(gini_avg, 3),
                color = group),
            hjust = -0.2,
            size = 3.5,
            fontface = "bold",
            show.legend = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.1))) +
  scale_color_manual(values = c("Brazil"        = "#2E8B57",
                                "LATAM Average" = "#E07B39",
                                "World Average" = "#3A7EC6")) +
  labs(
    title   = "Gini Coefficient — Brazil vs. LATAM vs. World (2000 – 2023)",
    x       = "Year",
    y       = "Gini Coefficient",
    color   = NULL,
    caption = "Source: World Bank — World Development Indicators"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title       = element_text(face = "bold", size = 16),
    plot.caption     = element_text(color = "gray50", size = 9),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )


# Save with high resolution
#ggsave("gini_comparison.png",
  #   width  = 10,      # width in inches
   #  height = 6,       # height in inches
    # dpi    = 300)     # 300 DPI is standard for print quality


# 5. Comparison table (top 10 highest Gini in 2023) ============================
  # This section creates a ranked table of Latin American countries by Gini
  # coefficient in 2023. 

# Latam rank by Gini for 2023
latam_gini_rank <- gini_latam %>%
  filter(date == 2023) %>%
  filter(!is.na(SI.POV.GINI)) %>%            
  arrange(desc(SI.POV.GINI)) %>%
  select(country, SI.POV.GINI) %>%
  rename(Country = country) %>%
  rename(Gini = SI.POV.GINI) %>%
  print()

# Creating the table
brazil_row <- data.frame(
  Country = "Brazil",
  `2023`  = round(gini_world %>% 
                    filter(country == "Brazil", date == 2023) %>% 
                    pull(SI.POV.GINI) / 100, 3),
  check.names = FALSE                          # prevents R from renaming columns
)

latam_gini_2023 <- gini_latam %>%
  filter(date == 2023) %>%                     # keep only 2012 and 2023
  filter(!is.na(SI.POV.GINI)) %>%              # remove missing values
  filter(country != "Brazil") %>%              # exclude Brazil (added manually)
  select(country, date, SI.POV.GINI) %>%       # keep only relevant columns
  tidyr::pivot_wider(
    names_from  = date,                        # years become columns
    values_from = SI.POV.GINI                  # gini values fill the cells
  ) %>%
  rename(Country = country) %>%
  mutate(`2023` = round(`2023`, 3)) %>%
  bind_rows(brazil_row) %>%                    # add Brazil's row
  arrange(desc(`2023`))                        # sort by 2023 gini decreasing

# Display the table with Brazil highlighted

latam_gini_table <- DT::datatable(latam_gini_2023,
                                  caption  = htmltools::tags$caption(
                                    htmltools::tags$div(
                                      style = "text-align: left; font-weight: bold; font-size: 18px; margin-bottom: 5px;",
                                      "Gini Coefficient — Latin American Countries (2023)"
                                    ),
                                    htmltools::tags$div(
                                      style = "text-align: left; color: gray; font-size: 11px; margin-top: 5px;",
                                      "Source: World Bank — World Development Indicators"
                                    )
                                  ),
                                  options = list(
                                    pageLength = 20,
                                    dom        = "t",
                                    initComplete = JS(             # applies CSS to adjust the table
                                      "function(settings, json) {",
                                      "$(this.api().table().container()).css({'max-width': '410px'});",
                                      "}"
                                    )
                                  )) %>%
  DT::formatStyle(
    "Country",
    target          = "row",
    backgroundColor = DT::styleEqual("Brazil", "#d4edda"),
    fontWeight      = DT::styleEqual("Brazil", "bold")
  ) %>%
  DT::formatStyle(
    "Country",
    width = "200px"                            # set Country column width
  ) %>%
  DT::formatStyle(
    "2023",
    width = "100px"                            # set Gini column width
  )

latam_gini_table

# Save as HTML to download with better quality

#saveWidget(latam_gini_table, "latam_table.html")      # export as HTML
#webshot2::webshot("latam_table.html",
 #                 "latam_table.png",
  #                selector = ".dataTables_wrapper",   # captures only the table element
   #               expand   = 20,                      # adds 20px of white space around the table
    #              zoom = 3)                           # zoom = 3 for high resolution
