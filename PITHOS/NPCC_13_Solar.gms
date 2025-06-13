************************************************************
************************** SETS ****************************
sets
S   'Solar technologies'    /1/
;

************************************************************
*********************** PARAMETERS *************************
parameters
S_CapIni(S,R)   'Initial capacities of solar in each region         (MW)'
S_Lifespan      'Lifespan of solar panel                            (Year)'
S_IC(S,R)       'Investment cost of solar                           (USD per MW)'
S_AIC(S,R)      'Annualized investment cost of solar                (USD per MW-Year)'
S_FOM(S,R)      'Fixed operation and maintenance cost of solar      (USD per MW-Year)'
S_VOM(S,R)      'Variable operation and maintenace cost of solar    (USD per MWh)'
S_DerFact       'To account for the effects of transmission congestion, weather variability, market inefficiency and siting/design/operation inefficiency'
;

* Lifespan
S_Lifespan = 25;

* Investment cost
S_IC(S,R) = 1291000;

* Annualized investment cost
S_AIC(S,R)  = S_IC(S,R)/(1+sum(DUM$(ord(DUM)<S_Lifespan), 1/1.06**ord(DUM)));

* Fixed operation and maintenance cost
S_FOM(S,R)  = 23000;

* Variable operation and maintenace cost
S_VOM(S,R)  = 0.001;

* Initial capacities
S_CapIni(S,'QC') = 11;
S_CapIni(S,'ON') = 1837;
S_CapIni(S,'AT') = 0;
S_CapIni(S,'NY') = 1377;
S_CapIni(S,'NE') = 2237;

* Deracting factor for solar
S_DerFact = 0.8;

parameter S_HP(R,H)   'Hourly solar profile in each region in %'     /
$INCLUDE    'NPCC_Input/0-Profiles/NPCC_Shourlyprof.txt'
/;

Parameter S_CapMax(PI,R) 'Maximum solar capacity additions per investment node (MW)'/
$INCLUDE    'NPCC_Input/1-CapUB/NPCC_CapMaxStage_S.txt'
/;

Parameter S_CF(PO)      'Solar cost factor for each scenario'/
$INCLUDE    'NPCC_Input/3-ScenVal/NPCC_CF_S.txt'
/;
************************************************************
************************************************************



************************************************************
*********************** VARIABLES **************************
positive variables
S_Cap(S,R,PI)   'Solar capacity addition per region and investment node'
S_Gen(S,R,PO,H) 'Hourly solar generation per region and scenario'
S_Cap_PO(S,R,PO)'Solar capacity expansion for operational node from previous investment node'
;
************************************************************
************************************************************



************************************************************
*********************** EQUATIONS **************************
equations
SOLAR_GEN_UP(S,R,PO,H)  'Upper bound on solar generation'
S_CAP_MAX(S,R,PI)       'Capacity expansion upper bound'
S_CAP_PIPO(S,R,PO)      'Solar capacity expansion for operational node from previous investment node'
;

* Upper bound on solar generation
SOLAR_GEN_UP(S,R,PO,H)..
    S_Gen(S,R,PO,H)
    =l=
    S_DerFact * S_HP(R,H) * (S_CapIni(S,R) + sum(PI$ONLIN(PO,PI), S_Cap(S,R,PI)));

* Capacity expansion upper bound
S_CAP_MAX(S,R,PI)..        
    S_Cap(S,R,PI)
    =l=
    S_CapMax(PI,R);
    
* Solar capacity expansion for operational node from previous investment node
S_CAP_PIPO(S,R,PO)..
    S_Cap_PO(S,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), S_Cap(S,R,PI))
************************************************************
************************************************************