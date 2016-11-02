##################################################################
#                        Feature.R                               #
#                   Feature extraction                           #
##################################################################
# Team 6
# Fall 2016 ADS

feature <- function(img_dir, img_name, sift_csv, data_name=null) {
        # required libraries
        require(EBImage)
        require(data.table)
        require(grDevices)
        
        n_files=length(list.files(img_dir))/length(img_name);n_files
        
        
        nR=10
        nG=10
        nB=10
        ### store vectorized pixel values of images
        dat <- array(dim=c(length(list.files(img_dir)), nR*nG*nB)) 
        
        for(j in 1:length(img_name)){
                for(i in 1:n_files){
                        cat(paste0(sprintf("%s%s_%04d.jpg",img_dir,img_name[j],i),"\n"))
                        img=readImage(sprintf("%s%s_%04d.jpg",img_dir,img_name[j],i)) # read image
                        
                        
                        # Resizing images
                        height <- nrow(img)
                        width <-  ncol(img) 
                        
                        if(width > height){
                          img <- resize(x = img, h = 200)    
                        } else{
                          img <- resize(x = img, w = 200)    
                        }
                        
                        mat <- imageData(img)
                        
                        
                        # Caution: the bins should be consistent across all images!
                        rBin <- seq(0, 1, length.out=nR)
                        gBin <- seq(0, 1, length.out=nG)
                        bBin <- seq(0, 1, length.out=nB)
                        freq_rgb <- as.data.frame(table(factor(findInterval(mat[,,1], rBin), levels=1:nR), 
                                                        factor(findInterval(mat[,,2], gBin), levels=1:nG), 
                                                        factor(findInterval(mat[,,3], bBin), levels=1:nB)))
                        rgb_feature <- as.numeric(freq_rgb$Freq)/(ncol(mat)*nrow(mat)) # normalization
                        q= i + n_files*(j-1) #index to store vectors
                        dat[q,]=rgb_feature
                }}
        sift <- read.csv(sift_csv)
        sift <- t(sift)
        sift <- as.data.frame(sift)
        dat <- cbind(sift, dat)
        
        dat <- dat[,which(colSums(dat)!=0)]
        
        ### output constructed features
        if(!is.null(data_name)){
                save(dat, file=paste0("./output/feature_eval", data_name, ".RData"))
        }
        return(dat)
}