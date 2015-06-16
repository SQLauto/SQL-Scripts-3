begin tran
/*
	Revert to "old draw"

	Display draw history/last change information for a given drawdate
*/

declare @drawdate datetime

set @drawdate = '12/25/2011'
--/*
	declare @bkp_name nvarchar(50)
	declare @sql nvarchar(4000)

	set @bkp_name = 'backup_scDraws_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
	+ '_'
	+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
	+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
	set @sql = 'select *
				into ' + @bkp_name + '
				from scDraws
				where DrawDate = ''' + convert(varchar, @drawdate, 1) + ''''
	exec(@sql)			
	--print @sql
--*/

;with cteLastDrawChange
as (
	select dh.*
	from scDrawHistory dh
	join (
		select drawid, MAX(changeddate) as changeddate
		from scDrawHistory
		where DATEDIFF(d, drawdate, @drawdate) = 0
		group by drawid
		) lastchange
	on dh.drawid = lastchange.drawid
	and dh.changeddate = lastchange.changeddate
) 
select d.DrawID 
	, a.AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount [Draw (current]
	, typ.ChangeTypeDescription
	, dh.olddraw, dh.newdraw
into #preview
from scDraws d
join cteLastDrawChange dh
	on d.DrawID = dh.drawid
join scAccounts a
	on d.AccountID = a.AccountID	
join nsPublications p
	on d.PublicationID = p.PublicationID	
join dd_nsChangeTypes typ
	on dh.changetypeid = typ.ChangeTypeID	
where d.DrawDate = @drawdate

select *
from #preview

update scDraws 
set DrawAmount = tmp.olddraw
from scDraws d
join #preview tmp
	on d.DrawID = tmp.drawid

rollback tran