# -*- coding: utf-8 -*-
"""
Created on Sat Oct 29 14:05:18 2016

@author: Andy
"""
from sklearn.cluster import KMeans
import csv,cv2
import os
import matplotlib.pyplot as plt


def most_powerful(kps,descs,size):
    responses = [i.response for i in kps]
    responses.sort(reverse = True)
    kept = responses[:size]
    resultkps = []
    resultdescs = []
    for i,j in zip(kps,descs):
        if i.response in kept:
            resultkps.append(i)
            resultdescs.append(j)
    return resultkps,resultdescs
               
    
def process_image(file):
    img = cv2.imread(file)
    gray= cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    
    sift = cv2.xfeatures2d.SIFT_create()
    kp = sift.detect(gray,None)
    img=cv2.drawKeypoints(gray,kp,cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
    (kps,descs) = sift.detectAndCompute(gray,None)
    print('keypoints: {number} and shape: {shape}'.format(number=len(kps),shape=descs.shape))
    return kps,descs

def get_imgdata(filelist,size):
    largerresult = []
    for i in filelist:
        kps,descs = process_image(i)
        adkps,addescs = most_powerful(kps,descs,size)
        for j in addescs:
            largerresult.append(j)
    return largerresult

def write_down(alldata,filelist,ncluster,desc):
    kmeans = KMeans(n_clusters=ncluster, random_state=0).fit(alldata)
    fDict = {}
    imgDict = {}
    for i in range(0,ncluster,1):
        fDict[i] = 0
    for indexI in filelist:
        imgDict[indexI] = []
    for img in filelist:
        kps,descs = process_image(img)
        labels = kmeans.predict(descs)
        for clus in labels:
            fDict[clus] += 1
        sums = sum(fDict.values())
        for i in imgDict.keys():
            fDict[i] = imgDict[i]/sums
        imgDict[img] = [ imgDict[i] for i in range(0,ncluster,1) ]
    with open(desc,'w') as f:
        csvwriter = csv.writer(f)
        for i in filelist:
            csvwriter.writerow([i]+imgDict[i])
        f.close()
    
def main():
    where = str(input('The image location: like /users/andy/desktop/Project3_poodleKFC_train/images :\n'))
    os.chdir(where)
    imgslist =os.listdir()
    imgslist.pop(0)
    size = int(input('How many to extract from each picture? i.e. 50 :\n'))
    alldata = get_imgdata(imgslist,size)
    ncluster = int(input('What size for your codebook? i.e. 5000 : \n'))
    desc = str(input('Where do you want to store csv? i.e. /users/andy/desktop/ss.csv :\n'))
    write_down(alldata,imgslist,ncluster,desc)
    
if __name__ == '__main__':
    main()
    
    
