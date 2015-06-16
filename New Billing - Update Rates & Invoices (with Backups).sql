begin tran

	SET NOCOUNT ON

	declare @invoiceDate datetime
	declare @beginDate datetime
	declare @endDate datetime
	declare @pub nvarchar(5)

	set @pub = 'WSJ'
	set @invoiceDate = '12/6/2014'

	update dd
	set DrawRate = 2.82
	FROM scdefaultdraws dd
	join nsPublications p
		on dd.PublicationID = p.PublicationID
	where p.PubShortName = 'wsj'	
	and dd.DrawRate = 1.88
	print 'Updated DrawRate for ' + cast(@@rowcount as varchar) + ' records.'
	
	select @beginDate = BeginDate
		, @endDate = EndDate
	from (
		select InvoiceDate, max(BeginDate) as [BeginDate], max(EndDate) as [EndDate]
		from scInvoiceMasters m
		where m.InvoiceDate = @invoiceDate
		group by InvoiceDate
	) prelim

	print 'InvoiceDate = ' + convert(nvarchar, @invoiceDate, 1) 
	print 'BeginDate = ' + convert(nvarchar, @beginDate, 1) 
	print 'EndDate = ' + convert(nvarchar, @endDate, 1) 


--| Step #1 - Fix Rates in scDraws
	select a.AcctCode, p.PubShortName, typ.ATName, convert( nvarchar, d.DrawDate, 1) as [DrawDate], d.DrawAmount, d.DrawRate, dd.DrawRate as [DefaultDrawRate]
		, d.DrawID, d.AccountID, d.PublicationID
	into #tmpRateUpdate	
	from scdraws d
	join scAccounts a
		on d.AccountID = a.AccountID
	join nsPublications p
		on d.PublicationID = p.PublicationID
	join scDefaultDraws dd
		on d.AccountID = dd.AccountID
		and d.PublicationID = dd.PublicationID
		and d.DrawWeekday = dd.DrawWeekday
	join dd_scAccountTypes typ
		on a.AccountTypeID = typ.AccountTypeID
	where ( 
		( @pub is null and dd.PublicationID > 0 )
		or ( p.PubShortName = @pub )
	)
	and d.DrawDate between @beginDate and @endDate
	and d.DrawRate <> dd.DrawRate 
	--and d.DrawRate = 0
	print 'Found ' + cast(@@rowcount as varchar) + ' records where DrawRate <> DefaultDrawRate'

	select *
	from #tmpRateUpdate
	
	select *
	into support_BackupForRateUpdate_scDraws_12092014
	from #tmpRateUpdate
		
	update scDraws
	set DrawRate = DefaultDrawRate
	from scDraws d
	join #tmpRateUpdate dd
		on d.DrawID = dd.DrawID	
	print 'Updated ' + cast(@@rowcount as varchar) + ' scDraws records where DrawRate <> DefaultDrawRate'	


--|  Step #2 - Product Line Item Details & Line Item Amounts
	;with cteProductLineItemDetails
	as (
		select plid.DrawId, plid.DrawRate, d.DrawRate as [CorrectedDrawRate]
		from scInvoiceMasters im
		join scInvoiceLineItems ili
			on im.InvoiceId = ili.InvoiceId
		join scProductLineItemDetails plid
			on ili.InvoiceLineItemId = plid.InvoiceLineItemId
		join scDraws d
			on plid.DrawId = d.DrawID		
		where im.InvoiceDate = @invoiceDate	
		and plid.DrawRate <> d.DrawRate
	)
	select plid.*, cte.CorrectedDrawRate
	into support_BackupForRateUpdate_scProductLineItemDetails_12092014
	from scProductLineItemDetails plid
	join cteProductLineItemDetails cte
		on plid.DrawId = cte.DrawId
	print 'Backed up  ' + cast(@@rowcount as varchar) + ' scProductLineItemDetails (support_BackupForRateUpdate_scProductLineItemDetails_12092014)'	
	
	;with cteProductLineItemDetails
	as (
		select plid.DrawId, plid.DrawRate, d.DrawRate as [CorrectedDrawRate]
		from scInvoiceMasters im
		join scInvoiceLineItems ili
			on im.InvoiceId = ili.InvoiceId
		join scProductLineItemDetails plid
			on ili.InvoiceLineItemId = plid.InvoiceLineItemId
		join scDraws d
			on plid.DrawId = d.DrawID		
		where im.InvoiceDate = @invoiceDate	
		and plid.DrawRate <> d.DrawRate
	)
	update scProductLineItemDetails	
	set DrawRate = cte.CorrectedDrawRate
	from scProductLineItemDetails plid
	join cteProductLineItemDetails cte
		on plid.DrawId = cte.DrawId
	print 'Updated ' + cast(@@rowcount as varchar) + ' Product Line Item Details scProductLineItemDetails'	

