begin tran

declare @counter int
declare @date datetime

set @counter = 1

create table #MonthsWithZeroDraw (
	  AccountId int
	, AcctCode nvarchar(20)
	, PublicationId int
	, PubShortName nvarchar(5)
	, MonthsWithZeroDraw int
	)

while @counter <= 12
begin
	set @date = convert(varchar, dateadd(month, -1 * @counter, getdate() ), 1)
	select @date as [Threshold]

	select a.accountid, acctcode, p.publicationid, pubshortname, sum(drawamount) as [DrawAmount]
	into #zeroDrawAccounts
	from scaccounts a
	join scdraws d
		on a.accountid = d.accountid
	join nspublications p
		on d.publicationid = p.publicationid
	where drawdate > @date
	group by a.accountid, acctcode, p.publicationid, pubshortname
	having sum(drawamount) = 0

	update #MonthsWithZeroDraw
	set MonthsWithZeroDraw = @counter
	from #zeroDrawAccounts tmp
	join #MonthsWithZeroDraw m
		on tmp.Accountid = m.AccountId
		and tmp.PublicationId = m.PublicationId
	
	insert into #MonthsWithZeroDraw ( AccountId, AcctCode, PublicationId, PubShortName, MonthsWithZeroDraw )
	select z.accountid, z.acctcode, z.publicationid, z.pubshortname, @counter
	from #zeroDrawAccounts z
	left join #MonthsWithZeroDraw tmp
		on z.accountid = tmp.accountid
		and z.publicationid = tmp.publicationid
	where tmp.accountid is null

	drop table #zeroDrawAccounts

	set @counter = @counter + 1
end

select AcctCode, PubShortName, MonthsWithZeroDraw
from #MonthsWithZeroDraw
order by MonthsWithZeroDraw desc, AcctCode
drop table #MonthsWithZeroDraw

rollback tran