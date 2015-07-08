from bottle import route, run, template
from bottle import route, request, response, template, HTTPResponse

import uuid
import numpy
import matplotlib
matplotlib.use('Agg')
from scipy.cluster.vq import *
import pylab
pylab.close()
from bottle import static_file
import csv
import random
from numpy import vstack,array
from numpy.random import rand
from scipy.cluster.vq import kmeans,vq
import json


field_names = ["GEO_ID","AREA_NAME","TABLE_ID","LINE_NUMBER","LINE_DESCRIPTION","ESTIMATE","MARGIN_OF_ERROR"]

def distance(p0,p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2)

print len(field_names)
# getting all the unique fields::;
def get_unique_lists(x_param, y_param):
    x_list = []
    y_list = []
    vector = []
    csvfile = open("stats.csv","r")
    reader = csv.DictReader(csvfile, fieldnames=field_names)
    for row in reader:
        vector_element = []
        #print(row['Report No.'], row['Report Date'])
        x_list.append(row[x_param])
        y_list.append(row[y_param])
        vector_element.append(row[x_param])
        vector_element.append(row[y_param])
        vector.append(vector_element)
    x_list = list(set(x_list))
    y_list = list(set(y_list))
    csvfile.close()
    return x_list,y_list,vector


# convert vector to decimal points
def get_decimal_vector(x_list,y_list,vector):
    d_vector = []
    for element in vector:
        x_index= x_list.index(element[0])
        #print x_index
        y_index = y_list.index(element[1])
        #print y_index
        d_vector_ele = []
        jitter1 = [random.random() for _ in range(0, 1)][0]
        jitter2 = [random.random() for _ in range(0, 1)][0]
        d_vector_ele.append(x_index+jitter1)
        d_vector_ele.append(y_index+jitter2)
        d_vector.append(d_vector_ele)
    return d_vector

def get_decimal_vector2(x_param,y_param):
    d_vector = []
    csvfile = open("stats.csv","r")
    reader = csv.DictReader(csvfile, fieldnames=field_names)
    reader.next()
    for row in reader:
        vector_element = []
        row[x_param] = clean(row[x_param])
        row[y_param] = clean(row[y_param])
        print row[x_param]
        print row[y_param]
        x_cor = int(float(clean(row[x_param]))) if (row[x_param]!='') else 0
        y_cor = int(float(clean(row[y_param]))) if (row[y_param]!='')  else 0
        vector_element.append(x_cor)
        vector_element.append(y_cor)
        d_vector.append(vector_element)
    return d_vector

def clean(element):
    element = element.replace(",","")
    element = element.strip("+/-")
    element = element.strip()
    element = element.replace("N","")
    element = element.replace("X","")
    return element
    

def vector_to_image(d_vector):
    #data = array(d_vector)
    name = str(uuid.uuid4())
    data = vstack(d_vector)
    # computing K-Means with K = 2 (2 clusters)
    centroids,_ = kmeans(data,2)
    # assign each sample to a cluster
    idx,_ = vq(data,centroids)
    # some plotting using numpy's logical indexing
    #pylab.plot(data[idx==0,0],data[idx==0,1],'ob',
    #     data[idx==1,0],data[idx==1,1],'or')
    pylab.plot(data[idx==0,0],data[idx==0,1],'ob',
         data[idx==1,0],data[idx==1,1],'or',markersize=2,marker='o')
    pylab.plot(centroids[:,0],centroids[:,1],'sg',markersize=12,marker='o')
    #pylab.plot(centroids[:,0],centroids[:,1],centroids[:,2],'sg',markersize=1)
    filename = name+".png"
    pylab.savefig("./static/"+filename)
    return filename

def vector_to_image2(d_vector,num_of_clusters):
    name = str(uuid.uuid4())
    xy = []
    xy = array(d_vector)
    res, idx = kmeans2(xy,num_of_clusters)
    colors = ([([0.4,1,0.4],[1,0.4,0.4],[0.1,0.8,1],[1,1,1],[0.3,0.3,0.3],[0.1,0.1,0.1])[i] for i in idx])
    cluster_dict = {}
    for x in colors:
        if str(x) in cluster_dict:
            cluster_dict[str(x)] += 1
        else:
            cluster_dict[str(x)] = 0
    pylab.scatter(xy[:,0],xy[:,1], c=colors)
    pylab.scatter(res[:,0],res[:,1], marker='o', s = 500, linewidths=2, c='none')
    pylab.scatter(res[:,0],res[:,1], marker='x', s = 500, linewidths=2)
    filename = name+".png"
    pylab.savefig("./static/"+filename)
    return filename,cluster_dict


@route('/static/<filename>')
def server_static(filename):
    return static_file(filename, root="static")

@route('/')
def index():
    #x_list,y_list,vector = get_unique_lists('Product Type','City')
    #d_vector = get_decimal_vector(x_list,y_list,vector)
    #name = vector_to_image(d_vector)
    #return template('ui', name=name)
    return template('ui')

@route('/clusterimage',  method='POST')
def clusterimage():
    #pdb.set_trace()
    # function creates output of the queries based on the posted parameters
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        posted_dict =  request.forms.dict
        x_param = posted_dict["x_param"][0]
        y_param = posted_dict["y_param"][0]
        nc = int(posted_dict["noofclusters"][0])
        print x_param
        print y_param
        #x_list,y_list,vector = get_unique_lists(x_param,y_param)
        #d_vector = get_decimal_vector(x_list,y_list,vector)
        d_vector = get_decimal_vector2(x_param,y_param)
        d_vector = array(d_vector)
        name,cluster_dict = vector_to_image2(d_vector,nc)
        #data = json.dumps(posted_dict)
        counters = json.dumps(cluster_dict) 
        resp = HTTPResponse(body=name+"#"+counters,status=200)
        return resp
    else:
        return 'This is a normal request'

def get_decimal_vector3(x_param,y_param):
    d_vector = []
    csvfile = open("stats.csv","r")
    reader = csv.DictReader(csvfile, fieldnames=field_names)
    reader.next()
    for row in reader:
        vector_element = {}
        row[x_param] = clean(row[x_param])
        row[y_param] = clean(row[y_param])
        print row[x_param]
        print row[y_param]
        x_cor = int(float(clean(row[x_param]))) if (row[x_param]!='') else 0
        y_cor = int(float(clean(row[y_param]))) if (row[y_param]!='')  else 0
        vector_element['key'] = x_cor
        vector_element['value']= y_cor
        d_vector.append(vector_element)
    return d_vector
    return

@route('/scatterplot',  method='POST')
def scatterplot():
    #pdb.set_trace()
    # function creates output of the queries based on the posted parameters
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        posted_dict =  request.forms.dict
        x_param = posted_dict["x_param"][0]
        y_param = posted_dict["y_param"][0]
        d_vector = get_decimal_vector2(x_param,y_param)
        data = json.dumps(d_vector)
        resp = HTTPResponse(body=data,status=200)
        return resp
    else:
        return 'This is a normal request'
@route('/bargraph', method='POST')
def bargraph():
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        posted_dict =  request.forms.dict
        x_param = posted_dict["x_param"][0]
        y_param = posted_dict["y_param"][0]
        print x_param
        print y_param
        d_vector = get_decimal_vector3(x_param,y_param)
        data = json.dumps(d_vector)
        resp = HTTPResponse(body=data,status=200)
        return resp
    else:
        return 'This is a normal request'

run(host='0.0.0.0', port=8000)
