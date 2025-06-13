************************************************************
************************** SETS ****************************
sets
W   'Wind technologies'     /Won, Wof/
;

************************************************************
*********************** PARAMETERS *************************
parameters
W_CapIni(W,R)   'Initial capacities for wind technology in each region  (MW)'
W_Lifespan      'Lifespan of wind generator                             (Year)'
W_IC(W,R)       'Investment cost of wind                                (USD per MW)'
W_AIC(W,R)      'Annualised investment cost of wind                     (USD per MW-Year)'
W_FOM(W,R)      'Fixed operation and maintenance cost of wind           (USD per MW-Year)'
W_VOM(W,R)      'Variable operation and maintenace cost of wind         (USD per MWh)'
W_HP(W,R,H)     'Hourly wind profile per techno-region in %'
W_DerFact       'To account for the effects of transmission congestion, weather variability, market inefficiency and siting/design/operation inefficiency'
;

* Lifespan
W_Lifespan = 25;

* Investment cost
W_IC('Won',R) = 1363000;
W_IC('Wof',R) = 3396000;

* Annualized cost of investment
W_AIC(W,R) = W_IC(W,R) / (1 + sum(DUM$(ord(DUM)<W_Lifespan), 1 / 1.06**ord(DUM)));

* Fixed operation and maintenance cost
W_FOM('Won',R) = 30300 ;
W_FOM('Wof',R) = 107000 ;

* Variable operation and maintenace cost
W_VOM('Won',R) = 0.001;
W_VOM('Wof',R) = 0.001;

* Initial capacities
W_CapIni('Won','QC') = 3946;
W_CapIni('Won','ON') = 5535;
W_CapIni('Won','AT') = 1228;
W_CapIni('Won','NY') = 2190;
W_CapIni('Won','NE') = 1546;

W_CapIni('Wof','QC') = 0;
W_CapIni('Wof','ON') = 0;
W_CapIni('Wof','AT') = 0;
W_CapIni('Wof','NY') = 0;
W_CapIni('Wof','NE') = 29;

* Deracting factor for wind
W_DerFact = 0.8;


parameter
Won_HP(R,H)        'Hourly wind onshore profile per techno-region in %'     /
$INCLUDE    'VoSP_Input/0-Profiles/VoSP_Wonhourlyprof.txt'
/;

parameter
Wof_HP(R,H)        'Hourly wind offshore profile per techno-region in %'     /
$INCLUDE    'VoSP_Input/0-Profiles/VoSP_Wofhourlyprof.txt'
/;

* Hourly wind profile
W_HP('Won',R,H) = Won_HP(R,H);
W_HP('Wof',R,H) = Wof_HP(R,H);


Parameter W_CapMax(PI,R) 'Maximum wind capacity additions per investment node (MW)'/
$INCLUDE 'VoSP_Input/1-CapUB/VoSP_CapMaxStage_W.txt'
/;

Parameter W_CF(W,PO)  'Wind cost factor for each scenario'/
$INCLUDE 'VoSP_Input/3-ScenVal/VoSP_CF_W.txt'
/;
************************************************************
************************************************************



************************************************************
*********************** VARIABLES **************************
positive variables
W_Cap(W,R,PI)   'Wind capacity addition per techno - region'
W_Gen(W,R,PO,H) 'Hourly wind generation per techno - region and scenario'
W_Cap_PO(W,R,PO)'Wind capacity expansion for operational node from previous investment node'
;
************************************************************
************************************************************



************************************************************
*********************** EQUATIONS **************************
equations
W_GEN_UP(W,R,PO,H)  'Upper bound on wind generation'
W_CAP_MAX(W,R,PI)   'Wind capacity expansion upper bound'
W_CAP_PIPO(W,R,PO)  'Wind capacity expansion for operational node from previous investment node'
;

* Upper bound on wind generation
W_GEN_UP(W,R,PO,H)..
    W_Gen(W,R,PO,H)
    =l=
    W_DerFact * W_HP(W,R,H) * (W_CapIni(W,R) + sum(PI$ONLIN(PO,PI), W_Cap(W,R,PI)));

* Capacity expansion upper bound
W_CAP_MAX(W,R,PI)..
    W_Cap(W,R,PI)
    =l=
    W_CapMax(PI,R);

* Wind capacity expansion for operational node from previous investment node
W_CAP_PIPO(W,R,PO)..
    W_Cap_PO(W,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), W_Cap(W,R,PI));
************************************************************
************************************************************