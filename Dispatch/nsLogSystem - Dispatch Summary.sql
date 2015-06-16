select sdm_syslogdatetime, sdm_syslogmessage 
from nslogsystem
where datediff(d, sdm_syslogdatetime, getdate()) = 0
and sdm_syslogmessage like '%DISPATCH SUMMARY%'
order by sdm_syslogdatetime desc