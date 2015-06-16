
insert into syncSystemLog ( 
	  LogMessage
	, SLTimeStamp
	, ModuleId
	, SeverityId
	, CompanyId
	, [Source]
	--, GroupId 
	)
select distinct 
	 'Account ''' + a.AcctCode + ''' on Manifest/Sequence ''' + mt.MTCode + '/' + mst.Code
	  + ''' was split between drop sequences ' + cast(tmp.NewSequence as varchar) + ' and ' + cast(tmp.Sequence as varchar) 
	  + '.  Publications were consolidated on drop sequence ' + cast(tmp.NewSequence as varchar) + '.'
		as [LogMessage]
	, getdate() as [SLTimeStamp]
	, 2 as [ModuleId]	--|2=SingleCopy
	, 1 as [SeverityId] --|1=Warning
	, 1 as [CompanyId]
	, N'' as [Source]   --|nvarchar(100)
	--, newid() as [GroupId]
	