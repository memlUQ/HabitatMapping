# Eastern Banks Seagrass data processing
# 08/10/2025

######################### ---------- (A) SETUP ---------- #########################
## add necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(segmented)

## set working directory
setwd("D:/path/to/input/files")

####################### ---------- (B) LOAD DATA ---------- #######################
## load data
data <- read.csv("benthic_data.csv")
#summary(data) 
#print(data)

##################### ---------- (C) BASIC HANDLING ---------- ####################
## remove unwanted columns
#data <- dplyr::select(data, -transect, -site, -depth_m,
#                      -total, -project, -survey_id, -site_id
#)
## ensure photos are not duplicated in ReefCloud output 
data <- data[!duplicated(data$image_name), ]

## remove rows with NA in Latitude or Longitude columns
data <- data %>%
  filter(!is.na(Latitude) & !is.na(Longitude))

## display the column names in the dataset
colnames(data)

## same grouping step
data$date <- as.Date(data$date)
data$year <- format(data$date, "%Y")

## group and unnest
grouped_dates <- data %>%
  distinct(year, date) %>%  # get unique year-date pairs
  arrange(year, date)
print(grouped_dates)

######################### ---------- (D) FILTER ---------- ########################
## filter photos with less than 90% cover of the mapping classes of interest: seagrass, macroalgae, not_seagrass, microalgae 
## create "Total" column with the sum of the mapping classes of interest
## create new grouped columns
data <- data %>%
  mutate(
    Other_ = rowSums(across(c(
      "Anemone", "Echinoderms..sea.urchin", "Echinoderms..Sea.stars", "Sponge",
      "All.other", "CRED.Tape", "CRED.Wand", "hard.substrate.with.turf", "Other",
      "Other.hard.coral", "Other.soft.coral", "Out.of.focus", "Shadow_TWS",
      "Unknown", "Pinna", "Sea.cucumber"
    )), na.rm = TRUE),
    
    Sand_ = rowSums(across(c(
      "muddy.sand", "Sand", "Shell.hash.Gravel"
    )), na.rm = TRUE),
    
    Microalgae_ = rowSums(across(c(
      "Benthic.Microalgae.on.Sand", "Cyanobacteria",
      "Cyanobacteria.smothering.dead.coral", "Microalgae"
    )), na.rm = TRUE),
    
    Green_Macroalgae = rowSums(across(c(
      "Caulerpa", "Halimeda",
      "Macroalgae..Articulated.calcareous..green", "Udotea.spp."
    )), na.rm = TRUE),
    
    Cymodocea = rowSums(across(c(
      "Cymodocea.rotundata", "Cymodocea.serrulata"
    )), na.rm = TRUE),
    
    Brown_Macroalgae = rowSums(across(c(
      "Hydroclathrus", "Padina", "Sargassum"
    )), na.rm = TRUE)
  )

## sum the relevant columns to clean up data
data <- data %>%
  mutate(
    Total = rowSums(across(c(
      "Sand_", "Microalgae_", "Green_Macroalgae", "Cymodocea", "Brown_Macroalgae",
      "Dead.seagrass", "Halodule.uninervis", "Halophila.ovalis", "Halophila.spinulosa",
      "Lyngbya.majuscula", "Seagrass", "Syringodium", "Zostera.muelleri"
    )), na.rm = TRUE),
    Total_sg = rowSums(across(c(
      "Halodule.uninervis", "Halophila.ovalis", "Halophila.spinulosa",
      "Seagrass", "Syringodium", "Zostera.muelleri", "Cymodocea"
    )), na.rm = TRUE),
    Total_macroalgae = rowSums(across(c(
      "Green_Macroalgae", "Brown_Macroalgae"
    )), na.rm = TRUE),  
  )


## print the updated dataframe
#print(final_data)

## count the number of rows where Total is less than 90%
rows_below_90 <- data %>%
  filter(Total < 90) %>%
  nrow()
