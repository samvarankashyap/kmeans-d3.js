#from pylab import plot,show
import pylab
from numpy import vstack,array
from numpy.random import rand
from scipy.cluster.vq import kmeans,vq
import pdb
pdb.set_trace()
# data generation
data = vstack((rand(150,2) + array([.5,.5]),rand(150,2)))

data = vstack([[1,1],[2,2],[6,5],[7,4]])

# computing K-Means with K = 2 (2 clusters)
centroids,_ = kmeans(data,2)
# assign each sample to a cluster
idx,_ = vq(data,centroids)

# some plotting using numpy's logical indexing
pylab.plot(data[idx==0,0],data[idx==0,1],'ob',
     data[idx==1,0],data[idx==1,1],'or')
pylab.plot(centroids[:,0],centroids[:,1],'sg',markersize=8)
#show()
pylab.savefig("/tmp/sampleimg.png")
