** DETAILED HYDRO-COMPLEXES SETS **

$offlisting
$offinclude
************************************************************
************************** SETS ****************************
* Binary parameter for a possible expansion of hydro
parameter Hydro_Potential;
Hydro_Potential = 1;

sets
HQ      'QC detailled hydro plants'         /BR,LF2,LF1,LG4,LG3,LG2,LG1,EM,SA,OU4,OU3,OU2,MA5,MA3,MA2,MA1,TO/
HR      'Aggregated hydro technologies'     /ROR,PS/
;

alias(HQ,HQHQ);

SET
RES large reservoirs /1,2,3,4,5/ ;
** Hydro Quebec's five largest reservoirs are considered in this study :
** 1-Caniapiscau , 2-La Grande 3, 3-Robert Bourassa, 4-Aux Outardes and 5-Manicouagan
** Reservoirs 1 to 3 are interdependent of the complex La Grande.
** Churchill Falls Reservoir is defined as an exogenous import

*SET
*HQ hydropower plants /BR,LF2,LF1,LG4,LG3,LG2,LG1,EM,SA,OU4,OU3,OU2,MA5,MA3,MA2,MA1,TO/  ;
** BR: Brisay ; LF: Laforge ; LG: La Grande ; EM: Eastmain ; SA: Sarcelles ; OU: Outardes ; MA: Manic ; TO: Toulnustouc
** LG2 is an aggregate of Robert-Bourassa and La Grande-2-A
** EM is an aggregate of Eastmain-1 and Eastmain-1-A
** MA5 is a an aggregate of Manic-5 and Manic-5-PA
** MA1 is a an aggregate of Manic-1 and McCormick, HQ owns only 60% of McCormick.

SET
RI rivers /Can,Laf,Lag,Dep,Sak,Eas,Rup,GOG,Out,Man,Tou/;
** Can:Caniapiscau ; Laf:Laforge ; Lag:La Grande ; Dep:De Pontois ; Sak:Sakami ;
** GOG:Giard-Opinaca-Gipouloux ; Eas:Eastmain ; Rup:Rupert(downstream) ;
** Out: Aux Outardes ; Man:Manicouagan ; Tou:Toulnustouc
** Remark: Hart jaune, a small river upstream of Man, associated to a  small reservoir plant of 51 MW, has not been modeled.
* I assume its small production has no impact on the management of the Manic reservoir, the largest in QC
* This plant is however taken into account in the set of other hydro technologies.
;

** DETAILED HYDRO-COMPLEXES SUBSETS **

SETS
** To each reservoir is associated a plant or an aggregate of plants: 1-Brisay, 2-LG3, 3-LG2&2A, 4-Outardes 4, 5-Manic 5&5A
HQ_R(RES,HQ)    'Plants at large reservoir'                 /1.BR,2.LG3,3.LG2,4.OU4,5.MA5/
** Lack of data: we assume that these reservoirs are used for intraday arbitrage only.
HQ_IR(HQ)       'Plants with intraday reservoir'            /LF1,LG4,EM,TO/
HQ_ROR(HQ)      'Run-of-river plants'                       /LF2,LG1,SA,OU3,OU2,MA3,MA2,MA1/
HQ_UpR(RES,HQ)  'Plants upstream of large reservoirs'       /2.LG4,3.(LG3,SA)/
HQ_DoR(HQ,HQHQ) 'Plants downstream of other plants'         /LF2.BR,LF1.LF2,LG4.LF1,LG1.LG2,SA.EM,OU3.OU4,OU2.OU3,MA3.MA5,MA2.(MA3,TO),MA1.MA2/
HQ_RRI(RES,RI)  'Rivers associated with reservoirs'         /1.Can,2.Dep,3.Sak,4.Out,5.Man/
HQ_RIP(HQ,RI)   'Rivers associated with other plants'       /LF2.Laf,LG4.Lag,EM.(Eas,Rup),SA.GOG,TO.Tou/
HQ_APDR(HQ,RES) 'Aggregated plants dowstream of reservoirs' /(BR,LF2,LF1,LG4,LG3,LG2,LG1).1,(LG3,LG2,LG1).2,(LG2,LG1).3,(OU4,OU3,OU2).4,(MA5,MA3,MA2,MA1).5/
;


