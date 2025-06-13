PITHOS model associated to the paper "On the Value of Saved Power in Net-ZEro North-Eastern America" by Michel Denault (HEC Montréal), Florian Mitjana (HEC Montréal) and Pierre-Olivier Pineau (Chair in Energy Sector Management, HEC Montréal).

The directory "PITHOS" contains the model developped in GAMS with the following files:

- VoSP_0_Main.gms: solver parameters and execution
- VoSP_1_Data.gms: definition of global data (number of hours, regions, etc...)

- VoSP_10_Gas.gms: Gas technology with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion and generation) and equations (capacity expansion, generation)
- VoSP_11_Hydro.gms: Hydro technology with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion and generation) and equations (capacity expansion, generation) PLUS Québec model with large reservoirs/intra-day reservoirs and run-of-river
- VoSP_12_Nuclear.gms: Nuclear technology with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion and generation) and equations (capacity expansion, generation)
- VoSP_13_Solar.gms: Solar technology with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion and generation) and equations (capacity expansion, generation)
- VoSP_14_Wind.gms: Wind technology with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion and generation) and equations (capacity expansion, generation)

- VoSP_20_DSM.gms: Demand response and Load shedding options with parameters (costs, block capacities), variables (capacity expansion and load reduction) and equations (capacity expansion)
- VoSP_21_Storage.gms: Lithium batteries with with parameters (costs, initial capacities, expansion bounds), variables (capacity expansion, charge, discharge, energy stored) and equations (capacity expansion, charge, discharge, equilibrium)
- VoSP_22_TL.gms: Transmission lines with parameters (costs, initial capacities, distances), variables (capacity expansion and trades) and equations (capacity expansion, trades)

- VoSP_30_GloCtr.gms: Global equations such as load balance and carbon emission

- VoSP_40_FctObj.gms: Objective function to minimize (fixed and operational costs)

- Directory "VoSP_Input" includes load, hydro, solar and wind profiles; capacity expansion upper bounds; technology cost factors; load growth factor; carbon emission target.

The file "Data sources.txt" contains sources (link, year and additional informations) for capacities, costs, load, profiles of wind, solar and hydro
