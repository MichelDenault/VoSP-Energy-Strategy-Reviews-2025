$title NPCC_main

$onText
PITHOS - Power Investment in Transmission, Hydro Operations and Storage
Linear programming model of Québec, Ontario, Atlantic provinces, New York, New England
Model developed by Florian Mitjana
From the Chaire de gestion du secteur de l'énergie | HEC Montréal
$offText

* Activates the end of line comments with the symbol #
$eolcom #
* Activates inline comments
$onInline

* Turn off the listing of the input file
$offlisting

* Turn off the listing and cross-reference of the symbols used
$offsymxref offsymlist

************************************************************
************************** OPTIONS *************************
option
    limrow = 0,         # Equations listed per block
    limcol = 0,         # Variables listed per block
    solprint = off,     # Solver's solution output printed
    sysout = off,       # Solver generated output
    reslim  = 100000;   # Maximum time in seconds that a solver may run before it terminates
************************************************************
************************************************************

************************************************************
******************** INCLUDING FILES ***********************
$INCLUDE 'NPCC_1_Data.gms'          # Data initialization

$INCLUDE 'NPCC_10_Gas.gms'          # Natural gas
$INCLUDE 'NPCC_11_Hydro.gms'        # Hydro
$INCLUDE 'NPCC_12_Nuclear.gms'      # Nuclear
$INCLUDE 'NPCC_13_Solar.gms'        # Solar
$INCLUDE 'NPCC_14_Wind.gms'         # Wind

$INCLUDE 'NPCC_20_DSM.gms'          # Demand-side management
$INCLUDE 'NPCC_21_Storage.gms'      # Storage
$INCLUDE 'NPCC_22_TL.gms'           # Transmission lines

$INCLUDE 'NPCC_30_GloCtr.gms'       # Global constraints

$INCLUDE 'NPCC_40_FctObj.gms'       # Objective function
************************************************************
************************************************************

************************************************************
************************* SOLVER ***************************
model NPCC_main       /all/;

$onText
These are the solver settings for solving large problems with numerical issues.
Here we deactivate the crossover step of the barrier (interior point algorithm). 
Therefore, the obtained solution is not polished (i.e., it´s not an extreme point solution, but a nearly optimal solution). 
To improve the accuracy of the solution, the numerical emphasis is activated and the convergence tolerance is decreased. 
Also, the multi-thread mode is activated with N-1 threads, corresponding to letting one thread available.
$offText
NPCC_main.OptFile = 1;
$onecho > cplex.opt
lpmethod 4
names no
numericalemphasis 1
barcrossalg -1
barepcomp 1e-012
advind 0
$offecho
option threads=-1;

************************************************************
** Problem resolution
SOLVE NPCC_main MINIMIZING Cost_Total USING LP;