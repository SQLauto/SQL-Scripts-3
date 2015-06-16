begin tran

set nocount on
--|insert draw for new accounts

declare @begindate datetime
declare @enddate datetime
declare @acctcode varchar(10)
declare @counter int
declare @counter2 int

create table #accounts (
	acctcode varchar(10)
)


insert into #accounts
select 'T0H0149'

declare acct_cursor cursor
for 
	select acctcode
	from #accounts

open acct_cursor
fetch next from acct_cursor into @acctcode

while @@fetch_status = 0
begin
	--|first date that you want draw to be added for
	set @begindate = '2/17/2014'  
	--set @begindate = convert(varchar, getdate(), 1)  
	set @enddate = '2/17/2014'
	set @counter = 0
	set @counter2 = 0


	--| get the date to insert draws through
	if @enddate is null
	begin
		select @enddate = d.drawdate
		from scdraws d
		join (
			select d.accountid, d.publicationid, min(d.drawdate) as [DrawDate]
			from scdraws d
			join (
				select accountid, publicationid, drawdate
				from scdraws 
				where drawdate > @begindate
				and accountid = ( select accountid from scaccounts where acctcode = @acctcode )
				) as d2
			on d.accountid = d2.accountid
			and d.publicationid = d2.publicationid
			and d.drawdate = d2.drawdate
			group by d.accountid, d.publicationid
			) as tmp
		on d.accountid = tmp.accountid
		and d.publicationid = tmp.publicationid
		and d.drawdate = tmp.drawdate	
	end
	print 'End Date: ' + convert(varchar, @enddate, 1)


	--|preview draws
	select a.acctcode, d.drawdate, d.drawamount
	from #accounts tmp
	join scaccounts a
		on tmp.acctcode = a.acctcode
	join scdraws d
		on 	a.accountid = d.accountid
	where a.acctcode = @acctcode
	and d.drawdate between @begindate and @enddate
	order by a.acctcode, d.drawdate

	--|now I have a date range loop through and insert draw
	while datediff(d, @begindate, @enddate) <> 0
	begin

		--|insert draw
		if not exists (
			select *
			from scdraws
			where accountid = ( select accountid from scaccounts where acctcode = @acctcode )
			and publicationid in ( select publicationid from scaccountspubs where accountid = ( select accountid from scaccounts where acctcode = @acctcode ) )
			and datediff(d, @begindate, drawdate) = 0
		)
		begin
				INSERT	[dbo].[scDraws](
					 CompanyID
					,DistributionCenterID
					,AccountID
					,PublicationID
					,DrawWeekday
					,DrawDate
					,DeliveryDate
					,DrawAmount
					,DrawRate
					,RollupAcctID
					,LastChangeType)
		
				SELECT
					 1
					,1
					,T.AccountID
					,T.PublicationID
					,T.DrawWeekday
					,@begindate
					,@begindate
					--	if the Account AND the AccountPub is Active, go ahead and pull DefaultDraw amount
					--  otherwise, we insert zeros
					,case
						when ( AP.Active = 1 AND A.AcctActive = 1 ) then T.DrawAmount
						else 0
					 end
					--	same rule applies to rate as above
					,case
						when ( AP.Active = 1 AND A.AcctActive = 1 ) then T.DrawRate
						else 0.0
					 end
					,c.AccountID	-- Rollup Account ID ( if applicable )
					,0				-- 0 = System Change from dd_nsChangeTypes
				FROM
					scdefaultdraws T
				JOIN
					dbo.scAccounts	A  ON ( T.AccountId = A.AccountId )
				JOIN
					dbo.scAccountsPubs AP ON ( T.AccountID = AP.AccountID AND T.PublicationID = AP.PublicationID )
				left JOIN 
					dbo.scChildAccounts c on c.ChildAccountID = T.AccountID
				where
					t.drawweekday = datepart(dw, @begindate)
				and 
					a.acctcode = @acctcode
		
				set @counter = @counter + @@rowcount
		
				-- Insert the new DrawHistory records
				INSERT	[dbo].[scDrawHistory](
					 CompanyID
					,DistributionCenterID
					,AccountID
					,PublicationID
					,DrawId
					,DrawWeekday
					,DrawDate
					,ChangedDate
					,OldDraw
					,Newdraw
					,OldRate
					,NewRate
					,OldDeliveryDate
					,NewDeliveryDate
					,ChangeTypeId)
				SELECT
					 1
					,1
					,d.AccountID
					,d.PublicationID
					,d.DrawID
					,d.DrawWeekday
					,@begindate				-- drawdate
					,GETDATE()			-- user current date and time
					,d.DrawAmount
					,d.DrawAmount
					,d.DrawRate
					,d.DrawRate
					,d.DeliveryDate
					,d.DeliveryDate
					,0
				FROM 
					dbo.scDraws d
				JOIN
					dbo.scAccounts	A  ON ( d.AccountId = A.AccountId )
				JOIN
					dbo.scAccountsPubs AP ON ( d.AccountID = AP.AccountID AND d.PublicationID = AP.PublicationID )
				left JOIN 
					dbo.scChildAccounts c on c.ChildAccountID = d.AccountID
				where
					d.drawdate = @begindate
				and a.acctcode = @acctcode
		
				set @counter2 = @counter2 + @@rowcount
		end
		set @begindate = dateadd(d, 1, @begindate)
	end

	print 'Added ' + cast(@counter as varchar) + ' draw records for Account ''' + @acctcode + '''.'
	print 'Added ' + cast(@counter2 as varchar) + ' draw history records for Account ''' + @acctcode + '''.'


	fetch next from acct_cursor into @acctcode
end


close acct_cursor
deallocate acct_cursor

--|review draws
select a.acctcode, d.drawdate, d.drawamount, rollupacctid
from #accounts tmp
join scaccounts a
	on tmp.acctcode = a.acctcode
join scdraws d
	on 	a.accountid = d.accountid
order by a.acctcode, d.drawdate

drop table #accounts

rollback tran