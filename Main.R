# Script to simulate the impact of gas shortages

# Turn off any existing graphical devices in R
graphics.off()

# Remove all objects from the current workspace to start with a clean environment
rm(list = ls())

# List of required libraries for the analysis
libraries = c("readxl", "readr", "rstudioapi", "stringr", "openxlsx", "MASS")

# Install any libraries that are not already installed
lapply(libraries, function(x) if (!(x %in% installed.packages())) {
  install.packages(x)
})

# Load the required libraries
lapply(libraries, library, quietly = TRUE, character.only = TRUE)

# Set the working directory to the directory of the current script
setwd(dirname(getSourceEditorContext()$path))

# 1) Simulate gas shortage profile for industry
# This step involves running a script that simulates the gas shortage profile specifically for the industrial sector.
source("Scripts/Script1_SimulateGasStorage.R")

# 2) Create io tables
# These steps involve creating input-output tables for different regions or categories, if they don't already exist.
#a) for federal states if necessary (if Excel file does not already exist)
if(!file.exists("Data/InputOutputTables/BLIO.xlsx")){
  source("Scripts/Script2a_CreateIOReducedBL.R")  
}
#b) for east west if necessary (if Excel file does not already exist)
if(!file.exists("Data/InputOutputTables/EASTWESTIODE.xlsx")){
  source("Scripts/Script2b_CreateIOReducedEastWest.R")  
}

# 3) Compute first and second round effects for gas shortage profile
# This involves running scripts that compute the immediate and subsequent economic impacts of the gas shortages.
#a) first and second round effects 
source("Scripts/Script3a_Computation.R")  
#b) comparison with actual development
source("Scripts/Script3b_ComputationActual.R")  

# 4) Create Excel files for graphs
# These scripts are likely focused on generating data specifically formatted for graphical representation.
# a) first and second rounds effect
source("Scripts/Script4a_FirstSecondRoundEffects.R")  
# b) necessary imports of intermediates to avoid second round effects
source("Scripts/Script4b_IntermediateImports.R")  

# 5) Simple Example in the Online Appendix
# This script might provide a simplified example or case study for demonstration purposes, possibly for inclusion in an online appendix.
source("Scripts/Script5_SimpleExample.R")  
