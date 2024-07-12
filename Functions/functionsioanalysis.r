    # # Example Call
    # # 
    # copdat <- read.delim("clipboard")
    # lreg <- c("West", "East")
    # lsec <- c("Primary", "Secondary", "Tertiary")
    # copdat[c(1:6), c(2:4, 6:8)]
    # # domestic intermediate consumption matrix
    # zreg_mat <- matrix(c(2339.9649,  22928.098, 1.926524e+03,  161.2850,  1135.267,    112.9259,
    #                    5173.9325, 216470.880, 1.784623e+05,  456.2784, 12549.204,  11615.1747,
    #                    13631.1822, 301715.446, 1.291929e+06, 1095.1726, 12704.654,  41851.9559,
    #                    110.3514,   1053.156, 9.995147e+01,  544.9799,  4559.537,    414.2788,
    #                    245.1924,  10820.929, 9.563398e+03,  902.1523, 22788.801,  20500.4851,
    #                    711.5970,  12261.773, 3.916754e+04, 2075.8968, 31688.029, 170449.9429),
    #                    nrow = 6,
    #                    ncol = length(lsec)*length(lreg))
    # 
    # 
    #  rownames(zreg_mat) <- paste0(lreg[sort(rep(1:length(lreg), length(lsec)))],"_", lsec[(rep(1:length(lsec), length(lreg)))])
    #  colnames(zreg_mat) <- paste0(lreg[sort(rep(1:length(lreg), length(lsec)))],"_", lsec[(rep(1:length(lsec), length(lreg)))])
    # # imported intermediate consumption matrix
    #  copdat[c(7:9), c(2:4, 6:8)]
    #  zimp_mat <- matrix(c(1023.400, 11124.36, 968.5767, 325.5915, 2068.466, 274.4976,
    #                       3638.535, 254209.42, 137491.6598, 684.0693, 27426.609, 17199.4096,
    #                       1497.103,  56335.06, 151895.3610, 274.3174,  9756.053, 25224.5007),
    #                       nrow = length(lsec),
    #                       ncol = length(lsec)*length(lreg), byrow = TRUE)
    #  rownames(zimp_mat) <- c("Primary", "Secondary", "Tertiary")
    #  colnames(zimp_mat) <- paste0(lreg[sort(rep(1:length(lreg), length(lsec)))],"_", lsec[(rep(1:length(lsec), length(lreg)))])
    #  zimp_diff <- zimp_mat
    #  zimp_diff[] <- 0
    # # output vector
    #  rowSums(copdat[,-1])
    #   x_vec <- matrix(c(47614.08,
    #                     1386642.76,
    #                     4044092.66,
    #                     10941.80,
    #                     187378.69,
    #                     676256.98), nrow = length(lreg)*length(lsec), ncol = 1, byrow = TRUE)
    # rownames(x_vec) <- paste0(lreg[sort(rep(1:length(lreg), length(lsec)))],"_", lsec[(rep(1:length(lsec), length(lreg)))])
    # # change in output vector to compute reduction
    # x_diff <- x_vec
    # x_diff[] <- 0
    # a_mat <- compiocoeff(zreg_mat, zimp_mat, x_vec)$a_mat
    # x_diff["West_Secondary",] <- -100
    # print(computelink(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff)$xnew-x_vec)
    # zimp_diff["Secondary", "West_Secondary"] <- a_mat["Secondary", "West_Secondary"] * x_diff["West_Secondary",]
    # x_diff[] <- 0
    # print(computelink(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff)$xnew-x_vec)
    # x_diff <- computelink(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff)$xnew-x_vec
    # x_diff
    # print((sum(x_diff)/sum(x_vec))/(-100/x_vec["East_Secondary",]))
