begin tran

select top 5 *
from scBillingPeriods
ORDER BY BillingPeriodId DESC

update scBillingPeriods
set Status = 1
where BillingPeriodId = ( select max(BillingPeriodId) from scBillingPeriods )

INSERT INTO dbo.scBillingPeriods
	(
		 BeginDate
		,EndDate
		,OriginalEndDate
		,CutoffDate
		,[Status]
		,LastEditedUserId
	)
	select dateadd(d, 7, BeginDate), dateadd(d, 7, EndDate), dateadd(d, 7, EndDate), dateadd(d, 7, CutoffDate), 0, 1
	from scBillingPeriods
	where BillingPeriodId = ( select max(BillingPeriodId) from scBillingPeriods )
	

select top 5 *
from scBillingPeriods
ORDER BY BillingPeriodId DESC


commit tran