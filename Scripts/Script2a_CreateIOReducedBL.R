# This R script is designed to process data for creating a regional input-output
# (IO) matrix and saving it in an Excel file.

# Clear all objects from the current workspace to start with a clean environment
rm(list = ls())

# Load the main dataset from an RDS file
rawdata = readRDS("Data/riot.rds")

# Load mapping files from Excel relating administrative regions to regions (BL_Regions) and sectors to IO sectors (BL_Sectors)
mapags2reg = read_excel("Data/Correspondence.xlsx", sheet = "BL_Regions")
mapio2sec = read_excel("Data/Correspondence.xlsx", sheet = "BL_Sectors")

# Define the regions and sectors for the IO matrix, including a 'Rest of the World' (ROW) category
casregions = c(unique(mapags2reg$Region), "ROW")
cassectors = unique(mapio2sec$Sector)
# Include consumption as an additional sector
cassectorsuse = c(cassectors, "consumption")

# Initialize the IO matrix with the appropriate dimensions
dfioregional = matrix(nrow = length(casregions) * length(cassectors), 
                      ncol = length(casregions) * length(cassectorsuse))

# Set column and row names for the IO matrix based on regions and sectors
colnames(dfioregional) = paste0(casregions[sort(rep(1:length(casregions), length(cassectorsuse)))], 
                                "_", cassectorsuse[rep(1:length(cassectorsuse), length(casregions))])
rownames(dfioregional) = paste0(casregions[sort(rep(1:length(casregions), length(cassectors)))], 
                                "_", cassectors[rep(1:length(cassectors), length(casregions))])

# Loop through each row and column of the IO matrix to populate it with data
for(srow in rownames(dfioregional)){
  # Extract and process the region and sector of the origin from the row name
  sregionorigin = unlist(strsplit(srow, "_"))[1]
  ssectororigin = unlist(strsplit(srow, "_"))[2]
  # Select data based on the region and sector of origin
  lselectregorig = if(sregionorigin == "ROW") {
    !(rawdata$reporter %in% unlist(mapags2reg$ID))
  } else {
    rawdata$reporter %in% mapags2reg$ID[mapags2reg$Region == sregionorigin]
  }
  lselectsecorig = rawdata$sec %in% mapio2sec$Id[mapio2sec$Sector == ssectororigin]
  
  # Iterate over columns to determine and process the destination region and sector
  for(scol in colnames(dfioregional)){
    sregiondest = unlist(strsplit(scol, "_"))[1]
    lselectregdest = if(sregiondest == "ROW") {
      !(rawdata$partner %in% unlist(mapags2reg$ID))
    } else {
      rawdata$partner %in% mapags2reg$ID[mapags2reg$Region == sregiondest]
    }
    ssectordest = unlist(strsplit(scol, "_"))[2]
    lselectsecdest = if(ssectordest == "consumption") {
      rawdata$use %in% "consumption"
    } else {
      rawdata$use %in% mapio2sec$Id[mapio2sec$Sector == ssectordest]
    }
    # Sum the flow values for the specified origin and destination region-sector pairs
    dfioregional[srow, scol] = sum(rawdata$flow[lselectregorig & lselectsecorig & lselectregdest & lselectsecdest])
    # Print progress for each cell calculation
    print(paste0(srow, scol))
  }
}

# Create a new Excel workbook
wb = createWorkbook()

# Add a new worksheet and write the IO matrix to it
addWorksheet(wb, "RegionalIO")
writeData(wb, "RegionalIO", dfioregional, rowNames = TRUE)

# Save the workbook to an Excel file, overwriting any existing file
saveWorkbook(wb, "Data/BLIODE.xlsx", overwrite = TRUE)
