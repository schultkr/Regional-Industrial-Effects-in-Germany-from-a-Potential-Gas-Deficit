# IO computation of First-, Second-, Third-, Fourth Round Effects
graphics.off()
rm(list = ls())
lversions = c("BL", "DE")
# get function to compute effects
source("Functions/functionsioanalysis.r")

gasshortage = read_excel("Output/ExcelFiles/GasShortageProfile.xlsx", sheet = "Data")
vashares = read.xlsx(paste0("Data/InputOutputTables/InputBL.xlsx"), sheet = "VA")
vasharesde = read.xlsx(paste0("Data/InputOutputTables/InputDE.xlsx"), sheet = "VA")
mapBLabbr <- read.xlsx("Data/Correspondence.xlsx", sheet = "BL")
mapSecabbr <- read.xlsx("Data/Correspondence.xlsx", sheet = "SectorNames")

sfileio <- paste0("Data/InputOutputTables/BLIO.xlsx")
ioinput <-  read.xlsx(sfileio, sheet = "RegionalIO", rowNames = TRUE)
finaldemand <- rowSums(ioinput[,grepl("consumption", colnames(ioinput))])
ioinput <- ioinput[,!grepl("ROW", colnames(ioinput))]
ioinput <- ioinput[,!grepl("consumption", colnames(ioinput))]



ivecsec = unique(substr(rownames(ioinput),
                        unlist(lapply(rownames(ioinput),
                                      function(x){gregexpr("_",x)}))+1,
                        nchar(rownames(ioinput))))

# get output vector 
x_vec <- rowSums(ioinput)
x_vec <- x_vec[colnames(ioinput)]

lressum <- NULL
lressum$BL$int2interval
for(sversionIO in lversions){
  sfileres <- paste0("Output/RDS/Results", sversionIO, ".rds")
  lressum[[sversionIO]] <- readRDS(sfileres)
}
x_vecde <- matrix(NaN, nrow = length(ivecsec), ncol = 1)
rownames(x_vecde) <- ivecsec
for(isec in ivecsec){
  x_vecde[isec,] <- sum(x_vec[substr(names(x_vec),4,5) == isec])
}

# ============================
# create state specific losses
# ============================
dfdisplay <- data.frame(matrix(0, ncol = 3, nrow = 17*5))
colnames(dfdisplay) <-  c("BL", "Round", "Values")
dfdisplay$BL <- mapBLabbr$Abbr[rep(1:17,5)]
dfdisplay$BL[is.na(dfdisplay$BL)] = "DE"
dfdisplay$Round <- sort(rep(1:5,17))
lmonths <- paste0(gasshortage$Jahr, "-", gasshortage$Monat)[gasshortage$GasShort<0]
for(smonth in lmonths){
  # get data to display for each month additional demand for intermediate goods
  dfdisp <- data.frame(sector = as.factor(mapSecabbr[["GD-Descr"]]),
                      month = (lressum[["BL"]][[paste0("int2")]][,smonth])*100)
  write.xlsx(dfdisp, paste0("Output/ExcelFiles/ResultsIntermediatesBottomUpMonth", smonth, ".xlsx"))
  # get data to display for each month additional demand for intermediate goods
  dfdisp <- data.frame(sector = as.factor(mapSecabbr[["GD-Descr"]]),
                      month = (lressum[["DE"]][[paste0("int2")]][,smonth])*100)
  write.xlsx(dfdisp, paste0("Output/ExcelFiles/ResultsIntermediatesTopDownMonth", smonth, ".xlsx"))
}

for(icoint in 1:10){
  # get data to display for each month additional demand for intermediate goods
  dfdisp <- data.frame(sector = as.factor(mapSecabbr[["GD-Descr"]]),
                      month = (lressum[["BL"]][[paste0("int2interval")]][,icoint])*100)
  write.xlsx(dfdisp, paste0("Output/ExcelFiles/ResultsIntermediatesBottomUpInterval", icoint, ".xlsx"))
  # get data to display for each month additional demand for intermediate goods
  dfdisp <- data.frame(sector = as.factor(mapSecabbr[["GD-Descr"]]),
                      month = (lressum[["DE"]][[paste0("int2interval")]][,icoint])*100)
  write.xlsx(dfdisp, paste0("Output/ExcelFiles/ResultsIntermediatesTopDownInterval", icoint, ".xlsx"))
}