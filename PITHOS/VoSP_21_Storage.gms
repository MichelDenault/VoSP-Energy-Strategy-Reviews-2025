************************************************************
************************** SETS ****************************
sets
B     'Energy storage technologies'   /1/
;

************************************************************
*********************** PARAMETERS *************************
parameters
BE_CapIni(B,R)    'Initial capacities for battery energy in each region             (MWh)'
BE_Lifespan(B)    'Lifespan of battery energy                                       (Year)'
BE_IC(B,R)        'Investment cost for battery energy                               (USD per MWh)'
BE_AIC(B,R)       'Annualized investment cost for battery energy                    (USD per MW-Year)'
BE_FOM(B,R)       'Fixed operation and maintenance cost for nuclear                 (USD per MW-Year)'
BE_VOM(B,R)       'Variable operation and maintenace cost for nuclear               (USD per MWh)'
BE_Eff(B)         'Loss of stored energy'

BP_CapIni(B,R)    'Initial capacities for battery power in each region              (MW)'
BP_Lifespan(B)    'Lifespan of battery power                                        (Year)'
BP_IC(B,R)        'Investment cost for battery power                                (USD per MW)'
BP_AIC(B,R)       'Annualized investment cost for battery power                     (USD per MW-Year)'
BP_FOM(B,R)       'Fixed operation and maintenance cost for nuclear                 (USD per MW-Year)'
BP_VOM(B,R)       'Variable operation and maintenace cost for nuclear               (USD per MWh)'
BP_Eff(B)         'Round-trip effiency of charge-discharge'

RATIO_BE_BP_ONOFF 'Binary parameter for using a ratio between battery energy and battery power'
RATIO_BE_BP       'Parameter giving the ratio between battery energy and battery power'
;

* Lifespan
BE_Lifespan(B) = 10;
BP_Lifespan(B) = 10;

* Cost of investment
BE_IC(B,R) =  322000;
BP_IC(B,R) =  299000;

* Efficiency of charge cycle
BE_Eff(B)    = 1.00;
BP_Eff(B)    = 0.85;

* Annualised cost of investment
BE_AIC(B,R)  = BE_IC(B,R) / (1 + sum(DUM$(ord(DUM)<BE_Lifespan(B)), 1 / 1.06**ord(DUM)));
BP_AIC(B,R)  = BP_IC(B,R) / (1 + sum(DUM$(ord(DUM)<BP_Lifespan(B)), 1 / 1.06**ord(DUM)));

* Annualized fixed operation and maintenance cost
BE_FOM(B,R)  = BE_IC(B,R) * 0.025;
BP_FOM(B,R)  = BP_IC(B,R) * 0.025;

* Variable operation and maintenace cost
BE_VOM(B,R)  = 0.001;
BP_VOM(B,R)  = 0.001;

* Initial capacities
BE_CapIni(B,'QC') = 1.2;
BE_CapIni(B,'ON') = 240;
BE_CapIni(B,'AT') = 2.5;
BE_CapIni(B,'NY') = 389.5;
BE_CapIni(B,'NE') = 639.2;

BP_CapIni(B,'QC') = 1.2;
BP_CapIni(B,'ON') = 120;
BP_CapIni(B,'AT') = 1.3;
BP_CapIni(B,'NY') = 140.1;
BP_CapIni(B,'NE') = 303.1;

Parameter BE_CapMax(PI,R) 'Maximum capacity additions (MW)'/
$INCLUDE 'VoSP_Input/1-CapUB/VoSP_CapMaxStage_BE.txt'
/;

Parameter BP_CapMax(PI,R) 'Maximum capacity additions (MW)'/
$INCLUDE 'VoSP_Input/1-CapUB/VoSP_CapMaxStage_BP.txt'
/;

Parameter B_CF(PO)    'Investment cost factor of storage for each scenario'/
$INCLUDE 'VoSP_Input/3-ScenVal/VoSP_CF_B.txt'
/;

* Ratio between capacity and power
RATIO_BE_BP_ONOFF = 0;
RATIO_BE_BP = 2;
************************************************************
************************************************************




************************************************************
*********************** VARIABLES **************************
positive variables
BE_Cap(B,R,PI)      'Battery energy capacity expansion per region'
BP_Cap(B,R,PI)      'Battery power  capacity expansion per region'

BE_Lvl(B,R,PO,H)    'Battery energy level per region-scenario-hour'
BP_Ch(B,R,PO,H)     'Hourly charge per region and scenario'
BP_Di(B,R,PO,H)     'Hourly discharge per region and scenario'

