begin tran

select *
from scdefaultdraws
where accountid = ( select accountid from scaccounts where acctcode = '2272008' )
order by publicationid, drawweekday

select AccountId, PublicationId, Mon, Tue, Wed, Thu, Fri, Sat, Sun
into #tmpDefaultDraws
from adhoc_min_draw tmp
join scaccounts a
	on tmp.acctcode = a.acctcode
join nspublications p
	on tmp.pub = p.pubshortname

declare @weekday int
set @weekday = 1
while @weekday <= 7
begin
print @weekday
/*
	select Case @weekday
		when 1 then Sun
		when 2 then Mon
		when 3 then Tue
		when 4 then Wed
		when 5 then Thu
		when 6 then Fri
		when 7 then Sat
		end as [New Draw]
		, ForecastMinDraw
	from #tmpDefaultDraws tmp
	join scdefaultdraws dd
		on tmp.accountid = dd.accountid
		and tmp.publicationid = dd.publicationid
		and dd.drawweekday = @weekday 
*/
	update scDefaultDraws
	set ForecastMinDraw = Case @weekday
		when 1 then Sun
		when 2 then Mon
		when 3 then Tue
		when 4 then Wed
		when 5 then Thu
		when 6 then Fri
		when 7 then Sat
		end 
	from #tmpDefaultDraws tmp
	join scdefaultdraws dd
		on tmp.accountid = dd.accountid
		and tmp.publicationid = dd.publicationid
		and dd.drawweekday = @weekday 
/*
	select Case @weekday
		when 1 then Sun
		when 2 then Mon
		when 3 then Tue
		when 4 then Wed
		when 5 then Thu
		when 6 then Fri
		when 7 then Sat
		end as [New Draw]
		, ForecastMinDraw
	from #tmpDefaultDraws tmp
	join scdefaultdraws dd
		on tmp.accountid = dd.accountid
		and tmp.publicationid = dd.publicationid
		and dd.drawweekday = @weekday
*/
	set @weekday = @weekday + 1
end

drop table #tmpdefaultdraws

select *
from scdefaultdraws
where accountid = ( select accountid from scaccounts where acctcode = '2272008' )
order by publicationid, drawweekday

commit tran