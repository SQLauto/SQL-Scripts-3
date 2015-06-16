begin tran
/*
	Pulls draw forward from "source" draw date and applies it to "target" draw date
*/
set nocount on

declare @sourceDate datetime
declare @targetDate datetime
declare @pub nvarchar(5)

set @sourceDate = '3/22/2011'
set @targetDate = '3/29/2011'
set @pub = null

--|  Create backup table to allow revert or to produce a Before/After report
declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)

set @bkp_name = 'supportBackup_scDraws_' + case when isnull( @pub, '') <> '' then @pub + '_' else '' end 
	+ right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
	+ '_'
	+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
	+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
--print 'Backup Name:  ' + @bkp_name

set @sql = '
select d.DrawId, d.AccountID, d.PublicationID, d.DrawDate, d.DrawWeekday, d.DrawAmount, d.DrawRate
into ' + @bkp_name + '
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where d.DrawDate = ''' + convert(varchar, @targetDate, 1) + ''''
+ case when isnull( @pub, '') <> '' then '
and p.PubShortName = ''' + @pub + ''''	else ''	end

exec (@sql)
print cast(@@rowcount as varchar) + ' draw records inserted into ' + @bkp_name

--| Update Target Date with Source Draw
;with cteSourceDraw as (
	select d.DrawID as [sourceDrawId], d.AccountID, d.PublicationID, d.DrawDate, d.DrawWeekday, d.DrawAmount, d.DrawRate
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where d.DrawDate = @sourceDate
	and ( 
		( @pub is null and p.PublicationId > 0 )
		or 
		( @pub is not null and p.PubShortName = @pub )	
	)
)
update scDraws
set DrawAmount = src.DrawAmount
from scDraws tgt
join cteSourceDraw src
	on tgt.AccountID = src.AccountID
	and tgt.PublicationID = src.PublicationID
	and tgt.DrawWeekday = src.DrawWeekday
where tgt.DrawDate = @targetDate
and ( src.DrawAmount <> tgt.DrawAmount )
print cast(@@rowcount as varchar) + ' draw records updated where source draw <> target draw'

;with cteSourceRates as (
	select d.DrawID as [sourceDrawId], d.AccountID, d.PublicationID, d.DrawDate, d.DrawWeekday, d.DrawRate
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where d.DrawDate = @sourceDate
	and ( 
		( @pub is null and p.PublicationId > 0 )
		or 
		( @pub is not null and p.PubShortName = @pub )	
	)
)
update scDraws
set DrawRate = src.DrawRate
from scDraws tgt
join cteSourceRates src
	on tgt.AccountID = src.AccountID
	and tgt.PublicationID = src.PublicationID
	and tgt.DrawWeekday = src.DrawWeekday
where tgt.DrawDate = @targetDate
and src.DrawRate <> tgt.DrawRate
and ( 
	    src.DrawRate > 0
	and tgt.DrawRate = 0 
)
print cast(@@rowcount as varchar) + ' draw records updated where source rate <> target rate (source rate > 0, target rate = 0)'
print ''

--|  Display Results
set @sql = '
select a.AcctCode, p.PubShortName, cd.DrawDate, tgt.DrawAmount as [Draw (before update)], cd.DrawAmount as [Draw (after update)]
	, tgt.DrawRate as [Rate (before update)], cd.DrawRate as [Rate (aftter update)]
from ' + @bkp_name + ' tgt
join scDraws cd
	on tgt.DrawId = cd.DrawID
join scAccounts a
	on cd.AccountID = a.AccountID
join nsPublications p
	on cd.PublicationID = p.PublicationID
where ( cd.DrawAmount <> tgt.DrawAmount
	or cd.DrawRate <> tgt.DrawRate )
order by a.AcctCode, p.PubShortName'

--print @sql
exec (@sql)

rollback tran


