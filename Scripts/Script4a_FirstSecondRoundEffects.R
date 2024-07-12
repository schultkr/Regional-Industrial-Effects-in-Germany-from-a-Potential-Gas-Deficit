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
x_vec <- rowSums(ioinput) + finaldemand
x_vec <- x_vec[colnames(ioinput)]

lressum <- NULL
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
ldisp <- NULL
dfdisplayBU <- dfdisplay
dfdisplayBUid <- dfdisplay
dfdisplayTD <- dfdisplay
dfdisplayBUYear <- dfdisplay
dfdisplayBUidYear <- dfdisplay
dfdisplayTDYear <- dfdisplay
for(smonth in lmonths){
  dfdisplayTD[dfdisplayTD$BL =="DE","Values"] = 0
  dfdisplayBU[dfdisplayBU$BL =="DE","Values"] = 0
  for(iround in 1:2){
    for(sbl in unique(dfdisplayBU$BL)[1:16]){
      # bottom up
      sblid <- mapBLabbr$STATE[mapBLabbr$Abbr== sbl]
      restemp <- lressum[["BL"]][[paste0(iround)]]
      lsel <- substr(rownames(restemp),1,2) == sblid
      lselx <- substr(names(x_vec),1,2) == sblid
      lselrow <- dfdisplayBU$BL == sbl & dfdisplayBU$Round ==iround
      lselrowDE <- dfdisplayBU$BL == "DE" & dfdisplayBU$Round ==iround
      vablreg <- sum(vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid])
      vabl_sec <- vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid] / sum(vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid])
      dfdisplayBU[lselrow,"Values"] <- sum(vabl_sec * restemp[lsel,smonth]/x_vec[lselx], na.rm = TRUE)*100
      dfdisplayBU[lselrowDE,"Values"] <- dfdisplayBU[lselrowDE,"Values"] + vablreg * dfdisplayBU[lselrow,"Values"]
      # topdown 
      restemp <- lressum[["DE"]][[paste0(iround)]]
      dfdisplayTD[lselrow,"Values"] <- sum(vabl_sec* restemp[,smonth]/x_vecde, na.rm = TRUE )*100
      dfdisplayTD[lselrowDE,"Values"] <- dfdisplayTD[lselrowDE,"Values"] + vablreg * dfdisplayTD[lselrow,"Values"]
    }
  }
  ldisp[[paste0(smonth, "BU")]] <- dfdisplayBU
  ldisp[[paste0(smonth, "TD")]] <- dfdisplayTD

  dfdisplayBUYear$Values <- dfdisplayBUYear$Values + 1/12 * dfdisplayBU$Values
  dfdisplayTDYear$Values <- dfdisplayTDYear$Values + 1/12 * dfdisplayTD$Values
  
}
gasshortage$GasShortInd <- gasshortage$GasShort/gasshortage$GasInd * 100
gasshortage$Monat <- gasshortage$Monat

write.xlsx(dfdisplayTDYear,"Output/ExcelFiles/ResultsTopDownYear.xlsx")
write.xlsx(dfdisplayBUYear,"Output/ExcelFiles/ResultsBottomUpYear.xlsx")
# ============================
# create state specific losses for intervals
# ============================
lintervals <- colnames(lressum$BL$`1interval`)
dfdisplay <- data.frame(matrix(0, ncol = 4, nrow = 16*5*length(lintervals)))
colnames(dfdisplay) <-  c("BL", "Round", "Interval", "Values")
dfdisplay$BL <- mapBLabbr$Abbr[rep(rep(1:16,5), 10)]
dfdisplay$BL[is.na(dfdisplay$BL)] = "DE"
dfdisplay$Round <- rep(sort(rep(1:5,16)), 10)
dfdisplay$Interval <- sort(rep(1:10,5*16))
ldisp <- NULL
dfdisplayBU <- dfdisplay
dfdisplayTD <- dfdisplay
for(sint in lintervals){
  for(iround in 1:2){
    for(sbl in unique(dfdisplayBU$BL)[1:16]){
      # bottom up
      sblid <- mapBLabbr$STATE[mapBLabbr$Abbr== sbl]
      restemp <- lressum[["BL"]][[paste0(iround,"interval")]]
      lsel <- substr(rownames(restemp),1,2) == sblid
      lselx <- substr(names(x_vec),1,2) == sblid
      lselrow <- dfdisplayBU$BL == sbl & dfdisplayBU$Round ==iround & dfdisplayBU$Interval == as.numeric(sint)
      vablreg <- sum(vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid])
      vabl_sec <- vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid] / sum(vashares$VA_Share[substr(vashares$IO_Sector,1,2) == sblid])
      dfdisplayBU[lselrow,"Values"] <- vablreg * sum(vabl_sec * restemp[lsel,sint]/x_vec[lselx], na.rm = TRUE) * 100
      # topdown 
      restemp <- lressum[["DE"]][[paste0(iround,"interval")]]
      dfdisplayTD[lselrow,"Values"] <- vablreg * sum(vabl_sec* restemp[,sint]/x_vecde, na.rm = TRUE )*100
    }
  }
}
dfdisplay <- dfdisplayBU[dfdisplayBU$Round<=2,]
dfdisplay$Round <- as.factor(dfdisplay$Round)
dfdisplay$BL = mapBLabbr$`STATE-Descr`[match(dfdisplay$BL,mapBLabbr$Abbr)]
dfdisplay$BL[is.na(dfdisplay$BL)] ="Deutschland"
dfdisplay$Interval <- dfdisplay$Interval/10*100
dfdisplay$Interval <- factor(dfdisplay$Interval, levels = unique(dfdisplay$Interval))

dfdisplay$BL <- factor(dfdisplay$BL, levels = unique(dfdisplay$BL))
write.xlsx(dfdisplayTD,"Output/ExcelFiles/ResultsTopDownInterval.xlsx")
write.xlsx(dfdisplayBU,"Output/ExcelFiles/ResultsBottomUpInterval.xlsx")