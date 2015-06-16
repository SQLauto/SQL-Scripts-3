begin tran

create table #support_Exports(
ExportDate datetime
,LastUpdated datetime
,UserName nvarchar(255)
,ExportTypeDescription nvarchar(80)
,Status nvarchar(20)
,ExportStart datetime
,ExportEnd datetime
,Duration nvarchar(12)
,ExportFile nvarchar(max)
,GroupId uniqueidentifier
)

insert into #support_Exports
exec support_Exports @exportDate=null

select ExportDate, LastUpdated, ExportTypeDescription, ExportFile, Status, UserName, 
from #support_Exports
where ExportTypeDescription = 'Adjustment Export'

rollback tran