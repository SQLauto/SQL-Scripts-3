

select logmessage
	,  cast( substring(logmessage, 26, 2)
	+ '/' + substring(logmessage, 28, 2)
	+ '/' + substring(logmessage, 22, 4) as datetime )
	/*+ ' ' + substring(logmessage, 31, 2)
	+ ':' + substring(logmessage, 33, 2)
	+ ':' + substring(logmessage, 35, 2) as datetime )*/
from syncsystemlog
where logmessage like '%returns_%'
and sltimestamp > '10/11/2010'

select logmessage, cast(right(logmessage, 17) as datetime) as [exports]
from syncsystemlog
where logmessage like 'Data export started%'
and sltimestamp > '10/11/2010'