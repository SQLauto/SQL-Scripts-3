
/*
	sql job syntax for requesting an export with date ranges relative to today
*/

--| declarations
declare @beginDateOffset_RelativeToRunOnDay int
declare @endDateOffset_RelativeToRunOnDay int
declare @runonday varchar(9)	--| Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|null
declare @exportType varchar(9)	--| Return|Adjustment|Forecast|Custom|Invoice
declare @pathToConfigFile nvarchar(1000)
declare @configFile nvarchar(100)
declare @delay_seconds int

--| set variables
set @beginDateOffset_RelativeToRunOnDay = 0
set @endDateOffset_RelativeToRunOnDay = 0
set @exportType = 'Custom'
set @configFile = 'CustomForecastExport.xml'
set @pathToConfigFile = 'C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\'
set @runonday = 'Monday'
set @delay_seconds = 15


print convert(varchar, dateadd(d, @beginDateOffset_RelativeToRunOnDay, getdate()), 1) 
print convert(varchar, dateadd(d, @endDateOffset_RelativeToRunOnDay, getdate()), 1) 

--| run the export
exec support_ExportScheduler @beginDateOffset_RelativeToRunOnDay, @endDateOffset_RelativeToRunOnDay, @runonday, @exportType, @pathToConfigFile, @configFile, @delay_seconds

