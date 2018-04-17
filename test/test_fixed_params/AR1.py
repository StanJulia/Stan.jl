#!/usr/bin/env python
u"""
AR1.py
by Yara Mohajerani (04/2018)

Generate and plot univariate and multivariate AR1 time-series with Stan
"""
import pickle
import pystan
import os
import numpy as np
import matplotlib.pyplot as plt

#-- directory setup
ddir = os.path.dirname(os.path.realpath(__file__))
pkl_dir = os.path.join(ddir,'compiled_models.dir')
stan_dir = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', 'stan'))


#######################################################
# - single-variat case
#######################################################
T = 100
y0 = 1
phi = 0.95
sigma = 1
dat = dict(T=T,y0=y0,phi=phi,sigma=sigma)


## Fit Stan model #####################################
#-- First check if the compiled file exists. If not, compile model.
compiled_file = os.path.join(pkl_dir,'ar1_compiled.pkl')
if os.path.isfile(compiled_file):
        mod = pickle.load(open(compiled_file, 'rb'))
else:
        mod = pystan.StanModel(os.path.join(stan_dir,'ar1.stan')) #pre-compile

        # save it to the file 'model.pkl' for later use
        with open(os.path.join(pkl_dir,'ar1_compiled.pkl'), 'wb') as f:
            pickle.dump(mod, f)

fit = mod.sampling(data=dat, iter=1000, chains=2, warmup=0,algorithm='Fixed_param')

post = fit.extract(permuted=True)
print 'y_hat shape: ', post['y_hat'].shape
f1,ax1 = plt.subplots(5, 1, figsize=(8,7))
f1.suptitle('Univariate AR1 structure sampled from Normal Distribution')
for i in range(5):
	ax1[i].plot(post['y_hat'][i])
plt.tight_layout()
plt.subplots_adjust(top=0.95)



#######################################################
#-- Now do the multi-variate case
#######################################################

p = 3
PHI = np.random.normal(loc = 0 ,scale = 0.05, size=(p,p))
#-- make the diagnonals larger so it doesn't explode
PHI[np.arange(p),np.arange(p)] = np.random.uniform(low=0.5, high=1.0, size= p)
#-- covariance matrix: only variance of 0.1 for each variable 
SIGMA = np.zeros(PHI.shape)
np.fill_diagonal(SIGMA,0.1)
y0 =  np.random.normal(loc = 0 ,scale = 1, size=p)
dat = dict(T=T,p=p,y0=y0,PHI=PHI,SIGMA=SIGMA)

print 'PHI: ', PHI
print 'SIGMA: ', SIGMA

## Fit Stan model #####################################
#-- First check if the compiled file exists. If not, compile model.
compiled_file = os.path.join(pkl_dir,'ar1_MV_compiled.pkl')
if os.path.isfile(compiled_file):
        mod = pickle.load(open(compiled_file, 'rb'))
else:
        mod = pystan.StanModel(os.path.join(stan_dir,'ar1_MV.stan')) #pre-compile

        # save it to the file 'model.pkl' for later use
        with open(os.path.join(pkl_dir,'ar1_MV_compiled.pkl'), 'wb') as f:
            pickle.dump(mod, f)

fit = mod.sampling(data=dat, iter=1000, chains=2, warmup=0,algorithm='Fixed_param')

post = fit.extract(permuted=True) 
print 'y_hat shape: ', post['y_hat'].shape
f2,ax2 = plt.subplots(5, 1, figsize=(8,7))
f2.suptitle('Multivariate AR1 structure sampled from Normal Distribution')
for i in range(5):
        for j in range(p):
		ax2[i].plot(post['y_hat'][i,j,:])
plt.tight_layout()
plt.subplots_adjust(top=0.95)
plt.show()
