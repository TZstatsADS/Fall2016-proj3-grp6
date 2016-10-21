"""
===================================================
Identifying Labradoodle from fried Chicken
===================================================

Datasets used need to be downloaded from courseworks;
Columbia UID required

"""

from time import time
import logging
import pylab as pl
import numpy as np
from skimage import io
from skimage.transform import resize

from sklearn.cross_validation import train_test_split
from sklearn.datasets import fetch_lfw_people
from sklearn.grid_search import GridSearchCV
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.decomposition import RandomizedPCA
from sklearn.svm import SVC

import os

# Display progress logs on stdout
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

img_dict = '/Users/senzhuang/Documents/GitHub/Fall2016-proj3-grp6/data/images'

# load and resize images for processing
def load_image(data_folder, partial=True, image_size=200):
    dataset = np.empty([1000,40000])
    image_filenames = os.listdir(data_folder)

    if partial:
        image_filenames = image_filenames[:1000]

    num_images = len(image_filenames)
    dataset = np.ndarray(shape=(num_images, image_size, image_size, 3), dtype=float)
    dataset_labels = []

    for image_index, image_filename in enumerate(image_filenames):
        image_path = os.path.join(data_folder, image_filename)

        image = io.imread(image_path)
        image = resize(image, (image_size, image_size))

        dataset = np.append(dataset, image)
    return dataset

X = load_image(img_dict)
print(type(X))
print(X.shape)

################################################################################
# Create id and labels for images
target_names = np.array(['Fried Chiken', 'Dog'])
y = np.repeat(np.array([1,2]),500)

###############################################################################
# Split into a training and test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)

###############################################################################
# Compute a PCA on the images dataset (treated as unlabeled
# dataset): unsupervised feature extraction / dimensionality reduction
n_components = 250

print "Extracting the top %d eigenfaces from %d faces" % (n_components, X_train.shape[0])
t0 = time()
pca = RandomizedPCA(n_components=n_components, whiten=True).fit(X_train)
print "done in %0.3fs" % (time() - t0)
print "Variance explained by 1st and 2nd PC:"
print pca.explained_variance_ratio_
eigenfaces = pca.components_.reshape((n_components, h, w))

print "Projecting the input data on the eigenfaces orthonormal basis"
t0 = time()
X_train_pca = pca.transform(X_train)
X_test_pca = pca.transform(X_test)
print "done in %0.3fs" % (time() - t0)




