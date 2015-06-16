     IF OBJECT_ID('dbo.NumberTable') IS NOT NULL 
        DROP TABLE dbo.NumberTable

--===== Create and populate the NumberTable table on the fly
 SELECT TOP 11000 --equates to more than 30 years of dates
        IDENTITY(INT,1,1) AS N
   INTO dbo.NumberTable
   FROM Master.dbo.SysColumns sc1,
        Master.dbo.SysColumns sc2

--===== Add a Primary Key to maximize performance
  ALTER TABLE dbo.NumberTable
    ADD CONSTRAINT PK_NumberTable_N 
        PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100