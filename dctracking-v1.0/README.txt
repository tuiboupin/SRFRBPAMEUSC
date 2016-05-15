###################################################################
#                                                                 #
#   Discrete-Continuous Optimization for Multi-Target Tracking    #
#     Anton Andriyenko, Konrad Schindler and Stefan Roth          #
#                          CVPR 2012                              #
#                                                                 #
#                 Copyright 2012 Anton Andriyenko                 #
#                                                                 #
###################################################################



ABOUT:
This software implements our approach to multi-target tracking
using discrete-continuous optimization [1].


The additional packages
 - GCO
 - splinefit
are released under a different license and are included for your convenience.
Please refer to the information files within the corresponding folders
for more details.



==========================================================================
DISCLAIMER:
This demo software has been rewritten for the sake of simplifying the
implementation. Therefore, the results produced by the code may differ
from those presented in the paper [1].
==========================================================================


IMPORTANT:
If you use this software you should cite the following in any resulting publication:
    [1] Discrete-Continuous Optimization for Multi-Target Tracking
        A. Andriyenko, K. Schindler and S. Roth
        In CVPR, Providence, RI, USA, June 2012




INSTALLING & RUNNING
1.	Unpack dctracker-v1.0.zip

2.	Download and install GCO 3.0 from
	http://vision.csd.uwo.ca/code/
	and place it into ./gco-v3.0
    You should rebuild the GCO package if the binaries
    for your specific platform are missing in ./gco-v3.0/matlab/bin

3.  Start MATLAB and run compileMex.m to build the utilities binaries.
    (This step can be omitted if you are using MAC OS 64 bit ot Unix 64 bit.)
	
4.	Run dcTrackerDemo.m

You should be able to see the results similar to the ones in demo/result.avi



CHANGES
	1.0		May 25, 2012	Initial public release