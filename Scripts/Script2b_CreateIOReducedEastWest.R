# Set the working directory to a specified path (the command is missing in the provided script)
# The script then reads a raw data file and mapping files for regional and sectoral classification
rawdata = readRDS("Data/riot.rds")
mapags2reg = read_excel("Data/Correspondence.xlsx", sheet = "EastWest_Regions")
mapio2sec = read_excel("Data/Correspondence.xlsx", sheet = "Primary_Sectors")

# Define the regions and sectors for the IO matrix, including 'Rest of the World' (ROW)
casregions = c(unique(mapags2reg$Region), "ROW")
cassectors = unique(mapio2sec$Sector)
# Include consumption as an additional sector for analysis
cassectorsuse = c(cassectors, "consumption")

# Initialize the IO matrix with dimensions based on the number of regions and sectors
dfioregional = matrix(nrow = length(casregions) * length(cassectors), 
                      ncol = length(casregions) * length(cassectorsuse))

# Set the column and row names for the IO matrix based on regions and sectors
colnames(dfioregional) = paste0(casregions[sort(rep(1:length(casregions), length(cassectorsuse)))], 
                                "_", cassectorsuse[rep(1:length(cassectorsuse), length(casregions))])
rownames(dfioregional) = paste0(casregions[sort(rep(1:length(casregions), length(cassectors)))], 
                                "_", cassectors[rep(1:length(cassectors), length(casregions))])

# Populate the IO matrix by iterating through each row and column
for(srow in rownames(dfioregional)){
  # Extract and process the region and sector of the origin from the row name
  sregionorigin = unlist(strsplit(srow, "_"))[1]
  ssectororigin = unlist(strsplit(srow, "_"))[2]
  # Determine the appropriate data selection based on region and sector of origin
  lselectregorig = if(sregionorigin == "ROW") {
    !(rawdata$reporter %in% unlist(mapags2reg$ID))
  } else {
    rawdata$reporter %in% mapags2reg$ID[mapags2reg$Region == sregionorigin]    
  }
  lselectsecorig = rawdata$sec %in% mapio2sec$Id[mapio2sec$Sector == ssectororigin]
  
  # Repeat the process for each column to determine the destination region and sector
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

# Create a new Excel workbook, add the IO matrix as a worksheet, and save the workbook
wb = createWorkbook()
addWorksheet(wb, "RegionalIO")
writeData(wb, "RegionalIO", dfioregional, rowNames = TRUE)
saveWorkbook(wb, "Data/EASTWESTIODE.xlsx", overwrite = TRUE)
