/*
=============================================================
  Execution of Loading Procedures
=============================================================
  Description:
      Executes the Bronze and Silver loading procedures
      to load and process data through the data warehouse layers.

  Execution Order:
      1. bronze.load_bronze
      2. silver.load_silver
=============================================================
*/



EXEC bronze.load_bronze


EXEC silver.load_silver;
