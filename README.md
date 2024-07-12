# RIOTS-Gasembargo

This repository contains the replication code and data for the research study titled "Regional Industrial Effects in Germany from a Potential Gas Deficit" conducted by Robert Lehmann and Christoph Schult.

## Folder Structure

- **Data/**: Contains datasets and input files needed for the simulations.
- **Functions/**: R scripts with functions used across different analysis stages.
- **Output/**: Output files from the simulations, including results and logs.
- **Scripts/**: Scripts to perform the analysis and simulations.
- **Main.R**: Main R script that orchestrates the execution of all scripts in the "Scripts" folder.

## How to Execute

To replicate the study's findings:
1. Clone the repository to your local machine.
2. Open the `Main.R` script.
3. Run the script in your R environment. This script will automatically execute all necessary scripts in the "Scripts" folder.

## Data Description

- **Destatis/**:
  - `CompareActualPredicted.xlsx`: Year-on-year changes in industrial production.
  - `GasData.xlsx`: Data on net gas imports, storage, consumption, and industrial usage.
- **InputOutputTables/**:
  - `BLIO.xlsx`: Regional input-output table for federal states.
  - `DEIO.xlsx`, `IODEAppendix.xlsx`, `EastWestIODE.xlsx`: Further IO tables for analysis.
  - `InputBL.xlsx` and `InputDE.xlsx`: Input data for IO analysis using different approaches.
  - `riot.rds`: Regional input-output table at the county level for Germany.

## Scripts Overview

- **Script1_SimulateGasStorage.R**: Simulates gas consumption profiles and shortages.
- **Script2a_CreateIOReducedBL.R & Script2b_CreateIOReducedEastWest.R**: Create regional IO matrices.
- **Script3a_Computation.R & Script3b_ComputationActual.R**: Perform IO analysis, compare simulation results with actual data.
- **Script4a_FirstSecondRoundEffects.R & Script4b_IntermediateImports.R**: Evaluate economic impacts and calculate demands for intermediate goods.
- **Script5_SimpleExample.R**: Demonstration script for IO analysis used in an online appendix.

## Output Files

- **ExcelFiles/**: Contains Excel files with detailed analysis results.
- **RDS/**: Stores R data files with results from various computational stages.

## Contact Information

For further inquiries, please contact [Robert Lehmann](mailto:robert.lehmann@example.com) or [Christoph Schult](mailto:christoph.schult@example.com).