/*
	;with cteLineAmounts
	as (
		select ili.InvoiceId, ili.InvoiceLineItemId, ili.LineAmount
		, cast( ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate as decimal(7,2) ) as NewLineAmount
		from scInvoiceMasters im
		join scInvoiceLineItems ili
			on im.InvoiceId = ili.InvoiceId
		join scProductLineItemDetails plid
			on ili.InvoiceLineItemId = plid.InvoiceLineItemId
		where im.InvoiceDate = @invoiceDate
		and  ili.LineAmount <> cast( ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate as decimal(7,2) ) 
	)	
	select *
	from cteLineAmounts
*/

	select ili.*, ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate as [NewLineAmount]
	into support_BackupForRateUpdate_scInvoiceLineItems_12092014
	from scInvoiceMasters im
	join scInvoiceLineItems ili
		on im.InvoiceId = ili.InvoiceId
	join scProductLineItemDetails plid
		on ili.InvoiceLineItemId = plid.InvoiceLineItemId
	where im.InvoiceDate = @invoiceDate
	and  ili.LineAmount <> cast( ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate as decimal(7,2) ) 
	print 'Backed up  ' + cast(@@rowcount as varchar) + ' scInvoiceLineItems (support_BackupForRateUpdate_scInvoiceLineItems_12092014)'	

	update scInvoiceLineItems
	set LineAmount = ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate 
	from scInvoiceMasters im
	join scInvoiceLineItems ili
		on im.InvoiceId = ili.InvoiceId
	join scProductLineItemDetails plid
		on ili.InvoiceLineItemId = plid.InvoiceLineItemId
	where im.InvoiceDate = @invoiceDate
	and  ili.LineAmount <> cast( ( plid.DrawAmount + plid.AdjustmentAmount - plid.ReturnAmount ) * DrawRate as decimal(7,2) ) 
	print 'Updated ' + cast(@@rowcount as varchar) + ' Line Amounts in scInvoiceLineItems'	
	
	
--| Balance Totals
	;with cteARAccountBalanceTotals
	as (
		select ili.InvoiceId, sum(ili.LineAmount) as [Amount]
		from scInvoiceMasters im
		join scInvoiceLineItems ili
			on im.InvoiceId = ili.InvoiceId
		where im.InvoiceDate = @invoiceDate
		group by ili.InvoiceId
	)
	select ab.*, cte.Amount as [NewAmount]
	into support_BackupForRateUpdate_scARAccountBalances_12092014
	from scInvoiceMasters im
	join scInvoiceMastersARAccountBalances imab
		on im.InvoiceId = imab.InvoiceId
	join scARAccountBalances ab
		on imab.ARAccountBalanceId = ab.ARAccountBalanceId
	join cteARAccountBalanceTotals cte
		on im.InvoiceId = cte.InvoiceId
	where im.InvoiceDate = @invoiceDate
	and  ab.Amount <> cte.Amount
	print 'Backed up  ' + cast(@@rowcount as varchar) + ' scARAccountBalances (support_BackupForRateUpdate_scARAccountBalances_12092014)'	

	;with cteARAccountBalanceTotals
	as (
		select ili.InvoiceId, sum(ili.LineAmount) as [Amount]
		from scInvoiceMasters im
		join scInvoiceLineItems ili
			on im.InvoiceId = ili.InvoiceId
		where im.InvoiceDate = @invoiceDate
		group by ili.InvoiceId
	)
	update scARAccountBalances
	set Amount = cte.Amount
	from scInvoiceMasters im
	join scInvoiceMastersARAccountBalances imab
		on im.InvoiceId = imab.InvoiceId
	join scARAccountBalances ab
		on imab.ARAccountBalanceId = ab.ARAccountBalanceId
	join cteARAccountBalanceTotals cte
		on im.InvoiceId = cte.InvoiceId
	where im.InvoiceDate = @invoiceDate
	and  ab.Amount <> cte.Amount
	print 'Updated ' + cast(@@rowcount as varchar) + ' records in scARAccountBalances'	

rollback tran	