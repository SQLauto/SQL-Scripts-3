begin tran

	dbcc checkident (scBillingPeriods, reseed, 33)

	set nocount on

	/*
		Remove old billing periods
		Set the status of the current billing period to 'closed'
		Insert a new billing period
	*/
	
	select top 5 *
	from scBillingPeriods
	order by BillingPeriodId desc

	declare @currentBillingPeriodId int

	--|  Get the current billing period
	select @currentBillingPeriodId = BillingPeriodId
	from scBillingPeriods
	where BeginDate = (
		select max(BeginDate)
		from scBillingPeriods
		)

	--|  Set the status
	update scBillingPeriods
	set Status = 1
	where BillingPeriodId = @currentBillingPeriodId

	--|  Delete the old billing periods
	--delete from scBillingPeriods
	--where BillingPeriodId <> @currentBillingPeriodId

	--|  Insert the new billing period
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
		where BillingPeriodId = @currentBillingPeriodId
	

select top 5 *
from scBillingPeriods
order by BillingPeriodId desc

commit tran