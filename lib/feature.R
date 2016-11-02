#############################################################
### Construct visual features for training/testing images ###
#############################################################

### Author: Chenxi Huang
### Project 3
### ADS Fall 2016

### load libraries
library(EBImage)
library(data.table) # for fread


feature <- function(img_dir, img_name, data_name=NULL){
  
  ### Construct process features for training/testing images
  ### Sample simple feature: Extract raw pixel values of features
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images

  
  n_files <- length(list.files(img_dir))
  
  ### determine img dimensions
  img0 <-  readImage(paste0(img_dir, img_name, "_", 1, ".jpg"))
  mat1 <- as.matrix(img0)
  n_r <- nrow(img0)
  n_c <- ncol(img0)
  
  ### store vectorized pixel values of images
  dat <- array(dim=c(n_files, n_r*n_c)) 
  for(i in 1:n_files){
    img <- readImage(paste0(img_dir, img_name, "_", i, ".jpg"))
    dat[i,] <- as.vector(img)
  }
  
  ### output constructed features
  if(!is.null(data_name)){
    save(dat, file=paste0("./output/feature_", data_name, ".RData"))
  }
  return(dat)
}
##########################################################################
# store 'sift_features'in 'output' folder
feature_base <- function(filename){
  data <- fread(paste0("./output/", filename)) # dim(data)=5000 by 2000
  data <- t(data)
  return(data)
}
##########################################################################
feature_RGB <- function(img_dir, img_name, data_name=NULL){
  
  ### Construct process features for training/testing images
  ### Sample simple feature: Extract raw pixel values of features
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  
  n_files <- length(list.files(img_dir))
  nR <- 5
  nG <- 5
  nB <- 5
 
  ### store vectorized pixel values of images
  dat <- array(dim=c(n_files, nR*nG*nB)) 
  for(i in 1:n_files){
    for(j in length(img_name)){
    img=readImage(sprintf("%s%s_%04d.jpg",img_dir,img_name[j],i)) # read image
    mat <- imageData(img)
    
   
    # Caution: the bins should be consistent across all images!
    rBin <- seq(0, 1, length.out=nR)
    gBin <- seq(0, 1, length.out=nG)
    bBin <- seq(0, 1, length.out=nB)
    freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), 
                                    factor(findInterval(mat[,,2], gBin), levels=1:nG), 
                                    factor(findInterval(mat[,,3], bBin), levels=1:nB)))
    rgb_feature <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
    dat[i,]=rgb_feature
  }}
  
  ### output constructed features
  if(!is.null(data_name)){
    save(dat, file=paste0("./output/feature_", data_name, ".RData"))
  }
  return(dat)
}