****************
** PARAMETERS **
****************

********************************HYDRO COST PARAMETERS*****************************************
parameter
Hydro_Lifespan  'Lifespan of hydro generator'
H_IC_INI        'Investment cost for INITIAL aggregated hydro technologies              (USD per MW)'
H_AIC_INI       'Annualized investment cost for INITIAL aggregated hydro technologies   (USD per MW-year)'
************* DETAILLED HYDRO COMPLEXES ********************
HR_IC(HR,R)   'Investment cost for aggregated hydro technologies in each region                         (USD per MW)'
HR_AIC(HR,R)  'Annualized investment cost for aggregated hydro technologies                             (USD per MW-year)'
HR_FOM(HR,R)  'Fixed Operation and maintenance cost for aggregated hydro technologies in each region    (USD per MW)'
HR_VOM(HR,R)  'Variable Operation and maintenance cost for aggregated hydro technologies in each region (USD per MWh)'
************* DETAILLED HYDRO COMPLEXES ********************
HQ_IC(HQ)   'Investment cost for QC detailled hydro technology for each dam                         (USD per MW)'
HQ_AIC(HQ)  'Annualized investment cost for QC detailled hydro technology for each dam              (USD per MW-year)'
HQ_FOM(HQ)  'Fixed Operation and maintenance cost for detailled hydro technology for each dam       (USD per MW)'
HQ_VOM(HQ)  'Variable Operation and maintenance cost for detailled hydro technology for each dam    (USD per MWh)'
HQ_ConvFac  'Conversion factor of m^3/s to hm^3/h = 3600/(100^3)'
HQ_FREQ     'Number of hours of cyclic water management'
PW_VOM      'Variable operation and maintenace cost for pumped water'
CH_VOM      'Variable operation and maintenace cost for churchill fall'
SH_VOM      'Variable operation and maintenace cost for slack hydro'
************* CAPACITY COSTS FOR INITIAL CAPACITIES ********************

;
* Lifespan
Hydro_Lifespan = 75;

* Investment cost
HR_IC(HR,R) = 6694000;
HQ_IC(HQ)   = 6694000;
H_IC_INI    = 6694000 / 3;

* Annualised cost of investment
H_AIC_INI       = H_IC_INI      / (1 + sum(DUM$(ord(DUM)<Hydro_Lifespan), 1 / 1.06**ord(DUM)));
HR_AIC(HR,R)    = HR_IC(HR,R)   / (1 + sum(DUM$(ord(DUM)<Hydro_Lifespan), 1 / 1.06**ord(DUM)));
HQ_AIC(HQ)      = HQ_IC(HQ)     / (1 + sum(DUM$(ord(DUM)<Hydro_Lifespan), 1 / 1.06**ord(DUM)));

* Fixed operation and maintenance cost
HR_FOM(HR,R)    = 33000;
HQ_FOM(HQ)      = 33000;

* Variable operation and maintenace cost
HR_VOM(HR,R)    = 0.00001;
HQ_VOM(HQ)      = 0.00001;
PW_VOM          = 0.00001;
CH_VOM          = 0.00001;
SH_VOM          = 0.00001;

* Number of hours of cyclic water management
HQ_FREQ = 24;

* Conversion factor of m^3/s to hm^3/h
HQ_ConvFac = 0.0036;

************************************************************
************* DETAILLED HYDRO COMPLEXES ********************
*The set of detailed plants (HQ) represents 71% of HQ installed capacity.

**QC large reservoir and rivers parameters**
** Source: https://eau.ec.gc.ca/google_map/google_map_f.html?map_type=historical&search_type=province&province=QC
** Source:http://www.hydroquebec.com/comprendre/hydroelectricite/gestion-eau.html;

Parameters
LMIN(RES)   'Minimum content of the reservoirs in hm3'
LMAX(RES)   'Maximum content of the reservoirs in hm3'
IRV(RES)    'Initial water volume in Large Reservoirs in hm3'
INIV        'Assumnption on the inital volume of Water as % of LMAX-LMIN'
WATIN(RI,H) 'Average hourly water inflow in QC per day in m3-s'
;

