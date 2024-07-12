# Create gas consumption profile

# Clear all existing objects from the workspace to ensure a clean start
rm(list = ls())

# Read the existing gas shortage profile data from an Excel file
dfgas <- read.xlsx("Data/Destatis/GasData.xlsx", sheet = "Data")

# Initialize simulation parameters for the year, starting month, and date
isimyear <- 2021
istartmonth <- 3
istartdate <- 2023+3/12

# Define gas storage capacity and minimum capacity threshold
igascap <- 250  # Total gas capacity
imincap <- 0.10 * igascap  # Minimum capacity (10% of total capacity)

# Set the period for the simulation
iperiod <- 2021

# Initialize the GasShort column in the dataframe to zero
dfgas$GasShort <- 0

# Loop through each date in the dataset starting from the specified start date
for(idate in dfgas$Datum[dfgas$Datum >= istartdate]){
  # Find the position of the current date in the dataset
  ipos <- which(dfgas$Datum == idate)
  
  # Calculate the month number based on the date
  imonth <- as.integer(12 * (idate - dfgas$Jahr[ipos]) + 1)
  
  # Find the position in the dataset for the simulation year and month
  iposimyear <- which(dfgas$Jahr %in% iperiod & dfgas$Monat == imonth)
  
  # Set the gas consumption for the current date to the maximum observed in the simulation year and month
  dfgas$GasCons[ipos] <- max(dfgas$GasCons[iposimyear])
  
  # Calculate the starting gas stock for the current date
  dfgas$GasStockStart[ipos] <- min(igascap, max(imincap, dfgas$GasStockStart[ipos - 1] - dfgas$GasCons[ipos] + dfgas$GasNetImp[ipos]))
  
  # Compute the gas shortage for the current date
  dfgas$GasShort[ipos] <- min(0, dfgas$GasStockStart[ipos - 1] - imincap - dfgas$GasCons[ipos] + dfgas$GasNetImp[ipos])
}

# Save the updated gas shortage profile back to an Excel file
write.xlsx(dfgas, "Output/ExcelFiles/GasShortageProfile.xlsx", sheetName = "Data")
