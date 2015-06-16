/*
	Are messages being dispatched?
		When were messages last dispatched ok?
*/
select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where ( sdm_syslogmessage like 'Notify.exe (INFO)%'
	and sdm_syslogmessage not like '%Dispatched OK: 0%' )
and datediff(d, sdm_syslogdatetime, getdate()) = 0
order by sdm_syslogdatetime desc

--|  Dispatch Statuses for "Today"
select cast(convert(varchar, MessageDateTime, 1) as datetime) as [Date], MessageStatusDisplayName, count(*)
from deMessage m
join dd_deMessageStatus ddms
	on m.MessageStatusId = ddms.MessageStatusId
where datediff(d, MessageDateTime, getdate()) = 0
group by cast(convert(varchar, MessageDateTime, 1) as datetime), MessageStatusDisplayName
order by 1 desc


--|  DTI - Last time messages were processed from DTI
select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where datediff(d, sdm_syslogdatetime, getdate()) = 0
and ( sdm_syslogmessage like '%Processed%'
	and sdm_syslogmessage not like '%Processed 0%')
order by sdm_syslogdatetime desc

--|  DTI - All DTI messages
select sdm_syslogdatetime, sdm_syslogmessage
from nslogsystem
where datediff(d, sdm_syslogdatetime, getdate()) = 0
and sdm_syslogmessage like 'CCMsgTransfer.exe%'  --|DTI Only
order by sdm_syslogdatetime desc
