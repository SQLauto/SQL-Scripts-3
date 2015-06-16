

--|  are there messages in the system for today?
select m.messagedatetime, m.messagestatusid, messagestatuscode, addressconcat, messagetargetid
from demessage m
join dd_demessagestatus ms
	on m.messagestatusid = ms.messagestatusid
where datediff(d, messagedatetime, getdate()) = 0
order by m.messagedatetime desc

--|  are there any errors?
select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem 
where datediff(d, sdm_syslogdatetime, getdate()) = 0
order by sdm_syslogdatetime desc

select max(sdm_syslogdatetime)
from nslogsystem 
where datediff(d, sdm_syslogdatetime, getdate()) = 0
and sdm_syslogmessage like '%Dispatched OK: %'
and sdm_syslogmessage not like '%Dispatched OK: 0%'