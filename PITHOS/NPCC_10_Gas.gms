************************************************************
************************** SETS ****************************
sets
G       'Gas technologies'          /CT, CCGT/
Gb      'Carbon-neutral blocks'     /1 * 2/
;

* CT = Combustion Turbine
* CCGT = Combined Cycle Gas Turbine

************************************************************
*********************** PARAMETERS *************************
parameters
G_CapIni(G,R)       'Initial capacities of gas in each region                   (MW)'
G_Lifespan          'Lifespan of gas generator                                  (Year)'
G_CO2_Emissions(G)  'C02 produced                                               (T/MWh)'
G_IC(G,R)           'Investment cost for gas                                    (USD per MW)'
G_AIC(G,R)          'Annualized investment cost for gas                         (USD per MW-Year)'
G_FOM(G,R)          'Fixed operation and maintenance cost for gas               (USD per MW-Year)'
G_VOM(G,R)          'Variable operation and maintenace cost for gas - region    (USD per MWh)'
G_Fuel(G,R)         'Fuel cost for gas                                          (USD per MWh)'
G_Block_Cap(Gb)     'Capacity of each carbon-neutral block                      (TWh)'
G_Block_CF(Gb)      'Cost factor of each carbon neutral gas generation'
;

* Lifespan
G_Lifespan = 25;

* Cost of investment
G_IC('CT',R)    = 1120000;
G_IC('CCGT',R)  = 1248000;

* Annualized investment cost
G_AIC(G,R) = G_IC(G,R) / (1 + sum(DUM$(ord(DUM)<G_Lifespan), 1 / 1.06**ord(DUM)));

* Fixed operation and maintenance cost
G_FOM('CT',R)   =   24000;
G_FOM('CCGT',R) =   31000;

* Variable operation and maintenace cost
G_VOM('CT',R)   =   6.44 ;
G_VOM('CCGT',R) =   1.96 ;

* Based on an natural gas price of $ 3/ MBtu  
* For CT, the heat rate is 9720 Btu/kWh
* For CCGT, the heat rate is 6360 Btu/kWh
G_Fuel('CT',R)      =   29.16 ;  
G_Fuel('CCGT',R)    =   19.08 ;

* C02 produced in tonne per MWh
G_CO2_Emissions('CT')     =   0.516;
G_CO2_Emissions('CCGT')   =   0.338;

* We define 2 capacity blocks for carbon-neutral natural gas:
*   50 TWh at 5 times the natural gas cost
*   250 TWh at 5 times the cost of the previous block (25 times the cost of natural gas) 
G_Block_Cap('1') = 50000000;
G_Block_Cap('2') = 250000000;

* Cost factor of renewable gas generation
G_Block_CF('1') = 5;
G_Block_CF('2') = 25;

* Initial capacities
G_CapIni('CT','QC') = 1007;
G_CapIni('CT','ON') = 6026;
G_CapIni('CT','AT') = 1171;
G_CapIni('CT','NY') = 2915;
G_CapIni('CT','NE') = 1710;

G_CapIni('CCGT','QC') = 341;
G_CapIni('CCGT','ON') = 4980;
G_CapIni('CCGT','AT') = 3947;
G_CapIni('CCGT','NY') = 19100;
G_CapIni('CCGT','NE') = 14946;

Parameter G_CF(PO) 'Gas cost factor for each scenario' ;
G_CF(PO) = 1;

Parameter G_CapMax(PI,R) 'Maximum gas capacity additions for each investment node (MW)' /
$INCLUDE 'NPCC_Input/1-CapUB/NPCC_CapMaxStage_G.txt'
/;

************************************************************
************************************************************

************************************************************
*********************** VARIABLES **************************
positive variables
G_Cap(G,R,PI)           'Gas capacity addition per region per investment node'
G_Gen_R(G,R,PO,H)       'Hourly gas regular generation per region and scenario'
G_Gen_CN(G,R,PO,H)      'Hourly gas carbon neutral generation per region and scenario'
G_Gen_CN_B(R,Gb,PO)     'Carbon-neutral energy generation per block'
G_Cap_PO(G,R,PO)        'Gas capacity expansion for operational node from previous investment node'
;
************************************************************
************************************************************

************************************************************
*********************** EQUATIONS **************************
equations
G_GEN_MAX(G,R,PO,H)     'Gas generation upper bound'
G_GEN_ACN(R,PO)         'Annual carbon-neutral generation'
G_CAP_CN(Gb,PO)         'Capacity of carbon-neutral blocks'
G_CAP_MAX(R,PI)         'Gas capacity expansion upper bound'
G_CAP_PIPO(G,R,PO)      'Gas capacity expansion for operational node from previous investment node'
;

* Gas generation upper bound
G_GEN_MAX(G,R,PO,H)..
    G_Gen_R(G,R,PO,H) + G_Gen_CN(G,R,PO,H)
    =l=
    G_CapIni(G,R) + sum(PI$ONLIN(PO,PI), G_Cap(G,R,PI));

* Annual carbon-neutral generation
G_GEN_ACN(R,PO)..
    sum(Gb, G_Gen_CN_B(R,Gb,PO))
    =e=
    sum((G,H),G_Gen_CN(G,R,PO,H));

* Capacity of carbon-neutral blocks
G_CAP_CN(Gb,PO)..
    sum(R,G_Gen_CN_B(R,Gb,PO))
    =l=
    G_Block_Cap(Gb);

* Capacity expansion upper bound
G_CAP_MAX(R,PI)..
    sum(G, G_Cap(G,R,PI))
    =l=
    G_CapMax(PI,R);

* Gas capacity expansion for operational node from previous investment node
G_CAP_PIPO(G,R,PO)..
    G_Cap_PO(G,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), G_Cap(G,R,PI));
************************************************************
************************************************************