# IO computation of First-, Second-, Third-, Fourth Round Effects
graphics.off()
rm(list = ls())
lversions = c("BL", "DE")

# get function to compute effects
source("Functions/functionsioanalysis.r")

sfileio <- "Data/InputOutputTables/EastWestIODE.xlsx"
ioinput =  read.xlsx(sfileio, sheet = "RegionalIO", rowNames = TRUE)
x_vec <- rowSums(ioinput)
ioinput = ioinput[,!grepl("ROW", colnames(ioinput))]
ioinput = ioinput[,!grepl("consumption", colnames(ioinput))]

ivecsec = unique(substr(rownames(ioinput),
                        unlist(lapply(rownames(ioinput),
                                      function(x){gregexpr("_",x)}))+1,
                        nchar(rownames(ioinput))))
  
# get output vector 
x_vec <- x_vec[colnames(ioinput)]
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
y_init <- x_vec
x_diff[] <- 0
a_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$a_mat
b_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$b_mat
x_new <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)

x_diff["West_2"] = -100
x_diff["East_2"] = -100
zdiff_mat["2","West_2"] <- x_diff["West_2"] * a_mat["2", "West_2"]
zdiff_mat["2","East_2"] <- x_diff["East_2"] * a_mat["2", "East_2"]
x_diff[] <- 0
x_new <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)$xnew
x_diff <- x_new-x_vec


x_new <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)$xnew
x_diff <- x_new-x_vec


sfileio <- "Data/InputOutputTables/IODEAppendix.xlsx"
ioinput =  read.xlsx(sfileio, sheet = "IODEAppendix", rowNames = TRUE)
ioinput = ioinput[,!grepl("O", colnames(ioinput))]
x_vec <- rowSums(ioinput)
ioinput = ioinput[,!grepl("R", colnames(ioinput))]
ioinput = ioinput[,!grepl("FD", colnames(ioinput))]

ivecsec = unique(substr(rownames(ioinput),
                        unlist(lapply(rownames(ioinput),
                                      function(x){gregexpr("_",x)}))+1,
                        nchar(rownames(ioinput))))
  
# get output vector 
x_vec <- x_vec[colnames(ioinput)]
zreg_mat <- ioinput[names(x_vec), names(x_vec)]
zimp_mat <- matrix(NaN, nrow = length(ivecsec), ncol = ncol(zreg_mat))
rownames(zimp_mat) <- ivecsec
colnames(zimp_mat) <- rownames(ioinput)[!grepl("R", rownames(ioinput))]
lsec <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][2]}))
lreg <- unlist(lapply(rownames(ioinput), function(x){strsplit(x, "_")[[1]][1]}))
for(icosec in ivecsec){
  lsel <- lsec  == icosec & lreg == "R"
  zimp_mat[as.numeric(icosec),]  = colSums(ioinput[lsel,colnames(zimp_mat)])
}
zdiff_mat <- zimp_mat
zdiff_mat[] <- 0
x_diff <- x_vec
y_init <- x_vec
x_diff[] <- 0
a_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$a_mat
b_mat <- compiocoeff(zreg_mat, zimp_mat,x_vec)$b_mat
x_new <- computelink(zreg_mat,zimp_mat,zdiff_mat,x_vec,x_diff,y_init)