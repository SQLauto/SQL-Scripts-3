insert into syncSystemLog ( 
	  LogMessage
	, SLTimeStamp
	, ModuleId
	, SeverityId
	, CompanyId
	, [Source]
	--, GroupId 
	)
select 
	 ''
		as [LogMessage]
	, getdate() as [SLTimeStamp]
	, 2 as [ModuleId]	--|2=SingleCopy
	, 1 as [SeverityId] --|1=Warning
	, 1 as [CompanyId]
	, N'' as [Source]   --|nvarchar(100)
	--, newid() as [GroupId]
from 