$offlisting
$offinclude

************************************************************
*************************** SETS ***************************
sets
R       'Regions'               /ON, QC, AT, NY, NE/
H       'Hours in a year'       /1 * 8760/
PI      'Decision nodes'        /1/
PO      'Operational nodes'     /2/
DUM     'Dummy set'             /1 * 100/
;

* Duplicate the sets of regions (help for modelling)
alias(R,RR);
alias(H,HH);
alias(PI,PII);
alias(PO,POO);

Sets ONLIN(PO, PI)  'List of all invesment nodes related to each operational node'/
$INCLUDE 'VoSP_Input/2-ScenTree/VoSP_Nodes_ONLIN.txt'
/;

Sets INLIN(PI, PII) 'List of all invesment nodes related to each invesment node'/
$INCLUDE 'VoSP_Input/2-ScenTree/VoSP_Nodes_INLIN.txt'
/;

Sets ONLON(PO, POO) 'List of all operational nodes related to each operational node' /
$INCLUDE 'VoSP_Input/2-ScenTree/VoSP_Nodes_ONLON.txt'
/;

Sets ONPIN(PO, PI) 'Previous invesment node related to each invesment node'/
$INCLUDE 'VoSP_Input/2-ScenTree/VoSP_Nodes_ONPIN.txt'
/;

Sets INPIN(PI, PII) 'Previous invesment node related to each invesment node'/
$INCLUDE 'VoSP_Input/2-ScenTree/VoSP_Nodes_INPIN.txt'
/;
************************************************************
************************************************************


************************************************************
*************************** LOAD  **************************
parameter LD_Init(R,H)  'Reference regional hourly load'/
$INCLUDE 'VoSP_Input/0-Profiles/VoSP_load.txt'
/;

Parameter Load_GF(PO)   'Load growth factor for each operational node'/
$INCLUDE 'VoSP_Input/3-ScenVal/VoSP_Load_GF.txt'
/;

parameter LD(R,PO,H)    'Regional hourly load for each operational node';
LD(R,PO,H) = Load_GF(PO) * LD_Init(R,H);
************************************************************
************************************************************