* Minimum content of the reservoirs
LMIN('1') = 39e3;
LMIN('2') = 25.2e3;
LMIN('3') = 19.4e3;
LMIN('4') = 10.9e3;
LMIN('5') = 35.2e3;

* Maximum content of the reservoirs
LMAX('1') = 52.6e3 ;
LMAX('2') = 60e3 ;
LMAX('3') = 61.7e3 ;
LMAX('4') = 24.5e3 ;
LMAX('5') = 137.9e3 ;

* Initial water volume in Large Reservoirs
INIV = 0.8;
IRV(RES) = LMIN(RES) + INIV *(LMAX(RES) - LMIN(RES));

Table WaterInflowProf(H,RI) 'Total Predicted water inflow river and day in m3-s'
$ondelim
$include 'VoSP_Input/0-Profiles/DATA_VoSP_HYDRO.csv'
$offdelim
;

WATIN(RI,H) = WaterInflowProf(H,RI);

** Rupert River inflow is limited because:
** 1) HQ must procure a minimum outlow (48% on average) to the original river basin
** 2) The inflow is processed trouhg a tunnel of capcity 800m^3/s
WATIN('Rup',H)= min(0.52*WaterInflowProf(H,'Rup'),800);

Parameters
HQ_CapIni(HQ)       'Initial hydro capacity per plants in QC in MW'
HQ_Potential(HQ)    'Total hydro potential per plant in QC in GW'
HQ_TURB(HQ)         'Number of turbines per plant'
** This parameter is critical to the calibration of the model, only partially public, so we have to do some estimates for the others
HQ_TURB_MAX(HQ)     'Maximum turbined water per dam in m^3-s'
HQ_R_WS_B(HQ)       'Maximum spilled water per dam in m^3-s'
HQ_R_OS_B(HQ)       'Maximum spilled water out of the system per dam in m^3-s'
HQ_P_PROD(HQ)       'Productivity factor of each plant in MW per m^3-s'
HQ_P_AGGPROD(RES)   'Aggregated productivity factor of each reservoir in MW per m^3-s'
;

HQ_CapIni('BR')   = 0.469*1000;
HQ_CapIni('LF2')  = 0.319*1000;
HQ_CapIni('LF1')  = 0.878*1000;
HQ_CapIni('LG4')  = 2.779*1000;
HQ_CapIni('LG3')  = 2.417*1000;
** LG2 capacity is the sum of Robert-Bourassa and La Grande-2-A
HQ_CapIni('LG2')  = (5.616+2.106)*1000;
HQ_CapIni('LG1')  = 1.436*1000;
** EM capacity is the sum of Eastmain-1 and Eastmain-1-A
HQ_CapIni('EM')   = (0.480+0.768)*1000;
HQ_CapIni('SA')   = 0.15*1000;
HQ_CapIni('OU4')  = 0.785*1000;
HQ_CapIni('OU3')  = 1.026*1000;
HQ_CapIni('OU2')  = 0.523*1000;
** MA5 capacity is the sum of Manic-5 and Manic-5-PA
HQ_CapIni('MA5')  = (1.596+1.064)*1000;
HQ_CapIni('MA3')  = 1.326*1000;
HQ_CapIni('MA2')  = 1.229*1000;
** MA1 capacity is the sum of Manic-1 and 60% of McCormick
HQ_CapIni('MA1')  = (0.184+0.235*0.6)*1000;
HQ_CapIni('TO')   = 0.526*1000;

HQ_TURB('BR')   = 2;
HQ_TURB('LF2')  = 2;
HQ_TURB('LF1')  = 6;
HQ_TURB('LG4')  = 9;
HQ_TURB('LG3')  = 12;
** LG2 number of turbines is the sum of Robert-Bourassa and La Grande-2-A
HQ_TURB('LG2')  = 16 + 6;
HQ_TURB('LG1')  = 12;
** EM number of turbines is the sum of Eastmain-1 and Eastmain-1-A
HQ_TURB('EM')   = 3 + 3;
HQ_TURB('SA')   = 3;
HQ_TURB('OU4')  =4;
HQ_TURB('OU3')  = 4;
HQ_TURB('OU2')  = 3;
** MA5 number of turbines is the sum of Manic-5 and Manic-5-PA
HQ_TURB('MA5')  = 8 + 4;
HQ_TURB('MA3')  = 6;
HQ_TURB('MA2')  = 8;
** MA1 number of turbines is the sum of Manic-1 and 60% of McCormick
HQ_TURB('MA1')  = 3 + 7 * 0.6;
HQ_TURB('TO')   = 2;

