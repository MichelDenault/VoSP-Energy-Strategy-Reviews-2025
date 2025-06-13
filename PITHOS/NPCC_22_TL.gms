************************************************************
************************* PARAMETERS ***********************
parameters
TL_CapIni(R,RR)     'Initial capacities of transmission between regions                                         (MW)'
TL_Lifespan         'Lifespan of transmission lines                                                             (Year)'
TL_IC_FOM(R,RR)     'Investment and fixed maintenance and operation cost of a transmission capacity             (USD per MW)'
TL_AIC_FOM(R,RR)    'Annualized investment and fixed maintenance and operation cost of a transmission capacity  (USD per MW-Year)'
TL_UnitDistCost     'Unitary cost of a transmission capacity                     -                              (USD per MW-km)'
TL_UnitStationCost  'Unitary cost of transmission stations                                                      (USD per MW)'
TL_Loss             'Percent of electricity loss during a trade                                                 (%)'
TL_Potential(R,RR)  'Binary parameter indicating possible transmission lines between regions'
;

* Binary parameter for capacity expansion of transmission lines
parameter TL_MaxCapStage_CapIni;
TL_MaxCapStage_CapIni = 1;


table TL_Distances(R,RR)   'Flying distance in km between main cities (Montreal, Toronto, Halifax, NYC, Boston) in regions R and RR'
         QC      ON      AT      NY      NE
QC       0       505     791     534     403
ON       505     0       0       551     0
AT       791     0       0       0       655
NY       534     551     0       0       306
NE       403     0       655     306     0;

* Lifespan
TL_Lifespan = 80;

* Percent of electricity loss during a trade
TL_Loss = 0.058;

* UnitTransCost = Unit Cost [$/(MW-mile)] * (mile/km convertion factor)  *  (inflation factor 2013 - 2022: 1.2384)
TL_UnitDistCost = 701.36 / 1.60934 * 1.2384;

* UnitTransCost = (Unit Cost of 2013 in MacDonald, 2017)[$/(MW)] *  (inflation factor 2013 - 2022: 1.2384)
TL_UnitStationCost = 182856 * 1.2384;

* Cost of investment + fixed operation and maintenance cost
* Including 0.5% of O& M
TL_IC_FOM(R,RR)     = (TL_Distances(R,RR) * TL_UnitDistCost + TL_UnitStationCost) * (1 + 0.005);

* Annualized investment cost + fixed operation and maintenance cost
TL_AIC_FOM(R,RR)    = TL_IC_FOM(R,RR) / (1 + sum(DUM$(ord(DUM)<TL_Lifespan), 1 / 1.06**ord(DUM)));

* Initial capacities
TL_CapIni('QC','ON') = 2955;
TL_CapIni('ON','QC') = 2434;

TL_CapIni('QC','AT') = 1200;
TL_CapIni('AT','QC') = 775;

TL_CapIni('QC','NY') = 2079;
TL_CapIni('NY','QC') = 1100;

TL_CapIni('QC','NE') = 2275;
TL_CapIni('NE','QC') = 2170;

TL_CapIni('ON','NY') = 2050;
TL_CapIni('NY','ON') = 1650;

TL_CapIni('AT','NE') = 1000;
TL_CapIni('NE','AT') = 550;

TL_CapIni('NY','NE') = 1600;
TL_CapIni('NE','NY') = 1400;

* Binary parameter indicating existing or new transmission lines between regions
TL_Potential(R,RR) = TL_CapIni(R,RR) > 0;

Parameter TL_CapMax(PI) 'Maximum capacity additions (MW)'/
$INCLUDE 'NPCC_Input/1-CapUB/NPCC_CapMaxStage_TL.txt'
/;

Parameter TL_CF(PO) 'Transmission cost factor for each scenario';
TL_CF(PO) = 1;
************************************************************
************************************************************



************************************************************
*********************** VARIABLES **************************
positive variables
TL_Cap(R,RR,PI)     'Transmission line capacity expansion per (R,RR)'
TL_Flow(R,RR,PO,H)  'Hourly transmission flow between R and RR'
TL_Cap_PO(R,RR,PO)  'Transmission capacity expansion for operational node from previous investment node'
;

* Transmission line are bi-directional: investment on only one side to better results visualization
TL_Cap.up('ON','QC',PI) = 0;
TL_Cap.up('AT','QC',PI) = 0;
TL_Cap.up('NY','QC',PI) = 0;
TL_Cap.up('NE','QC',PI) = 0;
TL_Cap.up('NY','ON',PI) = 0;
TL_Cap.up('NE','AT',PI) = 0;
TL_Cap.up('NE','NY',PI) = 0;
************************************************************
************************************************************



************************************************************
*********************** EQUATIONS **************************
equations
TL_FLOW_UB(R,RR,PO,H)   'Upper bound of transmission'
TL_CAP_MAX(R,RR,PI)     'Capacity expansion upper bound'
TL_CAP_PIPO(R,RR,PO)    'Transmission capacity expansion for operational node from previous investment node'
;

* Upper bound of transmission
TL_FLOW_UB(R,RR,PO,H)$(TL_Potential(R,RR)=1)..
    TL_Flow(R,RR,PO,H)
    =l=
    TL_CapIni(R,RR) + sum(PI$ONLIN(PO,PI), TL_Cap(R,RR,PI)) + sum(PI$ONLIN(PO,PI), TL_Cap(RR,R,PI));

* Capacity expansion upper bound
TL_CAP_MAX(R,RR,PI)$(TL_Potential(R,RR)=1)..
    TL_Cap(R,RR,PI)
    =l=
    TL_Potential(R,RR) * TL_CapMax(PI)$(TL_MaxCapStage_CapIni = 0)
    + TL_Potential(R,RR) * (1 + 1/3) * (TL_CapIni(R,RR) + TL_CapIni(RR,R))$(TL_MaxCapStage_CapIni = 1);
    
* Transmission capacity expansion for operational node from previous investment node
TL_CAP_PIPO(R,RR,PO)..
    TL_Cap_PO(R,RR,PO)
    =e=
    sum(PI$ONPIN(PO,PI), TL_Cap(R,RR,PI))
************************************************************
************************************************************