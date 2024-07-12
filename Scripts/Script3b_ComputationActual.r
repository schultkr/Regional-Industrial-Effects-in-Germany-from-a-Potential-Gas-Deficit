# Turn off any existing R graphical devices and clear the workspace
graphics.off()
rm(list = ls())

# Define versions or scenarios for the analysis
lversions = c("BL", "DE")

# Load external R script containing functions for IO analysis
source("Functions/functionsioanalysis.r")

# Flag to specify whether the initial shock size for gas use is specific
linitgas <- FALSE

# Processing for one version/scenario at a time
sversionIO = lversions[1]

# Load value-added shares and elasticity data from specific Excel sheets
vashares = read.xlsx(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "VA")
elasticity = read.xlsx(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "Elasticity")

# Conditional loading of gas shares data based on scenario and flag
gasshares = read_excel(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "EGAnteile")

# Read the gas shortage profile
gasshortage = read_excel("Output/ExcelFiles/GasShortageProfile.xlsx", sheet = "Data")

# Read actual data for comparison
dfactual <- read_excel("Data/Destatis/CompareActualPredicted.xlsx", sheet = 1)

# Load the input-output table for the specified scenario
sfileio <- paste0("Data/InputOutputTables/", sversionIO, "IO.xlsx")
ioinput = read.xlsx(sfileio, sheet = "RegionalIO", rowNames = TRUE)
x_vec <- rowSums(ioinput)
# Exclude 'ROW' and 'consumption' columns from the analysis
ioinput = ioinput[,!grepl("ROW", colnames(ioinput))]
ioinput = ioinput[,!grepl("consumption", colnames(ioinput))]
x_vec <- x_vec[colnames(ioinput)]

# Extract unique sector identifiers for further analysis
ivecsec = unique(substr(rownames(ioinput),
                        unlist(lapply(rownames(ioinput),
                                      function(x){gregexpr("_",x)}))+1,
                        nchar(rownames(ioinput))))

# Prepare matrices for regional and imported inputs
zreg_mat <- ioinput[names(x_vec), names(x_vec)]
zimp_mat <- matrix(NaN, nrow = length(ivecsec), ncol = ncol(zreg_mat))
rownames(zimp_mat) <- ivecsec
colnames(zimp_mat) <- rownames(ioinput)[!grepl("ROW", rownames(ioinput))]

# Populate the imported input matrix based on sector and region
lsec <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][2]}))
lreg <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][1]}))
for(icosec in ivecsec){
  lsel <- lsec == icosec & lreg == "ROW"
  zimp_mat[as.numeric(icosec),] = colSums(ioinput[lsel,colnames(zimp_mat)])
}

# Initialize matrices for differential analysis and other variables
zimp_diff <- zimp_mat
zimp_diff[] <- 0
x_diff <- x_vec
y_init <- vashares$VA_Share
x_diff[] <- 0

# Compute input and output coefficient matrices
a_mat <- compiocoeff(zreg_mat, zimp_mat, x_vec)$a_mat
b_mat <- compiocoeff(zreg_mat, zimp_mat, x_vec)$b_mat

# Calculate new output vector after applying effects
x_new <- computelink(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff, y_init)
adom_mat <- a_mat - zimp_mat / matrix(x_vec, nrow = nrow(zimp_mat), ncol = ncol(zimp_mat), byrow = TRUE)

# Define the number of rounds for analysis
inbround <- 5

# Handle missing values in actual data
dfactual$change[is.na(dfactual$change)] = 0

# Apply shock based on actual data changes
ishock <- dfactual$change
x_diff[gsub("_0","_", gasshares$Sector)] <- ishock / 100 * x_vec[gsub("_0","_", gasshares$Sector)]
zimp_diff[2,] <- a_mat[2,] * x_diff[gsub("_0","_", gasshares$Sector)]
if(any(ishock > 0)){
  zimp_diff[,ishock > 0] <- a_mat[,ishock > 0] * x_diff[ishock > 0]  
  x_vec0 <- x_vec
  x_vec[ishock > 0] <- x_vec0[ishock > 0] * (1 + ishock[ishock > 0] / 100)
}

# Reset difference vector
x_diff[] <- 0

# Initialize a result list
lres <- NULL

# Compute and store results for each round
for(iround in 1:2){
  restemp <- computelink(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff, y_init)
  x_new <- restemp$xnew
  x_diff <- elasticity$Elasticity * (x_new - x_vec0)
  x_diff[x_diff < -x_vec] <- -x_vec[x_diff < -x_vec]
  lres[[paste0(iround)]] <- x_diff
  lres[[paste0("int", iround)]] <- restemp$zdiff / rowSums(zimp_mat)
}

# Update actual data with predicted impact changes
dfactual <- read_excel("Data/Destatis/CompareActualPredicted.xlsx", 1)
dfactual$impchpred <- lres[["int2"]] * 100

# Save updated actual data with predictions
write.xlsx(dfactual, "Output/ExcelFiles/CompareActualPredicted.xlsx", overwrite = TRUE)
