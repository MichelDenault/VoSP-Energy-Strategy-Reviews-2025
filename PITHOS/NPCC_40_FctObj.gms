************************************************************
****************** OBJECTIVE FUNCTION **********************
variables
Cost_Total            'Total cost to minimize'
Cost_Node_Cap(PO,R)   'Cost of capacities for each operational node and region'
Cost_Node_Ope(PO,R)   'Cost of operations for each operational node and region'
;

equations
Fct_Obj               'Objective function'
NodeCost_Cap(PO,R)    'Cost of capacities for each operational node and region'
NodeCost_Ope(PO,R)    'Cost of operations for each operational node and region'
;

*********************** Capacities *************************
NodeCost_Cap(PO,R)..
    Cost_Node_Cap(PO,R)
    =e=
      sum((G),  (G_AIC(G,R)   + G_FOM(G,R))   * (sum(POO$ONLON(PO,POO), G_CF(POO) * G_Cap_PO(G,R,POO))  + G_CapIni(G,R)                   ))                        /* Natural gas */
    + sum((N),  (N_AIC(N,R)   + N_FOM(N,R))   * (sum(POO$ONLON(PO,POO), N_CF(POO) * N_Cap_PO(N,R,POO))  + N_CapIni(N,R) * N_AvailFact(PO) ))                        /* Nuclear */
    + sum((W),  (W_AIC(W,R)   + W_FOM(W,R))   * (sum(POO$ONLON(PO,POO), W_CF(W,POO) * W_Cap_PO(W,R,POO))  + W_CapIni(W,R)                   ))                        /* Wind */
    + sum((S),  (S_AIC(S,R)   + S_FOM(S,R))   * (sum(POO$ONLON(PO,POO), S_CF(POO) * S_Cap_PO(S,R,POO))  + S_CapIni(S,R)                   ))                        /* Solar */
    + sum((B),  (BE_AIC(B,R)  + BE_FOM(B,R))  * (sum(POO$ONLON(PO,POO), B_CF(POO) * BE_Cap_PO(B,R,POO)) + BE_CapIni(B,R)                  ))                        /* Battery Energy */
    + sum((B),  (BP_AIC(B,R)  + BP_FOM(B,R))  * (sum(POO$ONLON(PO,POO), B_CF(POO) * BP_Cap_PO(B,R,POO)) + BP_CapIni(B,R)                  ))                        /* Battery Power */
    + sum((HQ), (HQ_AIC(HQ)   + HQ_FOM(HQ))   * (sum(POO$ONLON(PO,POO), HQ_CF(POO) * HQ_Cap_PO(HQ,POO))                                   ))$sameas(R,'QC')         /* Hydro-QC */
    + sum((HQ), (H_AIC_INI    + HQ_FOM(HQ))   * HQ_CapIni(HQ)                                                                             )$sameas(R,'QC')          /* Hydro-QC Initial */
    + sum((HR), (HR_AIC(HR,R) + HR_FOM(HR,R)) * (sum(POO$ONLON(PO,POO), HR_CF(POO) * HR_Cap_PO(HR,R,POO))                                 ))                        /* Hydro-R */
    + sum((HR), (H_AIC_INI    + HR_FOM(HR,R)) * HR_CapIni(HR,R)                                                                           )                         /* Hydro-R Initial */
    + sum((RR)$(TL_Potential(R,RR)=1), TL_AIC_FOM(R,RR) * (sum(POO$ONLON(PO,POO), TL_CF(POO) * (TL_Cap_PO(R,RR,POO) + TL_Cap_PO(RR,R,POO)) /2) + TL_CapIni(R,RR)))  /* Transmission lines */
    + sum((LSE), (LSE_AIC(LSE,R) + LSE_FOM(LSE,R)) * (LSE_CF(PO) * LSE_Cap_PO(LSE,R,PO) + LSE_CapIni(LSE,R)                               ))                        /* Load Shedding */
;

*********************** Operations *************************
NodeCost_Ope(PO,R)..
    Cost_Node_Ope(PO,R)
    =e=
    (
      sum((G,H),   G_Gen_R(G,R,PO,H)   * (G_VOM(G,R) + G_Fuel(G,R)))                   /* Regular gas */
    + sum((G,Gb),  G_Gen_CN_B(R,Gb,PO) * (G_VOM(G,R) + G_Block_CF(Gb) * G_Fuel(G,R)))  /* Carbon neutral gas */
    + sum((N,H),   N_Gen(N,R,PO,H)     * (N_Fuel(N,R) + N_VOM(N,R)))                   /* Nuclear - including fuel */
    + sum((N,H),   N_Curtail(N,R,PO,H) * N_CurtailCost(N,R))                           /* Penalty of nuclear curtailment */
    + sum((W,H),   W_Gen(W,R,PO,H)     * W_VOM(W,R))                                   /* Wind */
    + sum((S,H),   S_Gen(S,R,PO,H)     * S_VOM(S,R))                                   /* Solar */
    + sum((B,H),   BE_Lvl(B,R,PO,H)    * BE_VOM(B,R))                                  /* Battery Energy */
    + sum((B,H),   BP_Ch(B,R,PO,H)     * BP_VOM(B,R))                                  /* Battery Power */
    + sum((HQ,H),  HQ_Gen(HQ,PO,H)     * HQ_VOM(HQ))$sameas(R,'QC')                    /* Hydro-QC */
    + sum((HR,H),  HR_Gen(HR,R,PO,H)   * HR_VOM(HR,R))                                 /* Hydro-R */
    + sum((H),     PW_Gen(R,PO,H)      * PW_VOM)                                       /* Pumped water storage  */
    + sum((H),     CH_Gen(PO,H)        * CH_VOM)$sameas(R,'QC')                /* Churchill falls */
    + sum((H),     SH_Gen(PO,H)        * SH_VOM)$sameas(R,'QC')                /* Slack hydrogeneration  */
    + sum((H),     LL(R,PO,H)          * VOLL)                                         /* Lost load */
    + sum((LSE,H), LSEh(LSE,R,PO,H)    * LSE_VOM(LSE,R))                               /* Load shedding  */
    + sum((H),     LSIh(R,PO,H)        * LSI_UC)                                       /* Load shifting  */
            )
;

*********** Operational node probabilities *****************
parameter Prob_Node(PO) 'Probability of each operational node'/
$INCLUDE 'NPCC_Input/3-ScenVal/NPCC_Nodes_Prob.txt'
/;

******************* Objective function *********************
Fct_Obj..
    Cost_Total
    =e=
    sum((PO,R), Prob_Node(PO) * (Cost_Node_Cap(PO,R) + Cost_Node_Ope(PO,R) ));
************************************************************
************************************************************