## print the count
print(rows_below_90)

## remove rows where Total is less than 0.90
data  <- data %>%
  filter(Total >= 90)


################### ---------- (E) DOMINANT BENTHOS ---------- ####################
## create dominant benthos (DomBen) Class and apply thresholds
data_thresholds_DomBen <-data
## create thresholds to assign one dominant benthic type per photoquadrat
## create new variable - Dom_Ben based on the dominant benthic type (seagrass species, non-seagrass, or algae, total invertebrates)
data_thresholds_DomBen <- data_thresholds_DomBen %>%
  mutate(
    Dom_Ben = case_when(
      # first filter "dense" species
      Cymodocea >= 40 ~ "Cymodocea",
      Zostera.muelleri >= 40 ~ "Zostera",
      Halodule.uninervis >= 40 ~ "Hal_Uninervis",
      Syringodium >= 40 ~ "Syringodium",
      # establish thresholds for cryptic/sparse species
      Total_sg >= 50 & Halophila.ovalis >= 5 ~ "Hal_Ovalis",
      Sand_ >= 50 & Halophila.ovalis >= 5 ~ "Hal_Ovalis",
      Total_sg >= 50 & Halophila.spinulosa >= 5 ~ "Hal_Spinulosa", #everything else <5
      Sand_ >= 50 & Halophila.spinulosa >= 5 ~ "Hal_Spinulosa",
      # mixed seagrass (total seagrass is >50% but no dominant spp.)
      Total_sg >= 50 ~ "Mixed_Seagrass",
      # lyngbya
      Lyngbya.majuscula >= 50 ~ "Lyngbya",
      # sand?
      Sand_ >= 50 ~ "Sand",
      # mixed category for everything else (not one of the above is dominant)
      TRUE ~ "Mixed_Ben"
    )
  )

# generate a frequency table per Dom_Ben
class_frequency_DomBen <- table(data_thresholds_DomBen$Dom_Ben)
View(class_frequency_DomBen)

# define the levels of Dom_ben and their corresponding numeric values
levels_DomBen <- c("Cymodocea", "Zostera", "Hal_Uninervis", "Hal_Spinulosa", "Hal_Ovalis", "Syringodium", "Mixed_Seagrass",
            "Lyngbya", "Macro_Algae", "Micro_Algae", "Sand", "Mixed_Ben") 
values_Dom_Ben <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)

# create a connection between the Dom_ben classes to numeric values
level_to_value_DomBen <- setNames(values_Dom_Ben, levels_DomBen)

# create the Class_num variable based on the Dom_ben variable
data_thresholds_DomBen <- data_thresholds_DomBen %>%
  mutate(Class_num = level_to_value_DomBen[Dom_Ben])
#str(data_thresholds_DomBen)

##################### ---------- (F) PERCENT COVER ---------- #####################
## create Percent Cover (PerCov) class and apply thresholds
## create copy to try one set of thresholds
data_thresholds_PerCov <-data_thresholds_DomBen

## create thresholds to assign one percent cover threshold per photoquadrat
## create new variable - Per_Cov based on the seagrass percent cover
data_thresholds_PerCov <- data_thresholds_PerCov %>%
  mutate(
    Per_Cov = case_when(
      #First filter "dense" species
      Total_sg >= 1 & Total_sg <= 10 ~ "1",
      Total_sg >= 11 & Total_sg <= 20 ~ "2",
      Total_sg >= 21 & Total_sg <= 30 ~ "3",
      Total_sg >= 31 & Total_sg <= 40 ~ "4",
      Total_sg >= 41 & Total_sg <= 50 ~ "5",
      Total_sg >= 51 ~ "6",
      Total_sg >= 0 ~ "7",
    )
  )

## generate a frequency table per Dom_Ben
class_frequency_PerCov <- table(data_thresholds_PerCov$Per_Cov)
View(class_frequency_PerCov)

