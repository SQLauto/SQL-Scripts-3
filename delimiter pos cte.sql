CREATE TABLE dbo.Table1 
(
    DropLocation    VARCHAR(128)
)
GO

INSERT INTO dbo.Table1 VALUES ('val,val2,val3')
INSERT INTO dbo.Table1 VALUES ('val5,val7,val9,val14')
INSERT INTO dbo.Table1 VALUES ('val8,val34,val36,val65,val71,val')
INSERT INTO dbo.Table1 VALUES ('val3,val5,val99')
GO

SELECT * FROM dbo.Table1;
GO

;WITH
	L0 AS (SELECT 1 AS c UNION ALL SELECT 1),
	L1 AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
	L2 AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
	L3 AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
	Numbers AS(SELECT ROW_NUMBER() OVER(ORDER BY c) AS n FROM L1
)
SELECT DropLocation, [1] AS Column1, [2] AS Column2, [3] AS Column3, [4] AS Column4--, [5] AS Column5, [6] AS Column6, [7] AS Column7
FROM
(SELECT DropLocation,
        ROW_NUMBER() OVER (PARTITION BY DropLocation ORDER BY nums.n) AS PositionInList,
        LTRIM(RTRIM(SUBSTRING(valueTable.DropLocation, nums.n, charindex(N',', valueTable.DropLocation + N',', nums.n) - nums.n))) AS [Value]
 FROM   Numbers AS nums 
 INNER JOIN dbo.Table1 AS valueTable 
	ON nums.n <= CONVERT(int, LEN(valueTable.DropLocation)) 
	AND SUBSTRING(N',' + valueTable.DropLocation, n, 1) = N',') AS SourceTable
PIVOT
(
MAX([VALUE]) FOR PositionInList IN ([1], [2], [3], [4])--, [5], [6], [7])
) AS Table2
GO

drop table Table1
go