*  Total hydro potential per plant in QC in GW
HQ_Potential(HQ)    = HQ_CapIni(HQ) * (1 + 1 / HQ_TURB(HQ));
** At most, one more turbine could be built per plant
** For the aggregate of 2 plants, at most two turbines could be built.
HQ_Potential('LG2') = HQ_CapIni('LG2')  * (1 + 2 / HQ_TURB('LG2'));
HQ_Potential('EM')  = HQ_CapIni('EM')   * (1 + 2 / HQ_TURB('EM'));
HQ_Potential('MA5') = HQ_CapIni('MA5')  * (1 + 2 / HQ_TURB('MA5'));
HQ_Potential('MA1') = HQ_CapIni('MA1')  * (1 + 1.6 / HQ_TURB('MA1'));
** Alternatively, the potential for these plant is HQ% of existing capacity.
*HQ_Potential(HQ)= HQ_CapIni(HQ)*1.1;

** Observed parameters
** Source: From wikipedia to QC Ministere de l'environnment reports.
HQ_TURB_MAX('BR')   = 1130;
HQ_TURB_MAX('LG2')  = 4300 + 1620;
HQ_TURB_MAX('LG1')  = 5950;
HQ_TURB_MAX('EM')   = 840 + 1344;
HQ_TURB_MAX('SA')   = 1290;
HQ_TURB_MAX('TO')   = 330;

** Estimated parameters (based on centralized-reduced parameters, so no constant)
** Available data on Francis type of plant (since all plant to estimate have Francis), n=8,
** observations completed with some recent plant in QC for which this data is public
** R^2 modified = 0.86; F = 21.68 ; F-critical Value = 0.0034 ;
** Fisher test reject the null hypothesis: the results are significant p-value are in paranthesis.
** C1=1.46 (0.002) ; C2=-1.65 (0.001); each parameter is significant at more than 99%
HQ_TURB_MAX('LF2') = 783.7292866;
HQ_TURB_MAX('LF1') = 1693.253092;
HQ_TURB_MAX('LG4') = 2783.284568;
HQ_TURB_MAX('LG3') = 3438.677112;
HQ_TURB_MAX('OU4') = 604.896207;
HQ_TURB_MAX('OU3') = 632.7761661;
HQ_TURB_MAX('OU2') = 723.5234853;
HQ_TURB_MAX('MA5') = 717.2937855 + 670.6014601 ;
HQ_TURB_MAX('MA3') = 1589.769956 ;
HQ_TURB_MAX('MA2') = 2016.172763 ;
HQ_TURB_MAX('MA1') = 707.9468388 + 0.6 * 1373.107284;

HQ_R_WS_B(HQ)    = 5000;
HQ_R_WS_B('BR')  = 0;
HQ_R_WS_B('LG2') = 17600;

HQ_R_OS_B(HQ)   = 5000;
HQ_R_OS_B('BR') = 3340;

HQ_P_PROD(HQ) = HQ_CapIni(HQ) / HQ_TURB_MAX(HQ);

HQ_P_AGGPROD(RES) = sum(HQ$HQ_APDR(HQ,RES), HQ_P_PROD(HQ));
************************************************************
************************************************************


************************************************************
************** OTHER HYDRO TECHNOLOGIES ********************
**Operation parameters for other hydro technologies**
Parameters
HR_CapIni(HR,R)     'Initial hydro capacity per techno-region in GW'
HR_Potential(HR,R)  'Total hydro potential per techno-region in GW'
HR_CONTROL          'Water flow controlability for other hydro units in QC in %'
HR_AvPROF(H)        'Water availability profile for other hydro units in QC per day in % of total capacity'
HR_NePROF(PO,H)     'Water need profile for other hydro units in QC per year-day-hour in % of total capacity'
HR_WAPROF(R,PO,H)   'Average water profile for other hydro unit per region-day-hour in % of total capacity'
** Source, http://www.waterpowermagazine.com/features/featurepumped-storage-powers-up-for-new-york-summer/, last consulted on April 25th, 2017
HR_PSEF             'Pumped storage efficiency in %'
;

