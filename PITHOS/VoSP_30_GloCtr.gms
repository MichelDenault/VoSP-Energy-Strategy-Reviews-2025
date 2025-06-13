************************************************************
******************* Power balance **************************
equations
Power_Balance(R,PO,H)   'Balance of hourly loads'
;

Power_Balance(R,PO,H)..
    LD(R,PO,H)
    =e=
    sum(RR$(TL_Potential(RR,R)=1),TL_Flow(RR,R,PO,H)*(1-TL_Loss))   /* Imports */
    - sum(RR$(TL_Potential(R,RR)=1),TL_Flow(R,RR,PO,H))             /* Exports */
    + sum((G),G_Gen_R(G,R,PO,H))                                    /* Gas - regular */
    + sum((G),G_Gen_CN(G,R,PO,H))                                   /* Gas - carbon neutral */
    + sum((N),N_Gen(N,R,PO,H))                                      /* Nuclear */
    + sum((W),W_Gen(W,R,PO,H))                                      /* Wind */
    + sum((S),S_Gen(S,R,PO,H))                                      /* Solar */
    + sum(HR,HR_Gen(HR,R,PO,H))                                     /* Hydro-Region */
    + sum(HQ,HQ_Gen(HQ,PO,H))$sameas(R,'QC')                            /* Hydro-Quebec */
    + CH_Gen(PO,H)$sameas(R,'QC')                               /* Hydro-Churchill */
    + SH_Gen(PO,H)$sameas(R,'QC')                               /* Hydro-Slack */
    - PW_Gen(R,PO,H)                                                /* Hydro-PumpedStorage */
    + sum((B),BP_Di(B,R,PO,H))                                      /* Battery-Discharge */
    - sum((B),BP_Ch(B,R,PO,H))                                      /* Battery-Charge */
    + sum(LSE,LSEh(LSE,R,PO,H))                                     /* Load shedding-reduction */
    - sum(LSI, LSIh_b(LSI,R,PO,H++ord(LSI)))                        /* Load shifting-before */
    - sum(LSI, LSIh_n(LSI,R,PO,H--ord(LSI)))                        /* Load shifting-next */
    + LSIh(R,PO,H)                                                  /* Load shifting-reduction */
    + LL(R,PO,H)                                                    /* Load shedding */
;
************************************************************
************************************************************

************************************************************
******************** Carbon emissions **********************
Parameter CO2_Target_Reduction(PO)  'Percentage of emission reductions w.r.t. 1990 for each operational node'/
$INCLUDE 'VoSP_Input/3-ScenVal/VoSP_CO2_Target_Reduction.txt'
/;

parameter
CO2_Emissions_Ref           'Reference for carbon emissions (Tons)-  30 130 000 corresponds to 80% decarb. w.r.t. 1990'
CO2_Emissions_Node_UB(PO)   'Upper bound on annual carbon emisisons (Tons)'
;

* Equivalent target limits per region (in millions of tons)
* /QC 0.30 - ON 5.12 - AT 2.93 - NY 12.84 - NE 8.94/
CO2_Emissions_Ref           = 30130000;
CO2_Emissions_Node_UB(PO)   = CO2_Emissions_Ref * (100 - CO2_Target_Reduction(PO)) / 20;

equations
CO2_Emissions_Node(PO)  'Carbon emissions for each scenario'
;

CO2_Emissions_Node(PO)..
    sum((G,R,H), G_Gen_R(G,R,PO,H) * G_CO2_Emissions(G))
    =l=
    CO2_Emissions_Node_UB(PO);
************************************************************
************************************************************