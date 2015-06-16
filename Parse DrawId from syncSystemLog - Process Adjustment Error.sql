
select
	d.drawid, d.deliverydate, d.drawdate
	, did.sltimestamp
	, did.logmessage
from scdraws d
join (
	select substring( logmessage
			, charindex('drawid ''', logmessage) + len('drawid ''')
			, ( charindex(' but that draw', logmessage) - (charindex('drawid ''', logmessage) + len('drawid ''')) ) - 1
			) as [drawid]
		, sltimestamp
		, logmessage
	from syncsystemlog
	where logmessage like '%processAdjustment%'
	) as did
on d.drawid = did.drawid
order by sltimestamp desc