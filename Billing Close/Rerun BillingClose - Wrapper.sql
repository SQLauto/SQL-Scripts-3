begin tran

	set nocount on 
	/*
		To re-run a billing close, we need to do the following:
			1)  delete the current "open" billing period
			2)  set the status of the billing period to delete to '2'
			3)  delete invoices
			4)  re-run billing close
			5)  re-insert the "open" billing period that was removed in step #1
	*/

	/*
		review the billing periods

		select top 3*
		from scBillingPeriods
		order by BillingPeriodId desc
	*/


	declare @currentOpenBillingPeriodId int
	declare @billingPeriodToDelete int
	declare @sql nvarchar(500)
	declare @msg nvarchar(500)

	--|delete the most recent open billing period
	select @currentOpenBillingPeriodId = max(BillingPeriodId) 
	from scBillingPeriods
	where Status = 0
	
	select @msg = 'BillingPeriodId (' + cast(@currentOpenBillingPeriodId as varchar) + ') will be removed from scBillingPeriods.  
		BillingPeriod BeginDate=' + convert(varchar, BeginDate, 101) + ', EndDate=' + convert(varchar, EndDate, 101)
	from scBillingPeriods
	where BillingPeriodId = @currentOpenBillingPeriodId
	print @msg
		
	--|preserve billing period info to insert after billing close has been re-run
	declare @billingPeriod table (
		  [BeginDate] datetime
		, [EndDate] datetime
		, [OriginalEndDate] datetime
		, [CutoffDate] datetime
		, [Status] tinyint
		, [LastEditedUserId] int
		)
	insert into @billingPeriod
	select BeginDate, EndDate, OriginalEndDate, CutoffDate, 0, 1
	from scBillingPeriods
	where BillingPeriodId = @currentOpenBillingPeriodId


	delete from scBillingPeriods 
	where billingperiodid = @currentOpenBillingPeriodId
	

	--|set status of billing period so it can be rebuilt
	select @billingPeriodToDelete = max(BillingPeriodId) 
	from scBillingPeriods
	where BillingPeriodId < @currentOpenBillingPeriodId

	select @msg = 'Invoices for BillingPeriodId (' + cast(@billingPeriodToDelete as varchar) + ') will be deleted.  
		BillingPeriod BeginDate=' + convert(varchar, BeginDate, 101) + ', EndDate=' + convert(varchar, EndDate, 101)
	from scBillingPeriods
	where BillingPeriodId = @billingPeriodToDelete
	print @msg

	update scBillingPeriods
	set Status = 2
		--, CutoffDate = '5/12/2015 15:00:000'
	where BillingPeriodId = @billingPeriodToDelete

	--|precount
	select @msg = 'Invoice count (before):  ' + cast(count(*) as varchar)
	from scInvoiceMasters i
	where InvoiceDate = (
		select EndDate
		from scBillingPeriods
		where BillingPeriodId = @billingPeriodToDelete
	)
	print @msg

	--exec scInvoicesForBillingPeriod_Delete @BillingPeriodId=@billingPeriodToDelete	
	--exec support_DeleteInvoice

	--|postcount
	select @msg = 'Invoice count (after):  ' + cast(count(*) as varchar)
	from scInvoiceMasters i
	where InvoiceDate = (
		select EndDate
		from scBillingPeriods
		where BillingPeriodId = @billingPeriodToDelete
	)
	print @msg


	--|re-run billing close
	/*
		From a command line, run the following:
		F:\Syncronex\SingleCopy\bin\Syncronex.BillingClose.exe 1
	*/
	set @sql = 'F:\Syncronex\SingleCopy\bin\Syncronex.BillingClose.exe 1'
	print @sql
	--exec xp_cmdshell @sql 

	--|postcount
	select @msg = 'Invoice count (after):  ' + cast(count(*) as varchar)
	from scInvoiceMasters i
	where InvoiceDate = (
		select EndDate
		from scBillingPeriods
		where BillingPeriodId = @billingPeriodToDelete
	)
	print @msg

	insert into scBillingPeriods (
		BeginDate, EndDate, OriginalEndDate, CutoffDate, Status, LastEditedUserId
	)
	select *
	from @billingPeriod



rollback tran