*New HydroCapacities 
HR_CapIni('ROR','QC') = 10455;
HR_CapIni('ROR','ON') = 9122;
HR_CapIni('ROR','AT') = 1069;
HR_CapIni('ROR','NY') = 4563;
HR_CapIni('ROR','NE') = 1950;

* Pumped storage in NY and NE
HR_CapIni('PS',R)    = 0;
HR_CapIni('PS','NY') = 1409;
HR_CapIni('PS','NE') = 1830;

HR_Potential(HR,R) = 1.1 * HR_CapIni(HR,R);
HR_Potential('PS','NY') = HR_CapIni('PS','NY');
HR_Potential('PS','NE') = HR_CapIni('PS','NE');

** Most of the valley with relatively small hydro in QC are with controlled flow, that is, there is a reservoir in the valley that permit some arbitrage.
** See for example the Saint Maurice Valley or the outaouais Valley or La Romaine valley.
** The calibration of this parameter is however still ad hoc at this point one should look at data to calibrate it at some point.
HR_CONTROL = 0.5;

HR_AvPROF(H)            = sum(RI, WATIN(RI,H)) / smax(HH, sum(RI,WATIN(RI,HH)));
HR_NePROF(PO,H)         = LD('QC',PO,H) / smax((HH), LD('QC',PO,HH));
HR_WAPROF('QC',PO,H)    = HR_CONTROL * HR_NePROF(PO,H) + (1 - HR_CONTROL) * HR_AvPROF(H);

Parameter WAPROF_ON(H) /
$INCLUDE 'VoSP_Input/0-Profiles/VoSP_Hydro_ON.txt'
/;
Parameter WAPROF_AT(H) /
$INCLUDE 'VoSP_Input/0-Profiles/VoSP_Hydro_AT.txt'
/;
Parameter WAPROF_NY(H) /
$INCLUDE 'VoSP_Input/0-Profiles/VoSP_Hydro_NY.txt'
/;
Parameter WAPROF_NE(H) /
$INCLUDE 'VoSP_Input/0-Profiles/VoSP_Hydro_NE.txt'
/;

HR_WAPROF('ON',PO,H) = WAPROF_ON(H);
HR_WAPROF('AT',PO,H) = WAPROF_AT(H);
HR_WAPROF('NY',PO,H) = WAPROF_NY(H);
HR_WAPROF('NE',PO,H) = WAPROF_NE(H);

HR_PSEF = 0.73;


************************************************************
*********************** VARIABLES **************************

Positive Variables
************* DETAILLED HYDRO DECISIONS ********************
HQ_Cap(HQ,PI)   'Hydropower capacity expansion per dam'
HQ_Gen(HQ,PO,H) 'Hourly hydropower generation per dam and scenario'
HQ_Cap_PO(HQ,PO)'Hydropower capacity expansion for operational node from previous investment node'
ws(RES,PO,H)    'Volume of water per reservoir-year-day in hm^3'
wd(HQ,PO,H)     'Average water discharge of turbines in power plant HQ [m^3/s]'
ww(HQ,PO,H)     'Average water spiling of detailled hydro generation per plant-year-day-hour in m^3-s'
wo(HQ,PO,H)     'Average out-of-the-system water spiling of detailled hydro generation per plant-year-day-hour in m^3-s'
************* AGGREGATED HYDRO DECISIONS *******************
HR_Cap(HR,R,PI)     'Hydropower capacity expansion per region'
HR_Gen(HR,R,PO,H)   'Hourly hydropower generation per region and scenario'
HR_Cap_PO(HR,R,PO)  'Hydropower capacity expansion for operational node from previous investment node'
CH_Gen(PO,H)        'Churchill falls generation'
SH_Gen(PO,H)        'Slack hydrogeneration in TEMPORARY complement of miscalibration -- 30TWh'
PW_Gen(R,PO,H)      'Pumped water in NY or NE per year-day-hour in MW'
;


************************************************************
*********************** EQUATIONS **************************

**************** Investment Potential **********************
Equations
HQ_CAP_MAX(HQ,PI)
HR_CAP_MAX(HR,R,PI)
HQ_CAP_PIPO(HQ,PO)
HR_CAP_PIPO(HR,R,PO)
;

