
begin tran
/*
	Update Return Amounts based on syncSystemLog error message (v.2.5)
*/
select d.DrawAmount
	, adj.adjamount
	, adj.adjadminamount
	, ret.retamount
	, r.[returns]
into support_scReturns_Backup_05052011
from (
	select 
		SystemLogId
		, substring( logmessage
			, charindex('drawid=', logmessage) + len('drawid=')
			, ( charindex(' date=', logmessage) - (charindex('drawid=', logmessage) + len('drawid=')) )
			) as [drawid]
		, substring( logmessage
			, charindex('return=', logmessage) + len('return=')
			, len(logmessage) - ( charindex('return=', logmessage) + len('return=') - 1 )
		) as [returns]
	from syncsystemlog
	where logmessage like 'Returns > net draw error for drawid=% date=05/%/11%'
	) as r
join scdraws d
	 on r.drawid = d.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
left join screturns ret
	on d.drawid = ret.drawid

update scReturns
set retamount = r.[returns]
from (
	select 
		SystemLogId
		, substring( logmessage
			, charindex('drawid=', logmessage) + len('drawid=')
			, ( charindex(' date=', logmessage) - (charindex('drawid=', logmessage) + len('drawid=')) )
			) as [drawid]
		, substring( logmessage
			, charindex('return=', logmessage) + len('return=')
			, len(logmessage) - ( charindex('return=', logmessage) + len('return=') - 1 )
		) as [returns]
	from syncsystemlog
	where logmessage like 'Returns > net draw error for drawid=% date=05/%/11%'
	) as r
join scdraws d
	 on r.drawid = d.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
left join screturns ret
	on d.drawid = ret.drawid
where isnull(r.[Returns],0) <= ( d.drawamount + isnull(adj.adjamount,0) + isnull(adj.adjadminamount,0) )
and ret.retamount is not null

insert into scReturns
select 1, 1, d.AccountId, d.PublicationId, d.DrawWeekday, d.DrawId
	, 1
	, getdate()
	, d.drawdate
	, r.[returns]
	, null
	, null
	, null
from (
	select 
		SystemLogId
		, substring( logmessage
			, charindex('drawid=', logmessage) + len('drawid=')
			, ( charindex(' date=', logmessage) - (charindex('drawid=', logmessage) + len('drawid=')) )
			) as [drawid]
		, substring( logmessage
			, charindex('return=', logmessage) + len('return=')
			, len(logmessage) - ( charindex('return=', logmessage) + len('return=') - 1 )
		) as [returns]
	from syncsystemlog
	where logmessage like 'Returns > net draw error for drawid=% date=05/%/11%'
	) as r
join scdraws d
	 on r.drawid = d.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
left join screturns ret
	on d.drawid = ret.drawid
where isnull(r.[Returns],0) <= ( d.drawamount + isnull(adj.adjamount,0) + isnull(adj.adjadminamount,0) )
and ret.retamount is null

insert into scReturnsAudit
select 1, 1, d.AccountId, d.PublicationId, d.DrawWeekday, d.DrawId
	, 1, 1
	, getdate()
	, 3
	, 'Return Amount'
	, r.[returns]
from (
	select 
		SystemLogId
		, substring( logmessage
			, charindex('drawid=', logmessage) + len('drawid=')
			, ( charindex(' date=', logmessage) - (charindex('drawid=', logmessage) + len('drawid=')) )
			) as [drawid]
		, substring( logmessage
			, charindex('return=', logmessage) + len('return=')
			, len(logmessage) - ( charindex('return=', logmessage) + len('return=') - 1 )
		) as [returns]
	from syncsystemlog
	where logmessage like 'Returns > net draw error for drawid=% date=05/%/11%'
	) as r
join scdraws d
	 on r.drawid = d.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
left join screturns ret
	on d.drawid = ret.drawid
where isnull(r.[Returns],0) <= ( d.drawamount + isnull(adj.adjamount,0) + isnull(adj.adjadminamount,0) )
and ret.retamount is null

select  d.DrawAmount
	, adj.adjamount
	, adj.adjadminamount
	, ret.retamount
	, r.[returns]
from (
	select 
		SystemLogId
		, substring( logmessage
			, charindex('drawid=', logmessage) + len('drawid=')
			, ( charindex(' date=', logmessage) - (charindex('drawid=', logmessage) + len('drawid=')) )
			) as [drawid]
		, substring( logmessage
			, charindex('return=', logmessage) + len('return=')
			, len(logmessage) - ( charindex('return=', logmessage) + len('return=') - 1 )
		) as [returns]
	from syncsystemlog
	where logmessage like 'Returns > net draw error for drawid=% date=05/%/11%'
	) as r
join scdraws d
	 on r.drawid = d.drawid
left join scdrawadjustments adj
	on d.drawid = adj.drawid
left join screturns ret
	on d.drawid = ret.drawid


commit tran