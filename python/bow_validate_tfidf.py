# -*- coding: utf-8 -*-
"""
Created on Mon Apr 25 14:59:02 2016

@author: ivanliu
"""
#!/usr/bin/env python

# improved BOW validation script
# changes: leave stopwords in, use TF-IDF vectorizer, removed converting vectorizer output to np.array

import os
import pandas as pd
import numpy as np

from sklearn.cross_validation import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression as LR
from sklearn.metrics import roc_auc_score as AUC

from KaggleWord2VecUtility import KaggleWord2VecUtility

#

data_file = '../../data/all/jobs_all.csv'
data = pd.read_csv( data_file, header = 0, delimiter= "\t", quoting = 3 )

train_i, test_i = data.ix[:,11] != -1, data.ix[:,11] == -1

train = data.ix[train_i]
test = data.ix[test_i]

#train_i, valid_i = train_test_split( np.arange( len( train )), train_size = 0.8, random_state = 88 )
#train = train.ix[train_i]
#validation = train.ix[valid_i]

#

print "Parsing train job titles..."

clean_train_reviews = []
for title in train['abstract']:
	clean_train_reviews.append( " ".join( KaggleWord2VecUtility.review_to_wordlist(title,remove_stopwords=False)))

print "Parsing test reviews..."

clean_test_reviews = []
for title in test['abstract']:
	clean_test_reviews.append( " ".join( KaggleWord2VecUtility.review_to_wordlist(title,remove_stopwords=False)))

#print "Parsing validation reviews..."

#clean_valid_reviews = []
#for title in validation['title']:
#	clean_valid_reviews.append( " ".join( KaggleWord2VecUtility.review_to_wordlist(title,remove_stopwords=False)))

#

print "Vectorizing..."

vectorizer = TfidfVectorizer( max_features = 120000, ngram_range = ( 1, 3 ), 
	sublinear_tf = True )

train_data_features = vectorizer.fit_transform( clean_train_reviews )
test_data_features = vectorizer.transform( clean_test_reviews )
#valid_data_features = vectorizer.transform( clean_valid_reviews )

# let's define a helper function

def train_and_eval_auc( model, train_x, train_y, test_x, test_y ):
	model.fit( train_x, train_y )
	p = model.predict_proba( test_x )
	auc = AUC( test_y, p[:,1] )
	return auc

#

lr = LR()
auc = train_and_eval_auc( lr, train_data_features, train["hat"], \
	train_data_features, train["hat"].values )
print "logistic regression AUC:", auc
print "logistic regression GINI:", 2 * (auc-0.5)

#0.981494163919  - title, No stopwords, 40000 features
#0.982943178793  - title, No stopwords, 80000 features

#0.981494163919  - abstract, No stopwords, 40000 features
#0.981494163919  - abstract, No stopwords, 80000 features
