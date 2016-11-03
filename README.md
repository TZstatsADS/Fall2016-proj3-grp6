# Project: Labradoodle or Fried Chicken? 
![image](https://s-media-cache-ak0.pinimg.com/236x/6b/01/3c/6b013cd759c69d17ffd1b67b3c1fbbbf.jpg)
### [Full Project Description](doc/project3_desc.html)

Term: Fall 2016

+ Team #
+ Team members
	+ Chenxi Huang
	+ Hayoung Kim
	+ Huilong An
	+ Jaime Gacitua
	+ Sen Zhuang
+ Project summary: In this project, we created a classification engine for images of poodles versus images of fried chickens. 
	
**Contribution statement**:
All members designed the study. Jaime developed baseline classification model for evaluation. All members explored feature engineering for improving the baseline model. Chenxi discussed and designed the feature selection and cross-validations. Hayoung, Huilong, Jaime and Sen discussed and designed the model selections. All members carried out the computation for model evaluation. All team members contributed to the GitHub repository and helped Huilong to prepare the presentation. Huilong is the presenter and prepared the presentation mostly. Jaime and Chenxi contributed to github organization. Chenxi and Huilong wrote the project description. All team members approve our work presented in our GitHub repository including this contribution statement.

**Note:for the codes to run smoothly, please download "Project3_poodleKFC_test.zip", unzip it and add it into the data file.**


([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

**Project Description (Model Selected & Results)**
Summary: In this project, we developed a new method and improved the classification accuracy for images of dogs and chicken to 90%
**Project Summary**:
**1. Baseline Model** (around 34%)
Feature: SIFT, 5000
Model: GBN
Sub-summary:
(1) Cross-Validation: tested using K=3 and 5 while keeping other situations unchanged. 
Turns out K=5 performed slightly better than K=3.
(2) Depth: tested the best depth values using a sequence of values: seq(3,11,by=2) on both the base model and the advanced model below. 
depth=11 performed better in most of the cases. 
(3) n.trees for GBM: tested ntrees=100,200,500,1000,2000.
Turns out 200 and 1000 performed slightly better than other values. However, it took too long to use n.trees=1000 or even 2000, so we used n.trees=100 or 200 when establishing advanced models. 

**2. Feature Selection** (85+%)
(1) We firstly observed that the background colors differ. For example, chicken is usually placed on plates or other containers, while dogs are usually running in the grass, lying in the sofa or sitting in the living room. Also, although the color of chicken is similar to that of a dog, among the dogs the colors vary much more than among the chicken wings. Dogs present different colors due to different breeds.
So we choose to add RGB to the original SIFT. 
We tested 125, 512, and 1000 new RGB features (i.e., each with bin number per color=5, 8, and 10, respectively). Turns out 1000 new features perform the best. 
(2) We also tried to use PCA to trim down the feature dimensionality. However, after a few trials, we found out that using PCA did not improve that much so we discarded this idea. 
Results: add 1000 new RGB features to SIFT (5000), leading to now totally 6000 features. 

**3. Model Selection** (around 90%)
We developed our model by three categories: Linear boundary model, Non-linear boundary model and boosting method.
(1) Linear boundary model : logistic, SVM with linear kernel. We tried but linear separation merged. This is an important indication that we might lose lots of information contained in feature space if we use a linear boundary.<br>
(2) Non-linear model : By parameterized model, we tried the SVM with radial and polynomial model. And we used PCA to reduce the dimensionality of the feature space first. And then we tried Naive Bayes, which had a higher error rate because independece assumption cannot be met according to the way to extract SIFT(the SIFT features can be highly negatively related).<br>
(3) Boosting model : We finally went back to the boosting models. We tried Random Forest (by both bagging and boosting), and Gradient boosting machine (regularization both using shrinkage and bagging). We believe the properties of GBM (i.e. No boundary shape restriction; no strong assumption; inner mechanism to remedy overfitting problem).<br>
Here is a table to show part of our result.<br>
![image](https://github.com/TZstatsADS/Fall2016-proj3-grp6/blob/master/figs/model_comparision_table.png)






Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
