
                            < M A T L A B (R) >
                  Copyright 1984-2018 The MathWorks, Inc.
              R2018b Update 2 (9.5.0.1033004) 64-bit (glnxa64)
                              January 5, 2019

 
For online documentation, see https://www.mathworks.com/support
For product information, visit www.mathworks.com.
 
>> >> >> Batch run started.
>> 
---------------------------------------------------------------------------
CVX: Software for Disciplined Convex Programming       (c)2014 CVX Research
Version 2.1, Build 1127 (95903bf)                  Sat Dec 15 18:52:07 2018
---------------------------------------------------------------------------
Installation info:
    Path: /home/ssamarak/support/cvx
    MATLAB version: 9.5 (R2018b)
    Architecture: GLNXA64
    Java version: disabled
Verfying CVX directory contents:
    No missing files.
Preferences: 
    Path: /home/ssamarak/.matlab/cvx_prefs.mat
---------------------------------------------------------------------------
Setting CVX paths...done.
Saving updated path...failed. (see below)
Searching for solvers...3 shims found.
2 solvers initialized (* = default):
 *  SDPT3    4.0     {cvx}/sdpt3
    SeDuMi   1.34    {cvx}/sedumi
1 solver skipped:
    GLPK             
        Could not find a GLPK installation.
Saving updated preferences...done.
Testing with a simple model...done!
---------------------------------------------------------------------------
To change the default solver, type "cvx_solver <solver_name>".
To save this change for future sessions, type "cvx_save_prefs".
Please consult the users' guide for more information.
---------------------------------------------------------------------------
NOTE: the MATLAB path has been changed to point to the CVX distribution. To
use CVX without having to re-run CVX_SETUP every time MATLAB starts, you
will need to save this path permanently. This script attempted to do this
for you, but failed---likely due to UNIX permissions restrictions.
To solve the problem, create a new file
    /home/ssamarak/Documents/MATLAB/startup.m
containing the following line:
    run /home/ssamarak/support/cvx/cvx_startup.m
Then execute the following MATLAB commands:
    userpath reset; startup
Please consult the MATLAB documentation for more information about the
startup.m file and its proper placement and usage.
---------------------------------------------------------------------------

>> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> Topology: 1
CVX Warning:
   Models involving "log" or other functions in the log, exp, and entropy
   family are solved using an experimental successive approximation method.
   This method is slower and less reliable than the method CVX employs for
   other models. Please see the section of the user's guide entitled
       <a href="file:////home/ssamarak/support/cvx/doc/advanced.html#the-successive-approximation-method">The successive approximation method</a>
   for more details about the approach, and for instructions on how to
   suppress this warning message in the future.
Predict
    1.2986    0.0080

Topology 1 is done.
Topology: 2
Predict
    1.2903    0.0180

Topology 2 is done.
Topology: 3
Predict
    1.2959    0.0060

Topology 3 is done.
Topology: 4
Predict
    1.2577    0.0160

Topology 4 is done.
Topology: 5
Predict
    1.2779    0.0140

Topology 5 is done.
Topology: 6
Predict
    1.2403    0.0200

Topology 6 is done.
Topology: 7
Predict
    1.2727    0.0120

Topology 7 is done.
Topology: 8
Predict
    1.2808    0.0040

Topology 8 is done.
Topology: 9
Predict
    1.2784         0

Topology 9 is done.
Topology: 10
Predict
    1.2869    0.0020

Topology 10 is done.
Topology: 11
Predict
    1.2767    0.0040

Topology 11 is done.
Topology: 12
Predict
    1.2768    0.0120

Topology 12 is done.
Topology: 13
Predict
    1.2825    0.0140

Topology 13 is done.
Topology: 14
Predict
    1.2861    0.0120

Topology 14 is done.
Topology: 15
Predict
    1.3112    0.0060

Topology 15 is done.
Topology: 16
Predict
    1.2983    0.0060

Topology 16 is done.
Topology: 17
Predict
    1.2845         0

Topology 17 is done.
Topology: 18
Predict
    1.2614    0.0200

Topology 18 is done.
Topology: 19
Predict
    1.2571    0.0220

Topology 19 is done.
Topology: 20
Predict
    1.2643         0

Topology 20 is done.
Topology: 21
Predict
    1.2630         0

Topology 21 is done.
Topology: 22
Predict
    1.2844    0.0100

Topology 22 is done.
Topology: 23
Predict
    1.2661    0.0180

Topology 23 is done.
Topology: 24
Predict
    1.2094    0.0260

Topology 24 is done.
Topology: 25
Predict
    1.2806    0.0060

Topology 25 is done.
>> >> Batch run finished.
>> 