BE_Cap_PO(B,R,PO)    'Battery energy capacity expansion for operational node from previous investment node'
BP_Cap_PO(B,R,PO)    'Battery power  capacity for operational node from previous investment node'
;
************************************************************
************************************************************

* No energy at the beginning of the year
BE_Lvl.fx(B,R,PO,'1') = 0;

************************************************************
*********************** EQUATIONS **************************
equations
BP_CH_CAP(B,R,PO,H)         'Charge rate less than capacity'
BP_CH_LVL(B,R,PO,H)         'Charge rate less Battery energy capacity minus Battery energy level'
BP_DI_CAP(B,R,PO,H)         'Discharge rate less than capacity'
BP_DI_LVL(B,R,PO,H)         'Discharge rate less than Battery energy level'
BE_STORAGE(B,R,PO,H)        'Battery energy level less than Battery energy capacity'
BE_EQUILIBRIUM(B,R,PO,H)    'Equilibrium equation of energy between H+1 and H'
BE_CAP_MAX(B,R,PI)          'Battery energy capacity expansion upper bound'
BP_CAP_MAX(B,R,PI)          'Battery power  capacity expansion upper bound'
BE_CAP_PIPO(B,R,PO)         'Battery energy capacity expansion for operational node from previous investment node'
BP_CAP_PIPO(B,R,PO)         'Battery power  capacity expansion for operational node from previous investment node'
BE_BP_RATIO(B,R,PI)         'Ratio between battery energy and battery power'
;

* Charge rate less than capacity
BP_CH_CAP(B,R,PO,H)..
    BP_Ch(B,R,PO,H)
    =l=
    BP_CapIni(B,R) + sum(PI$ONLIN(PO,PI), BP_Cap(B,R,PI))
;

* Charge rate less Battery energy capacity minus Battery energy level
BP_CH_LVL(B,R,PO,H)..
    BP_Ch(B,R,PO,H)
    =l=
    BE_CapIni(B,R) + sum(PI$ONLIN(PO,PI), BE_Cap(B,R,PI)) - BE_Lvl(B,R,PO,H)
;

* Discharge rate less than capacity
BP_DI_CAP(B,R,PO,H)..
    BP_Di(B,R,PO,H)
    =l=
    BP_CapIni(B,R) + sum(PI$ONLIN(PO,PI), BP_Cap(B,R,PI))
;
    
* Discharge rate less than Battery energy level
BP_DI_LVL(B,R,PO,H)..
    BP_Di(B,R,PO,H)
    =l=
    BE_Lvl(B,R,PO,H)
;

* Battery energy level less than Battery energy capacity
BE_STORAGE(B,R,PO,H)..
    BE_Lvl(B,R,PO,H)
    =l=
    BE_CapIni(B,R) + sum(PI$ONLIN(PO,PI), BE_Cap(B,R,PI))
;

* Equilibrium equation of energy between H+1 and H
BE_EQUILIBRIUM(B,R,PO,H)..
    BE_Lvl(B,R,PO,H++1)
    =e=
    BE_Eff(B) * BE_Lvl(B,R,PO,H) + (BP_Eff(B) * BP_Ch(B,R,PO,H) - BP_Di(B,R,PO,H))
;
    
* Battery energy capacity expansion upper bound
BE_CAP_MAX(B,R,PI)..
    BE_Cap(B,R,PI)
    =l=
    BE_CapMax(PI,R)
;
    
* Battery power  capacity expansion upper bound
BP_CAP_MAX(B,R,PI)..
    BP_Cap(B,R,PI)
    =l=
    BP_CapMax(PI,R)
;

* Battery energy capacity expansion for operational node from previous investment node
BE_CAP_PIPO(B,R,PO)..
    BE_Cap_PO(B,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), BE_Cap(B,R,PI))
;
    
* Battery power  capacity expansion for operational node from previous investment node
BP_CAP_PIPO(B,R,PO)..
    BP_Cap_PO(B,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), BP_Cap(B,R,PI))
;

* Ratio between battery energy and battery power
BE_BP_RATIO(B,R,PI)..
    BE_Cap(B,R,PI)
    =e=
    (BP_Cap(B,R,PI) * RATIO_BE_BP)$(RATIO_BE_BP_ONOFF = 1)
    + BE_Cap(B,R,PI)$(RATIO_BE_BP_ONOFF = 0)
;
************************************************************
************************************************************