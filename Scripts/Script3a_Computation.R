# IO computation of First-, Second-, Third-, Fourth Round Effects
graphics.off()
rm(list = ls())
lversions = c("BL", "DE")

# get function to compute effects
source("Functions/functionsioanalysis.r")
# initial shock size gas use specific
linitgas <- FALSE
for(sversionIO in lversions){
  vashares = read.xlsx(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "VA")
  elasticity = read.xlsx(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "Elasticity")
  gasshares = read_excel(paste0("Data/InputOutputTables/Input", sversionIO, ".xlsx"), sheet = "EGAnteile")

  gasshortage = read_excel("Output/ExcelFiles/GasShortageProfile.xlsx", sheet = "Data")

  sfileio <- paste0("Data/InputOutputTables/", sversionIO, "IO.xlsx")
  ioinput =  read.xlsx(sfileio, sheet = "RegionalIO", rowNames = TRUE)
  x_vec <- rowSums(ioinput)
  ioinput = ioinput[,!grepl("ROW", colnames(ioinput))]
  ioinput = ioinput[,!grepl("consumption", colnames(ioinput))]
  x_vec <- x_vec[colnames(ioinput)]
  ivecsec = unique(substr(rownames(ioinput),
                          unlist(lapply(rownames(ioinput),
                                        function(x){gregexpr("_",x)}))+1,
                          nchar(rownames(ioinput))))

  # get output vector
  zreg_mat <- ioinput[names(x_vec), names(x_vec)]
  zimp_mat <- matrix(NaN, nrow = length(ivecsec), ncol = ncol(zreg_mat))
  rownames(zimp_mat) <- ivecsec
  colnames(zimp_mat) <- rownames(ioinput)[!grepl("ROW", rownames(ioinput))]
  lsec <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][2]}))
  lreg <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][1]}))
  for(icosec in ivecsec){
    lsel <- lsec  == icosec & lreg == "ROW"
    zimp_mat[as.numeric(icosec),]  = colSums(ioinput[lsel,colnames(zimp_mat)])
  }
  zdiff_mat <- zimp_mat
  zdiff_mat[] <- 0
  x_diff <- x_vec
  y_init <- vashares$VA_Share
  x_diff[] <- 0
  a_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$a_mat
  b_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$b_mat
  x_new <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)
  adom_mat <-  a_mat  - zimp_mat / matrix(x_vec, nrow = nrow(zimp_mat), ncol = ncol(zimp_mat), byrow = TRUE)
  inbround <- 2
  lres <- NULL
  lres[["Total"]] <- matrix(0,nrow = inbround, ncol = nrow(gasshortage))
  colnames(lres[["Total"]]) <- paste0(gasshortage$Jahr, "-", gasshortage$Monat)
  for(iround in 1:inbround){
    lres[[paste0(iround)]] <- matrix(0,nrow = length(x_vec),ncol = nrow(gasshortage))
    colnames(lres[[paste0(iround)]]) <- paste0(gasshortage$Jahr, "-", gasshortage$Monat)
    rownames(lres[[paste0(iround)]]) <- names(x_vec)
    lres[[paste0("int", iround)]] <- matrix(0,nrow = nrow(a_mat),ncol = nrow(gasshortage))
    colnames(lres[[paste0("int", iround)]]) <- paste0(gasshortage$Jahr, "-", gasshortage$Monat)
    rownames(lres[[paste0("int", iround)]]) <- rownames(a_mat)
  }

  for(imon in 1:nrow(gasshortage)){
    smonth <- paste0(gasshortage$Jahr[imon], "-", gasshortage$Monat[imon])
    x_diff[] <- 0
    ishock <- gasshortage$GasShort[imon]/gasshortage$GasInd[imon]
    if(ishock != 0){
      x_diff[gsub("_0","_", gasshares$Sector)] <- ishock * gasshares$EG_Anteil * x_vec[gsub("_0","_", gasshares$Sector)]
      zdiff_mat[2,] <- a_mat[2,] * x_diff[gsub("_0","_", gasshares$Sector)]
      x_diff[] <- 0
      for(iround in 1:inbround){
        restemp <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)
        x_new <- restemp$xnew
        x_diff <- elasticity$Elasticity * (x_new-x_vec)
        x_diff[x_diff < -x_vec] <- -x_vec[x_diff < -x_vec]
        lres[[paste0(iround)]][,smonth] <- x_diff
        if(iround == 1){
          lres[[paste0("int", iround)]][,smonth] <- 0
        }else{
          lres[[paste0("int", iround)]][,smonth] <- restemp$zdiff/rowSums(zimp_mat)
        }

        lres[["Total"]][iround,smonth] <- sum(x_diff)/sum(x_vec)
      }
    }
  }
  # compute intervals 10, 20, 30, 40, 50, ...
  for(iround in 1:inbround){
    lres[[paste0(iround, "interval")]] <- matrix(0,nrow = length(x_vec),ncol = 10)
    colnames(lres[[paste0(iround, "interval")]]) <- paste0(1:10)
    rownames(lres[[paste0(iround, "interval")]]) <- names(x_vec)
    lres[[paste0("int", iround, "interval")]] <- matrix(0,nrow = nrow(a_mat),ncol = 10)
    colnames(lres[[paste0("int", iround, "interval")]]) <- paste0(1:10)
    rownames(lres[[paste0("int", iround, "interval")]]) <- rownames(a_mat)
  }


  for(iint in 1:10){
    x_diff[] <- 0
    ishock <- iint/10
    if(ishock != 0){
      x_diff[gsub("_0","_", gasshares$Sector)] <- -ishock * gasshares$EG_Anteil * x_vec[gsub("_0","_", gasshares$Sector)]
      zdiff_mat[2,] <- a_mat[2,] * x_diff[gsub("_0","_", gasshares$Sector)]
      x_diff[] <- 0
      for(iround in 1:inbround){
        restemp <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)
        x_new <- restemp$xnew
        x_diff <- elasticity$Elasticity * (x_new-x_vec)
        zdiff<- restemp$zdiff
        x_diff[x_diff < -x_vec] <- -x_vec[x_diff < -x_vec]
        lres[[paste0(iround,"interval")]][,iint] <- x_diff
        lres[[paste0("int", iround,"interval")]][,iint] <- zdiff/rowSums(zimp_mat)
      }
    }
  }

  # save results
  sfileres <- paste0("Output/RDS/Results", sversionIO, ".rds")
  saveRDS(lres, file <- sfileres)
  # save input and output coefficient matrix
  wb <- createWorkbook()
  addWorksheet(wb,"InputCoefficient")
  writeData(wb, "InputCoefficient", a_mat, rowNames = TRUE)
  addWorksheet(wb,"OutputCoefficient")
  writeData(wb, "OutputCoefficient", b_mat, rowNames = TRUE)
  saveWorkbook(wb, paste0("Output/ExcelFiles/InputOutputCoeffiecients", sversionIO,".xlsx"), overwrite = TRUE)

}
