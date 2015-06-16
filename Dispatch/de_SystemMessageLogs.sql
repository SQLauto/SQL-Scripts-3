select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where datediff(d, sdm_syslogdatetime, getdate()) = 0
order by sdm_syslogdatetime desc

select *
from systemmessagelog
where datediff(d, messagedatetime, getdate()) = 0
order by messagedatetime desc