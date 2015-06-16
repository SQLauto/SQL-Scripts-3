
select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where datediff(d, sdm_syslogdatetime, '3/13/2011') = 0
and sdm_syslogmessage like 'Succesfully assigned Message Targets to % messages.  Stored Procedure:  de_NewMessages_Assign.'
and sdm_syslogmessage not like 'Succesfully assigned Message Targets to 0 messages.  Stored Procedure:  de_NewMessages_Assign.'
order by sdm_syslogdatetime desc


select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where datediff(d, sdm_syslogdatetime, '3/13/2011') = 0
and sdm_syslogmessage like 'Notify.exe (INFO)%'
and sdm_syslogmessage not like '%Msgs pending: 0%'
order by sdm_syslogdatetime desc

