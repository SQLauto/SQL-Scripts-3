declare @today datetime
set @today = CONVERT(varchar, getdate(), 101)

--eexec dbo.scReports_VariableDaysBack_AppliedSettings @today

--select *
--from dbo.scThresholdDates(@today)
;with cteVDB as (
	select p.PubShortName	
		, returnThreshold, RuleType, PeriodStartDate, PeriodLength, cutoffDay, DayInPeriod, CurrentPeriodStartDate, CutoffDateInPeriod, NewReturnThresholdDate
	from dbo.support_ThresholdDatesReport(@today) t
	join nsPublications p
		on t.PublicationId = p.PublicationID
)
select PubShortName	
		, returnThreshold, RuleType
		, PeriodStartDate as [PeriodStartDate (setting)], PeriodLength as [PeriodLength (setting)], cutoffDay as [PeriodCutoff (setting)]
		, DayInPeriod, CurrentPeriodStartDate, CutoffDateInPeriod, NewReturnThresholdDate
	, DATEDIFF(d, @today, returnThreshold) as [DaysBackFromToday]
from cteVDB		