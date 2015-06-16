begin tran

set nocount on

declare @paramDaysFromNow int
declare @forecastDate varchar(10)

set @paramDaysFromNow = -14

set @forecastDate = convert(varchar, dateadd(d, @paramDaysFromNow, getdate()), 1)

--|  Insert an informational message into the System Log
declare @msg varchar(256)
set @msg =  'Auto-Forecast beginning for ''' + @forecastDate + ''''
exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
print @msg

exec scForecastEngine_Run @DaysFromNow=@paramDaysFromNow, @LoggingLevel=-1, @LogFile=Null, @Diagnostic=False

exec scManifestSequence_Finalizer @forecastdate

select min(drawdate)
from scdraws
where datediff(month, getdate(), drawdate) = 0

commit tran