######################### ---------- (G) EXPORT ---------- ########################
## split the data dataframe by the 'year_month' column
split_data <- split(data_thresholds_PerCov, data_thresholds_PerCov$year_month) #MAKE SURE TO UPDATE DATAFRAM TO EXPORT THE RIGHT VERSION

## choose directory
folder_path <- "R:/SMARTSATHS-Q6635/Eastern_Banks/Inputs/Benthic_data/compiled/Time Series GEE Classes/Joint_Thresholds_Classes_20250708"

## iterate over each split, export it to a CSV file
for (year_month in names(split_data)) {
  ## get the dataframe for the current year_month
  year_month_data <- split_data[[year_month]]
  
  ## define the file path for the CSV file
  file_path <- file.path(folder_path, paste0(year_month, ".csv"))
  
  ## export the dataframe to CSV
  write.csv(year_month_data, file = file_path, row.names = FALSE)
}

## export entire dataset in single file
# set up file path
file_path <- file.path(folder_path, "Seagrass_EB_data.csv")
# export to csv
write.csv(data, file = file_path, row.names = FALSE)


########################## ---------- (H) PLOT ---------- #########################
plot_data <- select(data, Dom_Ben, bank, year)

## calculate percentages for each Dom_Ben within each bank and year
plot_data_percent <- plot_data %>%
  group_by(bank, year, Dom_Ben) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(bank, year) %>%
  mutate(percent = 100 * (count / sum(count))) %>%
  ungroup()

## filter for the first four banks
plot_data_percent_filtered <- plot_data_percent %>%
  filter(bank %in% c("AM", "MA", "MO", "WA"))

## rename and reorder the levels of Dom_Ben
plot_data_percent_filtered <- plot_data_percent_filtered %>%
  mutate(Dom_Ben = factor(Dom_Ben, levels = c(
    "Zostera", "Hal_Spinulosa", "Hal_Ovalis", "Hal_uninervis", "Cymodocea",
    "Syringodium", "Mixed_Seagrass", "Lyngbya", "Micro_Algae", "Macro_Algae",
    "Sand", "Abiotic_Benthos", "Mixed_Ben"
  ),
  labels = c(
    "Zostera", "H. spinulosa", "H. ovalis", "H. uninervis", "Cymodocea spp.",
    "Syringodium spp.", "Mixed Seagrass", "Lyngbya spp.", "Microalgae", "Macroalgae",
    "Sand", "Abiotic Benthos", "Mixed Benthos"
  )))

## create the line plot with the updated names and custom colors
ggplot(plot_data_percent_filtered, aes(x = year_month, y = percent, group = Dom_Ben, color = Dom_Ben)) +
  geom_line(size = 0.9) +  # Add lines for trends
  geom_point(size = 2) +  # Add dots for each year
  facet_wrap(~ bank, scales = "fixed") +  # Ensure fixed y-axis across all facets
  ylim(0, 100) +  # Set y-axis limits
  scale_color_manual(values = c(
    "Zostera" = "#73c2fb",
    "H. spinulosa" = "#c7ea46",
    "H. ovalis" = "#0b6623",
    "H. uninervis" = "#7b7dcf",
    "Cymodocea spp." = "#ff0800",
    "Syringodium spp." = "#1134a6",
    "Mixed Seagrass" = "#7c4700",
    "Lyngbya spp." = "#3ba036",
    "Microalgae" = "#8f00ff",
    "Macroalgae" = "#f81894",
    "Sand" = "#f8e473",
    "Abiotic Benthos" = "#ff9101",
    "Mixed Benthos" = "#222021"
  )) +
  labs(title = "Percent Cover of Dominant Benthic Type per Bank",
       x = "Year",
       y = "Percentage (%)",
       color = "Benthic Type") +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.background  = element_rect(color = 'black', fill = NA, size = 0.7, linetype = 'solid'))