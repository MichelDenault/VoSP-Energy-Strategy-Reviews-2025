************************************************************
************************** SETS ****************************
sets
LSE     'Load shedding'     /1 * 3/
LSI     'Load shifting'     /1 * 1/
;

************************************************************
*********************** PARAMETERS *************************
parameters
LSE_CapIni(LSE,R)   'Initial capacities of LSE in each region       (MW)'
LSE_Lifespan        'Lifespan of LSE contract                       (Year)'
LSE_IC(LSE,R)       'Investment cost of LSE                         (USD per MW)'
LSE_AIC(LSE,R)      'Annualized investment cost of LSE              (USD per MW-Year)'
LSE_FOM(LSE,R)      'Fixed operation and maintenance cost of LSE    (USD per MW-Year)'
LSE_VOM(LSE,R)      'Variable operation and maintenace cost of LSE  (USD per MWh)'
LSE_UB(LSE,R)       'Upper bound of load shedding                   (% of load)'
VOLL                'Value of lost load                             (USD per MWh)'
LSI_UB              'Upper bound of load shifting                   (% of load)'
LSI_UC              'Cost of load shifting                          (USD per MWh)'
;

* Lifespan
LSE_Lifespan = 1;

* Investment cost
LSE_IC(LSE,R) = 40000;

* Annualized investment cost
LSE_AIC(LSE,R)  = LSE_IC(LSE,R)/(1+sum(DUM$(ord(DUM)<LSE_Lifespan), 1/1.06**ord(DUM)));

* Fixed operation and maintenance cost
LSE_FOM(LSE,R)  = LSE_IC(LSE,R) * 0.025;

* Variable operation and maintenace cost
LSE_VOM('1',R) = 500;
LSE_VOM('2',R) = 1000;
LSE_VOM('3',R) = 1500;

* Upper bound of load shedding
LSE_UB('1',R) = 0.05;
LSE_UB('2',R) = 0.05;
LSE_UB('3',R) = 0.05;

Parameter LSE_CF(PO) 'LSE cost factor for each scenario' ;
LSE_CF(PO) = 1;

* Initial capacities
LSE_CapIni(LSE,'QC') = 0;
LSE_CapIni(LSE,'ON') = 0;
LSE_CapIni(LSE,'AT') = 0;
LSE_CapIni(LSE,'NY') = 0;
LSE_CapIni(LSE,'NE') = 0;

* Upper bound of load shifting
LSI_UB = 0.0;

* Cost of load shifting
LSI_UC = 10;

* Value of lost load
VOLL = 10000;
************************************************************
************************************************************


************************************************************
*********************** VARIABLES **************************
positive variables
LSE_Cap(LSE,R,PI)   'LSE capacity addition per region per investment node'
LSE_Cap_PO(LSE,R,PO)'LSE capacity expansion for operational node from previous investment node'
LSEh(LSE,R,PO,H)    'Hourly demand response per segment - region - scenario'
LSIh(R,PO,H)        'Hourly demand response per segment - region - scenario'
LSIh_b(LSI,R,PO,H)  'Hourly demand response per segment - region - scenario'
LSIh_n(LSI,R,PO,H)  'Hourly demand response per segment - region - scenario'
LL(R,PO,H)          'Unserved energy per region-year-hour in GW'
;

* Upper bound of load shedding
LSEh.up(LSE,R,PO,H) = LSE_UB(LSE,R) * LD(R,PO,H);

* Upper bound of load shifting
LSIh.up(R,PO,H)     = LSI_UB * LD(R,PO,H);
************************************************************
************************************************************


************************************************************
*********************** EQUATIONS **************************
equations
LSE_UP(LSE,R,PO,H)      'Load shedding upper bound'
LSE_CAP_PIPO(LSE,R,PO)  'Load shedding capacity expansion for operational node from previous investment node'
LSI_UP(R,PO,H)          'Equilibrium of load shifting'
;

LSE_CAP_PIPO(LSE,R,PO)..
    LSE_Cap_PO(LSE,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), LSE_Cap(LSE,R,PI));

LSE_UP(LSE,R,PO,H)..
    LSEh(LSE,R,PO,H)
    =l=
    LSE_CapIni(LSE,R) + LSE_Cap_PO(LSE,R,PO);

* Equilibrium of load shifting
LSI_UP(R,PO,H)..
    LSIh(R,PO,H)
    =e=
    sum(LSI, LSIh_b(LSI,R,PO,H)) + sum(LSI, LSIh_n(LSI,R,PO,H));
************************************************************
************************************************************