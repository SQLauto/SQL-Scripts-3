/*
	job syntax for requesting a forecast run relative to today
*/

--| declarations
declare @beginDateOffset_RelativeToRunOnDay int
declare @endDateOffset_RelativeToRunOnDay int
declare @runonday varchar(9)	--| Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|null
declare @loggingLevel int	
declare @overwriteUserEdits bit
declare @newAccountsOnly bit
declare @delay_seconds int

--| set variables
set @beginDateOffset_RelativeToRunOnDay = 0
set @endDateOffset_RelativeToRunOnDay = 0
set @runonday = null
set @loggingLevel = null
set @overwriteUserEdits = 0
set @newAccountsOnly = 0
set @delay_seconds = 120

print convert(varchar, dateadd(d, @beginDateOffset_RelativeToRunOnDay, getdate()), 1) 
print convert(varchar, dateadd(d, @endDateOffset_RelativeToRunOnDay, getdate()), 1) 

--| run the export
exec support_ForecastScheduler @beginDateOffset_RelativeToRunOnDay, @endDateOffset_RelativeToRunOnDay, @runonday, @loggingLevel, @overwriteUserEdits, @newAccountsOnly, @delay_seconds

