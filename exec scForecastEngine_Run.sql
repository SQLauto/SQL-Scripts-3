set nocount on

declare @paramDaysFromNow int
declare @forecastDate varchar(10)

set @paramDaysFromNow = -1

set @forecastDate = convert(varchar, dateadd(d, @paramDaysFromNow, getdate()), 1)

--|  Insert an informational message into the System Log
declare @msg varchar(256)
set @msg =  'Auto-Forecast beginning for ''' + @forecastDate + ''''
exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
print @msg

exec scForecastEngine_Run @DaysFromNow=@paramDaysFromNow, @LoggingLevel=-1, @LogFile=Null, @Diagnostic=False


