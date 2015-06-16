

/*
	1)  zero out future draw
	2)  zero out default draw
	3)  set ap.active = 0
	4)  set p.active = 0
	
*/

begin tran

set nocount on

declare @pub nvarchar(5)
declare @effectiveDate datetime
declare @zeroDefaultDraw int
declare @msg nvarchar(2048)


set @pub = '26 GO'
set @effectiveDate = '6/29/12'
set @zeroDefaultDraw = 1

--|  Step 1
/*
select d.DrawDate, p.PubShortName, sum(d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0)) as [DrawTotal]
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where d.DrawDate >= @effectiveDate
and p.PubShortName = @pub
group by d.DrawDate, p.PubShortName
having sum(d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0)) > 0
*/
declare @bkp_name nvarchar(50)
declare @sql nvarchar(4000)

set @bkp_name = 'support_scDraws_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
+ '_'
+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)

set @sql = 'select d.*
			into ' + @bkp_name + '
			from scdraws d
			join nspublications p
				on d.publicationid = p.publicationid
			where d.DrawDate >= ''' + convert(varchar, @effectiveDate, 1) + '''
			and p.PubShortName = ''' + @pub + '''
			and d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > 0'
exec(@sql)			

update scdraws
set DrawAmount = 0
	, AdjAmount = 0
	, AdjAdminAmount = 0
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where d.DrawDate >= @effectiveDate
and p.PubShortName = @pub
and d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > 0

set @msg = cast(@@rowcount as varchar) + ' Draw records set to zero for pub ''' + @pub + ''' where DrawDate >= ' + convert(varchar, @effectiveDate, 1) + '''.'
print @msg

--|  Step 2
if @zeroDefaultDraw = 1
begin
	set @bkp_name = 'support_scDefaultDraws_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
	+ '_'
	+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
	+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
	
	set @sql = 'select dd.*
				into ' + @bkp_name + '
				from scdefaultdraws dd
				join nspublications p
					on dd.publicationid = p.publicationid
				where p.PubShortName = ''' + @pub + '''
				and dd.DrawAmount > 0'
	exec(@sql)			


	update scdefaultdraws
	set DrawAmount = 0
	from scdefaultdraws dd
	join nspublications p
		on dd.publicationid = p.publicationid
	where 
		p.PubShortName = @pub
	and dd.drawamount > 0	
	
	set @msg = ' ' + cast(@@rowcount as varchar) + ' Default Draw records set to zero for pub ''' + @pub + '''.'
	print @msg
end	

--|  Step 3
update scaccountspubs
set active = 0
from scAccountsPubs ap
join nspublications p
	on ap.publicationid = p.publicationid
where p.pubshortname = @pub
and ap.active <> 0
set @msg = 'Deactivated ' + cast(@@rowcount as varchar) + ' AcctPub records for pub ''' + @pub + '''.'
print @msg

commit tran