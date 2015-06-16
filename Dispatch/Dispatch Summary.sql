;with cteDispatchLogs 
	--(
	--SDM_SysLogDateTime
	--, SDM_SysLogMessage
	--, Pending
	--, Dispatched
	--, Error
	--)
as (

	select SDM_SysLogDateTime, SDM_SysLogMessage 
		, len( substring( sdm_syslogmessage
				, charindex('Msgs pending: ', SDM_SysLogMessage, 0) + LEN('Msgs pending: ')
				, charindex('Dispatched OK: ', SDM_SysLogMessage, 0) - (charindex('Msgs pending: ', SDM_SysLogMessage, 0) + LEN('Msgs pending: ') )
			)) as [Pending]
		, len( REPLACE( substring( sdm_syslogmessage
				, charindex('Msgs pending: ', SDM_SysLogMessage, 0) + LEN('Msgs pending: ')
				, charindex('Dispatched OK: ', SDM_SysLogMessage, 0) - (charindex('Msgs pending: ', SDM_SysLogMessage, 0) + LEN('Msgs pending: ') )
			
			), ' ','') ) as test
		, substring( sdm_syslogmessage
				, charindex('Dispatched OK: ', SDM_SysLogMessage, 0) + LEN('Dispatched OK: ')
				, charindex('Dispatch erroRSDispatchList: ', SDM_SysLogMessage, 0) - (charindex('Dispatched OK: ', SDM_SysLogMessage, 0) + LEN('Dispatched OK: ') )
			) as [Dispatched]
		, substring( sdm_syslogmessage
				, charindex('Dispatch erroRSDispatchList: ', SDM_SysLogMessage, 0) + LEN('Dispatch erroRSDispatchList: ')
				, charindex('Message Target', SDM_SysLogMessage, 0) - (charindex('Dispatch erroRSDispatchList: ', SDM_SysLogMessage, 0) + LEN('Dispatch erroRSDispatchList: ') )
			) as [Error]	
	from nsLogSystem l
	where SDM_SysLogMessage like '%DISPATCH SUMMARY%'
	--where DATEDIFF(d, sdm_syslogdatetime, getdate()) = 0

)
select *
from cteDispatchLogs
--where ltrim(rtrim(pending)) <> '0'

order by SDM_SysLogDateTime desc


--select *
--from nsLogSystem

--Notify.exe (INFO).    DISPATCH SUMMARY  Msgs pending: 3  Dispatched OK: 0  Dispatch erroRSDispatchList: 3  Message target not in SDMConfig..Logins: 0  SubscriberID missing from SDMConfig..Logins: 0  