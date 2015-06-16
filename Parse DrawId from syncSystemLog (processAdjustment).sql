

select substring( logmessage
		, charindex('drawid ''', logmessage) + len('drawid ''')
		, ( charindex(' but that draw', logmessage) - (charindex('drawid ''', logmessage) + len('drawid ''')) ) - 1
		) as [drawaid]
from syncsystemlog
where logmessage like '%processAdjustment%'