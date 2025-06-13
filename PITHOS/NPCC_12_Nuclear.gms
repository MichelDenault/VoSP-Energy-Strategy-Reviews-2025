************************************************************
************************** SETS ****************************
sets
N       'Nuclear technologies'      /1/
;

************************************************************
*********************** PARAMETERS *************************
parameters
N_CapIni(N,R)       'Initial capacities for nuclear in each region              (MW)'
N_Lifespan          'Lifespan of nuclear plant                                  (Year)'
N_IC(N,R)           'Investment cost for nuclear                                (USD per MW)'
N_AIC(N,R)          'Annualized investment cost for nuclear                     (USD per MW-Year)'
N_FOM(N,R)          'Fixed operation and maintenance cost for nuclear           (USD per MW-Year)'
N_VOM(N,R)          'Variable operation and maintenace cost for nuclear         (USD per MWh)'
N_Fuel(N,R)         'Fuel cost for nuclear                                      (USD per MWh)'
N_MinGen(N,R)       'Fraction of minimum generation of nuclear capacity         (MWh per MWh)'
N_CurtailCost(N,R)  'Cost of electricity curtailment for nuclear power plants   (USD)'
N_WorkingRate       'Operating rate of nuclear plant'
;

* Lifespan
N_Lifespan  = 40;

* Investment cost
N_IC(N,R)   = 9440000;

* Annualized investment cost
N_AIC(N,R)  = N_IC(N,R) / (1 + sum(DUM$(ord(DUM)<N_Lifespan), 1 / 1.06**ord(DUM)));

* Fixed operation and maintenance cost
N_FOM(N,R)  = 152120;

* Variable operation and maintenace cost
N_VOM(N,R)  = 2.47;

* Fuel cost
N_Fuel(N,R) = 6.88 ;

* Operating rate
N_WorkingRate   = 1;

* Fraction of minimum generation
N_MinGen(N,R)   = 0.8;

* Cost of electricity curtailment
N_CurtailCost(N,R)  = 20;

* Initial capacities
N_CapIni(N,'QC') = 0;
N_CapIni(N,'ON') = 13798;
N_CapIni(N,'AT') = 705;
N_CapIni(N,'NY') = 3304;
N_CapIni(N,'NE') = 3356;

Parameter N_CapMax(PI,R)    'Maximum nuclear capacity additions per investment node (MW)' /
$INCLUDE 'NPCC_Input/1-CapUB/NPCC_CapMaxStage_N.txt'
/;

Parameter N_AvailFact(PO)   'Availability of initial nuclear' /
$INCLUDE 'NPCC_Input/3-ScenVal/NPCC_N_Availabilty.txt'
/;

Parameter N_CF(PO)          'Nuclear cost factor for each scenario' /
$INCLUDE 'NPCC_Input/3-ScenVal/NPCC_CF_N.txt'
/;
************************************************************
************************************************************



************************************************************
*********************** VARIABLES **************************
positive variables
N_Cap(N,R,PI)       'Nuclear capacity addition per region per investment node'
N_Gen(N,R,PO,H)     'Hourly nuclear generation per region and scenario'
N_Curtail(N,R,PO,H) 'Electricity curtailment of nuclear generation'
N_Cap_PO(N,R,PO)    'Nuclear capacity expansion for operational node from previous investment node'
;
************************************************************
************************************************************



************************************************************
*********************** EQUATIONS **************************
equations
N_GEN_MAX(N,R,PO,H)     'Nuclear generation upper bound'
N_GEN_MIN(N,R,PO,H)     'Nuclear generation lower bound'
N_CAP_MAX(N,R,PI)       'Nuclear capacity expansion upper bound'
N_CAP_PIPO(N,R,PO)      'Nuclear capacity expansion for operational node from previous investment node'
;

* Nuclear generation upper bound
N_GEN_MAX(N,R,PO,H)..
    N_Gen(N,R,PO,H)
    =l=
    N_WorkingRate * (N_CapIni(N,R) * N_AvailFact(PO) + sum(PI$ONLIN(PO,PI), N_Cap(N,R,PI)));

* Nuclear generation lower bound
N_GEN_MIN(N,R,PO,H)..
    N_Gen(N,R,PO,H) + N_Curtail(N,R,PO,H)
    =g=
    N_MinGen(N,R) * N_WorkingRate * (N_CapIni(N,R) * N_AvailFact(PO) + sum(PI$ONLIN(PO,PI), N_Cap(N,R,PI)));

* Capacity expansion upper bound
N_CAP_MAX(N,R,PI)..
    N_Cap(N,R,PI)
    =l=
    N_CapMax(PI,R);

* Nuclear capacity expansion for operational node from previous investment node
N_CAP_PIPO(N,R,PO)..
    N_Cap_PO(N,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), N_Cap(N,R,PI))
************************************************************
************************************************************