select 
	datepart(hour, sltimestamp) as [startHour], count(*)
from syncSystemLog
where LogMessage = 'ForecastEngine: Forecasting start'
group by datepart(hour, sltimestamp)
order by datepart(hour, sltimestamp)