** Investment potential for aggregated hydro is set at 10% if existing capacity in each region
** Except for Pumped Storage (only modeled in NY), for which no new investment is permitted
** Investment potential for QC detailled hydro is set at one incremental turbine per plant.

*We assume no depreciation of hydro capital stock
* Maximum investment in hydro
HQ_CAP_MAX(HQ,PI)..
    sum(PII$INLIN(PI,PII), HQ_Cap(HQ,PII))
    =l=
    HQ_Potential(HQ) - HQ_CapIni(HQ);

HR_CAP_MAX(HR,R,PI)..
    sum(PII$INLIN(PI,PII), HR_Cap(HR,R,PII))
    =l=
    HR_Potential(HR,R) - HR_CapIni(HR,R);

* Hydropower in QC capacity expansion for operational node from previous investment node
HQ_CAP_PIPO(HQ,PO)..
    HQ_Cap_PO(HQ,PO)
    =e=
    sum(PI$ONPIN(PO,PI), HQ_Cap(HQ,PI));
    
* Hydropower capacity expansion for operational node from previous investment node
HR_CAP_PIPO(HR,R,PO)..
    HR_Cap_PO(HR,R,PO)
    =e=
    sum(PI$ONPIN(PO,PI), HR_Cap(HR,R,PI));
    
    
if (Hydro_Potential = 0,
    HQ_Cap.up(HQ,PI) = 0;
    HR_Cap.up(HR,R,PI) = 0;
);

Parameter HQ_CF(PO) 'Hydropower in QC cost factor for each scenario';
HQ_CF(PO) = 1;

Parameter HR_CF(PO) 'Hydropower ROR cost factor for each scenario';
HR_CF(PO) = 1;

************* DETAILLED HYDRO EQUATIONS ********************
Equations
HQ_GEN_BOUND_CAP(HQ,PO,H)   'Production lower than capacity for detailled plant'
HQ_GEN_BOUND_WAT(HQ,PO,H)   'Approximation of the power gneration function' 
HQ_DYNA_ROR(HQ,PO,H)        'Inflow outlfow equality for ROR plants'
HQ_DYNA_IDR(HQ,PO,H)        'Inflow outlfow equality for intraday reservoir plants'
HQ_DYNA_RES(RES,PO,H)       'Dynamic inflow outflow equality for pluri-annual reservoirs'
HQ_TERMINAL(PO,H)           'Terminal condition on the volume of water'
;

HQ_GEN_BOUND_CAP(HQ,PO,H)..
    HQ_Gen(HQ,PO,H)
    =l=
    HQ_CapIni(HQ) + sum(PI$ONLIN(PO,PI), HQ_Cap(HQ,PI));
    
HQ_GEN_BOUND_WAT(HQ,PO,H)..
    HQ_Gen(HQ,PO,H)
    =l=
    HQ_P_PROD(HQ) * wd(HQ,PO,H);

ws.lo(RES,PO,H) = LMIN(RES); 
ws.up(RES,PO,H) = LMAX(RES);

ww.up(HQ,PO,H) = HQ_R_WS_B(HQ); 
wo.up(HQ,PO,H) = HQ_R_OS_B(HQ);

* Run of the river: sum outflows  =   sum inflows + sum upstream outflows
HQ_DYNA_ROR(HQ,PO,H)$HQ_ROR(HQ)..
    wd(HQ,PO,H) + ww(HQ,PO,H) + wo(HQ,PO,H)
    =e=
    sum(RI$HQ_RIP(HQ,RI), WATIN(RI,H)) + sum(HQHQ$HQ_DoR(HQ,HQHQ), wd(HQHQ,PO,H) + ww(HQHQ,PO,H)) ;

