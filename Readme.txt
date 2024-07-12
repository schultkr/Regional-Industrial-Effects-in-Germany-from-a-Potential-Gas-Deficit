Folder Overview:
Inside this folder, you'll find the R code needed to recreate the research study titled "Regional Industrial Effects in Germany from a Potential Gas Deficit" conducted by Robert Lehmann and Christoph Schult.

How to Execute:
To replicate the study's findings, simply run the "Main.R" script. It takes care of running all the necessary scripts located in the "Scripts" folder.

Functions:

    functionsioanalysis.R: This file houses two important R functions:
        compiocoeff: Calculates sector-specific domestic inputs and input coefficient matrices, essential for further input-output (IO) analysis.
        computelink: Performs calculations to simulate how changes in production and imports impact economic output across various sectors and regions.

Scripts:

    Script1_SimulateGasStorage.R: Generates a gas consumption profile and computes gas shortages based on data from an Excel file.
    Script2a_CreateIOReducedBL.R and Script2b_CreateIOReducedEastWest.R: Create regional input-output (IO) matrices, crucial for analyzing economic interdependencies among sectors and regions. They process raw data, map it based on predefined classifications, and save it in Excel format.
    Script3a_Computation.R: Uses input-output (IO) analysis to calculate first and second-round effects across different sectors, saving results as matrices in RDS and Excel files.
    Script3b_ComputationActual.R: Processes various data sources, including sector-specific gas shares and regional economic data, using custom functions (compiocoeff and computelink) for specific IO calculations. It also compares simulation results with actual data.
    Script4a_FirstSecondRoundEffects.R: Focuses on evaluating the impact of gas shortages across different rounds and regions using both bottom-up and top-down approaches. Detailed results, including state-specific losses, are saved in Excel format.
    Script4b_IntermediateImports.R: Calculates additional demand for intermediate goods for each month and interval with a gas shortage, separately for bottom-up and top-down approaches. Results are saved in Excel files.
    Script5_SimpleExample.R: Demonstrates IO analysis to compute first and second-round effects for an online appendix illustration.

Data:

    Destatis:
        CompareActualPredicted.xlsx: Contains year-on-year changes in industrial production.
        GasData.xlsx: Holds data on net gas imports, gas storage, gas consumption, and industrial gas consumption.
    InputOutputTables:
        BLIO.xlsx: A regional input-output table for federal states created using Script2a_CreateIOReducedBL.R with data from riot.rds.
        DEIO.xlsx: Input-output table derived from BLIO.xlsx.
        IODEAppendix.xlsx.
        EastWestIODE.xlsx: A regional input-output table for federal states created using Script2a_CreateIOReducedBL.R with data from riot.rds.
        InputBL.xlsx: Contains input data for input-output analysis in the Bottom-Up approach.
        InputDE.xlsx: Contains input data for input-output analysis in the Top-Down approach.
    Correspondence.xlsx: Maps counties and sectors to federal states and more aggregated sectors.
    riot.rds: A regional input-output table at the county level for Germany, created by Krebs (Krebs 20 - University of Tübingen Working Papers in Business and Economics 132).

Output:

    ExcelFiles:
        CompareActualPredicted.xlsx: Displays import changes computed using the IO method.
        GasShortageProfile.xlsx: Contains the gas shortage profile for the industry.
        InputOutputCoefficientsBL.xlsx: Stores input-output coefficients for the Bottom-Up approach.
        InputOutputCoefficientsDE.xlsx: Stores input-output coefficients for the Top-Down approach.
        ResultsBottomUpInterval.xlsx: Presents yearly results for the Bottom-Up approach for various levels of gas shortage.
        ResultsBottomUpYear.xlsx: Contains yearly results for the Bottom-Up approach based on the gas shortage profile.
        ResultsTopDownInterval.xlsx: Displays results for the Top-Down approach for different gas shortage levels.
        ResultsTopDownYear.xlsx: Contains yearly results for the Top-Down approach based on the gas shortage profile.
        ResultsIntermediatesBottomUpInterval[Interval].xlsx: Shows additional demand for intermediate goods in the Bottom-Up approach for different gas shortage levels (ranging from 10 to 100 percent).
        ResultsIntermediatesTopDownInterval[Interval].xlsx: Highlights additional demand for intermediate goods in the Top-Down approach for varying gas shortage levels.
    RDS:
        ResultsBL.rds: Stores first and second-round effects for the Bottom-Up approach.
        ResultsDE.rds: Stores first and second-round effects for the Top-Down approach.