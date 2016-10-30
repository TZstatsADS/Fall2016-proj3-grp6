#############################################################
### Construct visual features for training/testing images ###
#############################################################

### Author: Yuting Ma
### Project 3
### ADS Spring 2016

feature <- function(img_dir, img_name, data_name=NULL){
  
  ### Construct process features for training/testing images
  ### Sample simple feature: Extract raw pixel values os features
  
  ### Input: a directory that contains images ready for processing
  ### Output: an .RData file contains processed features for the images
  
  ### load libraries
  library("EBImage")
  
  n_files <- length(list.files(img_dir))
  
  ### determine img dimensions
  img0 <-  readImage(paste0(img_dir, img_name, "_", 1, ".jpg"))
  mat1 <- as.matrix(img0)
  n_r <- nrow(img0)
  n_c <- ncol(img0)
  
  ### store vectorized pixel values of images
  # Each row represents an image. Tutorial: Total 1289 images in training set
  # Each column represents a pixel of the image. Tutorial: Total 256 pixels
  
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

feature_base <- function(filename){
  library(readr)
  data <- read_csv(paste0("./data/", filename))

    # Columns are images. Rows are SIFT features. Got to transpose.
  data <- t(data)
  return(data)
}

feature_RGB <- function(img_dir, data_name){
  
  library(EBImage)
  library(mixtools)
  
  list.of.images <- list.files(img_dir)
  n_files <- length(list.of.images)

  dat <- array(dim=c(n_files, 12), dimnames = NULL) 

#  for(i in 1:n_files){
  for(i in 1:n_files){
    img.name <- list.of.images[i]
    image.path <- paste0(img_dir, img.name)
    img <- readImage(image.path)
#    cat("i=", i, ", Image: ", image.path, "\n")
    
    height <- nrow(img)
    width <-  ncol(img) 

#    cat("Original:",width, ", ", height, "\n" )

    if(width > height){
      img <- resize(x = img, h = 128)    
    } else{
      img <- resize(x = img, w = 128)    
    }

    height <- nrow(img)
    width <-  ncol(img) 
    
#    cat("Resized:",width, ", ", height, "\n" )
    
    red.channel <- as.vector(as.array(img[,,1]))
    red.channel <- red.channel[red.channel <= 0.95]
    green.channel <- as.vector(as.array(img[,,2]))
    green.channel <- green.channel[green.channel <= 0.95]
    blue.channel <- as.vector(as.array(img[,,3]))
    blue.channel <- blue.channel[blue.channel <= 0.95]
    
    
    tryCatch({
    
    fitted.dist.mix.r <- normalmixEM2comp(red.channel, mu = c(0.25, 0.75), lambda = 0.2, sigsqrd = c(1,0.5),
                                                   maxit = 100, verb = FALSE)
    
    fitted.dist.mix.g <- normalmixEM2comp(green.channel, mu = c(0.25, 0.75), lambda = 0.2, sigsqrd = c(1,0.5),
                                          maxit = 100, verb = FALSE)
    
    fitted.dist.mix.b <- normalmixEM2comp(blue.channel, mu = c(0.25, 0.75), lambda = 0.2, sigsqrd = c(1,0.5),
                                          maxit = 100, verb = FALSE)
    
    dat[i,1] <- fitted.dist.mix.r$mu[1]
    dat[i,2] <- fitted.dist.mix.r$mu[2]
    dat[i,3] <- fitted.dist.mix.g$mu[1]
    dat[i,4] <- fitted.dist.mix.g$mu[2]
    dat[i,5] <- fitted.dist.mix.b$mu[1]
    dat[i,6] <- fitted.dist.mix.b$mu[2]
    dat[i,7] <- fitted.dist.mix.r$sigma[1]
    dat[i,8] <- fitted.dist.mix.r$sigma[2]
    dat[i,9] <- fitted.dist.mix.g$sigma[1]
    dat[i,10] <- fitted.dist.mix.g$sigma[2]
    dat[i,11] <- fitted.dist.mix.b$sigma[1]
    dat[i,12] <- fitted.dist.mix.b$sigma[2]
    
    }, 
    warning = function(w){
      return(NULL)
    },
    error = function(e){
      return(NULL)
    },
    finally = {}
    )
    
    cat(img.name, " value: ", dat[i,], "\n")
  }
  
  ### output constructed features
  if(!is.null(data_name)){
    save(dat, file=paste0("./output/feature_", data_name, ".RData"))
  }
  return(dat)
}

feature.JG <- function(filename){
  library(readr)
  data <- read_csv(paste0("./data/", filename))
  data <- t(data)
  return(data)
}