* Intra-day reservoirs  (water level at the end of the cycle is equal to initial water level
* Declared only at the end of each cycle
* Sum of inflows during the cycle equals sum of outflows during the cycle
HQ_DYNA_IDR(HQ,PO,H)$(HQ_IR(HQ)and(mod(ord(H),HQ_FREQ)=0))..
    0
    =e=
    sum(HH$(ord(HH)>ord(H)-HQ_FREQ and(ord(HH)<ord(H)+1)),
        wd(HQ,PO,HH) + ww(HQ,PO,HH) + wo(HQ,PO,HH)
        - sum(RI$HQ_RIP(HQ,RI), WATIN(RI,HH))
        - sum(HQHQ$HQ_DoR(HQ,HQHQ), wd(HQHQ,PO,HH) + ww(HQHQ,PO,HH))
        );
                                                        
* Pluri-annual reservoirs - with water volume every 24 hours
* Volume in reservoir RES at hour h = Sum of outstream inflows during the revision period - sum of outflows during revision period +
* volumen at the end of previous cycle (initial volume considered in initial period)
* assuming equal initial stored water level
HQ_DYNA_RES(RES,PO,H)$(mod(ord(H),HQ_FREQ)=0)..
    ws(RES,PO,H)
    =e=
    HQ_ConvFac * sum(HH$(ord(HH)>ord(H)-HQ_FREQ and(ord(HH)<ord(H)+1)),
                    sum(HQ$HQ_UpR(RES,HQ), wd(HQ,PO,HH) + ww(HQ,PO,HH))
                    + sum(RI$HQ_RRI(RES,RI), WATIN(RI,HH))
                    - sum(HQ$HQ_R(RES,HQ), wd(HQ,PO,HH) + ww(HQ,PO,HH) + wo(HQ,PO,HH))
                    )  
    + ws(RES,PO,H-HQ_FREQ)$(ord(H)>HQ_FREQ)
    + IRV(RES)$(ord(H)=HQ_FREQ);

HQ_TERMINAL(PO,H)$(ord(H)=card(H))..
    sum(RES, (ws(RES,PO,H)-LMIN(RES)) * HQ_P_AGGPROD(RES) / 3600)
    =g=
    sum(RES, (IRV(RES)-LMIN(RES)) * HQ_P_AGGPROD(RES) / 3600);


************* AGGREGATED HYDRO EQUATIONS *******************
Equations
HR_GEN_BOUND(R,PO,H)    'Production lower than capacity for ROR'
CH_GEN_BOUND(PO)        'Total production cap Churchill Falls'
SH_GEN_BOUND(PO)        'Total production cap Slack'
PW_PROD_BOUND(R,PO,H)   'production lower than capacity for PS'
PW_RES(R,PO,H)          'Pumped-storage reservoir management'
PW_PUMP_BOUND(R,PO,H)   'Pumping water lower than dam capcity for PS'
;

HR_GEN_BOUND(R,PO,H)..
    HR_Gen('ROR',R,PO,H)
    =l=
    (HR_CapIni('ROR',R) + sum(PI$ONLIN(PO,PI), HR_Cap('ROR',R,PI))) * HR_WAPROF(R,PO,H);

CH_GEN_BOUND(PO)..
    sum(H,CH_Gen(PO,H))
    =l=
    28e6 ;
    
CH_Gen.up(PO,H) = 5428;

SH_GEN_BOUND(PO)..
    sum(H,SH_Gen(PO,H))
    =l=
    30e6 ;
    
SH_Gen.up(PO,H) = 5428;

PW_PROD_BOUND(R,PO,H)$((sameAs(R,'NY') or sameAs(R,'NE')))..
    HR_Gen('PS',R,PO,H)
    =l=
    HR_CapIni('PS',R);
    
PW_RES(R,PO,H)$((mod(ord(H),HQ_FREQ)=0) and (sameAs(R,'NY') or sameAs(R,'NE')))..
    sum(HH$(ord(HH)>ord(H)-HQ_FREQ and(ord(HH)<ord(H)+1)), HR_Gen('PS',R,PO,HH) - HR_PSEF * PW_Gen(R,PO,HH))
    =e=
    0;

PW_PUMP_BOUND(R,PO,H)$((sameAs(R,'NY') or sameAs(R,'NE')))..
    PW_Gen(R,PO,H)
    =l=
    HR_CapIni('PS',R);
    
HR_Gen.up('PS',R,PO,H)$(not((sameAs(R,'NY') or sameAs(R,'NE')))) = 0;
PW_Gen.up(R,PO,H)$(not((sameAs(R,'NY') or sameAs(R,'NE')))) = 0;