compiocoeff <- function(zreg_mat, zimp_mat, x_vec) {
    # input to compiocoeff
    # zreg_mat: regional domestic intermediate consumption matrix
    # zimp_mat: imported intermediate consumption matrix
    # x_vec: output vector
    # output from computelink
    # a_mat: input coefficients forward linkages
    # b_mat: output coeffcients

    # create output matrix from vector
    x_mat <- t(matrix(x_vec, nrow = nrow(zreg_mat),
                  ncol = ncol(zreg_mat), byrow = TRUE))
    # output coefficient matrix
    b_mat <- zreg_mat / x_mat
    # compute sector specific domestic inputs
    zdom_mat <- zimp_mat
    lsec <- unlist(lapply(rownames(zreg_mat) , function(x){strsplit(x, "_")[[1]][2]}))
    for(srow in rownames(zdom_mat)){
      lselrows <- lsec == srow
      zdom_mat[srow, ] <- colSums(zreg_mat[lselrows, ])
    }    
    # create output matrix from vector
    x_mat <- matrix(x_vec, nrow = nrow(zdom_mat),
                    ncol = ncol(zdom_mat), byrow = TRUE)

    # input coefficient matrix
    a_mat <- (zdom_mat + zimp_mat) / x_mat
    # output
    lresult <- list(
            "a_mat" = a_mat,
            "b_mat" = b_mat
            )
    return(lresult)
}


computelink <- function(zreg_mat, zimp_mat, zimp_diff, x_vec, x_diff, y_init) {
    # input to computelink
    # zreg_mat: regional intermediate consumption matrix    
    # zimp_mat: imported intermediate consumption matrix
    # zimp_diff: change in imported intermediate consumption matrix
    # x_vec: output vector
    # x_diff: change in output vector to compute reduction
    # y_init: value added vector
    # output from computelink
    # x_new: new output vector

    # output coefficient matrix
    b_mat <- compiocoeff(zreg_mat, zimp_mat, x_vec)$b_mat
    # input coefficient matrix
    a_mat <- compiocoeff(zreg_mat, zimp_mat, x_vec)$a_mat

    # total final use
    x_mat <- matrix(x_vec, nrow = nrow(a_mat),
                           ncol = ncol(a_mat), byrow = TRUE)
    x_impact_mat <- matrix(x_vec+x_diff, nrow = ncol(zreg_mat),
                    ncol = nrow(zreg_mat), byrow = TRUE)
    
    zreg_imp <- b_mat * t(x_impact_mat)
    zdifa_mat <- a_mat * matrix(t(x_diff), nrow(a_mat),ncol(a_mat), byrow = TRUE)#*zimp_mat/(a_mat*x_mat)
    zdom_mat <- zimp_mat
    zdif_mat <- zimp_mat
    lsec <- unlist(lapply(rownames(zreg_imp) , function(x){strsplit(x, "_")[[1]][2]}))
    for(srow in rownames(zdom_mat)){
      lselrows <- lsec == srow
      zdom_mat[srow, ] <- colSums(zreg_imp[lselrows, ], na.rm = TRUE)
      zdif_mat[srow, ] <- colSums(zreg_mat[lselrows, ]-zreg_imp[lselrows, ], na.rm = TRUE)
    }
    # total final use
    zimpact_mat <- apply(zimp_mat + zimp_diff + zdom_mat,
                        1:2,
                        function(x){max(x, 0, na.rm =TRUE)})
    # compute inverse of input coefficient matrix
    ainv_mat <- a_mat^(-1)
    # compute output matrix
    x_imp_mat <- apply(rbind(t(x_impact_mat[1,]),
                       ainv_mat * (zimpact_mat)), 2,
                       function(x){
                        min(x, na.rm = TRUE)
                        })
    lresult <- list(
            "xnew" = x_imp_mat,
            "zdiff" = rowSums(zdif_mat+zdifa_mat,na.rm = TRUE),
            "zdifb_mat" = zdif_mat,
            "zdifa_mat" = zdifa_mat
            )
    return(lresult)
}

#   x_new <-  computelink(zdom_mat, zimp_mat, zimp_diff, x_vec, x_diff)$FLPF
#   for(icoiter in 1:10){
#       x_new <-  computelink(zdom_mat, zimp_mat, zimp_diff, x_vec, x_new-x_vec)$FLPF
#       print(sum(abs(x_new-x_vec)))
#   }