## Set working directory
setwd("PATH TO WORKING DIRECTORY")

## Load data
data <- read.csv("PATH TO RAW FIELD DATA")
head(data)
summary(data)
print(data)

##Add necessary Libraries
library(ggplot2)
library(dplyr)

## Delete unnecessary columns 
data1 <- select(data, -Image, -Date, -layer, -path, -xcoord, -ycoord, 
                -survey_title,  -Name_2, -date_2, -project, -site, -total, 
                -org_name, -Water, -transect_gear, -unclear, - unknown,
                -All_Other, -Crown_of_Thorns_Sea_Star, -Mobile_Invertebrate,
                -Sargassum, -Seagrass,  -Sessile_Invertebrate_Other, -depth_m,
                -transect, -xcoord_2, -ycoord_2
)
head(data1)

# Ensure photos are not duplicated
data_clean <- data1[!duplicated(data1$Name), ]

#########################
#START PROCESSING CLASSES
#########################

## Merge Coral per Class
Merged <- data_clean %>%
  rowwise() %>%
  mutate(
    Coral_Tot = sum(c_across(starts_with("Acropor")),
                     c_across(starts_with("Branching")),
                     c_across(starts_with("Porites")),
                     c_across(starts_with("Pocillopora")),
                     c_across(contains("Soft_Coral")),
                     c_across(starts_with("Favid")),
                     c_across(starts_with("Foliose")),
                     c_across(starts_with("Gorgonian")),
                     c_across(starts_with("Hard_Coral")),
                     c_across(starts_with("Massive")), 
                     na.rm = TRUE),
  ) %>%
  ungroup() %>%
  select(-starts_with("Acropor"), -starts_with("Branching"), -starts_with("Porites"), 
         -starts_with("Pocillopora"), -contains("Soft_Coral"), -starts_with("Favid"),
         -starts_with("Foliose"), -starts_with("Gorgonian"), -starts_with("Hard_Coral"),
         -starts_with("Massive")
  )
#head(Merged)

## Create Alga Total
Merged <- Merged %>%
  rowwise() %>%
  mutate(
    Alga_Tot = sum(c_across(starts_with("Algae")), 
                   c_across(starts_with("BMA")),
                   c_across(starts_with("Chlorodesmis")),
                   c_across(starts_with("Cualerpa")),
                   c_across(starts_with("Cyano")),
                   c_across(starts_with("Dictyota")),
                   c_across(starts_with("Halimeda")),
                   c_across(starts_with("Lobophora")),
                   c_across(starts_with("Padina")),
                   c_across(starts_with("Turbinaria")),
                   na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(-starts_with("Algae"), -starts_with("BMA"), -starts_with("Chlorodesmis"),
         -starts_with("Cualerpa"), -starts_with("Cyano"), -starts_with("Dictyota"),
         -starts_with("Halimeda"), -starts_with("Lobophora"), -starts_with("Padina"),
         -starts_with("Turbinaria"),
  )

#head(Merged)

## Crearte Rock Total
Merged <- Merged %>%
  rowwise() %>%
  mutate(
    Rock_Tot = sum(c_across(ends_with("DHC")), c_across(ends_with("ubble")),
                   na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(-ends_with("DHC"), -ends_with("ubble"))

#head(Merged)

##Clean table - get rid of "NA" rows
Merged <- na.omit(Merged)

#########
# Update the Total column to contain the sum of Coral_Tot, Algae_Tot, Rock_Tot, and Sand_Tot
Merged <- Merged %>%
  mutate(Total = Coral_Tot + Alga_Tot + Rock_Tot + Sand_)
# Print the updated dataframe
#print(final_data)

# Count the number of rows where Total is less than 0.90
rows_below_90 <- Merged %>%
  filter(Total <= 90) %>%
  nrow()
# Print the count
print(rows_below_90)

# Remove rows where Total is less than 0.90
Merged  <- Merged %>%
  filter(Total >= 90)


#######################
#CREATE MAPPING CLASSES
#######################

# Create new variable Dom_Ben based on conditions
Merged <- Merged %>%
  mutate(
    Dom_Ben = case_when(
      # Coral dominant - where CC is over 30%
      Coral_Tot >= 30 ~ "Coral_Dominant",
      # Algae dominant with coral cover between 5-30%
      Alga_Tot >= 50 & Coral_Tot >= 5 & Coral_Tot < 30 ~ "Algae_Coral",
      Rock_Tot >= 50 & Coral_Tot >= 5 & Coral_Tot < 30 ~ "Rock_Coral",
      Sand_ >= 50 & Coral_Tot >= 5 & Coral_Tot < 30 ~ "Sand_Coral",
      # Algae dominant
      Alga_Tot >= 50 ~ "Algae_Dominant",
      # Rock dominant
      Rock_Tot >= 50 ~ "Rock_Dominant",
      # Sand dominant
      Sand_ >= 50 ~ "Sand_Dominant",
      # Mixed category for everything else
      TRUE ~ "Mixed"
    )
  )

# Generate a frequency table
class_frequency <- table(Merged$Dom_Ben)
View(class_frequency)

# Define the levels of Dom_ben and their corresponding numeric values
levels <- c("Coral_Dominant", "Algae_Dominant", "Algae_Coral", "Rock_Dominant", "Rock_Coral", "Sand_Dominant", "Sand_Coral", "Mixed") 
values <- c(1, 2, 3, 4, 5, 6, 7, 8)
# Create a connection bewtween the Dom_ben classes to numeric values
level_to_value <- setNames(values, levels)

# Create the Class_num variable based on the Dom_ben variable
Merged <- Merged %>%
  mutate(Class_num = level_to_value[Dom_Ben])

class_frequency2 <- table(Merged$Class_num)
View(class_frequency2)


########
# EXPORT
########

# Choose directory
folder_path <- 'PATH TO FOLDER'

# Define the file path
file_path <- file.path(folder_path, "NAME OF OUTPUT FILE")

# Export the dataframe to CSV
write.csv(Merged, file = file_path, row.names = FALSE)

