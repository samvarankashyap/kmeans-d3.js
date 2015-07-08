from numpy import *
from sklearn.cluster import KMeans
import csv
import pdb
pdb.set_trace()
dataset = open("bank-data.csv","r")
bank_data = csv.reader(dataset)
cluster_data = [row for row in bank_data]
cluster_data = cluster_data[1:]
data_age = []
for row in cluster_data:
	age = int(row[1])
	data_age.append(age)
data_age = array(data_age)
k_means = KMeans(init="k-means++",n_clusters=2, n_init=10)
k_means.fit(data_age)


