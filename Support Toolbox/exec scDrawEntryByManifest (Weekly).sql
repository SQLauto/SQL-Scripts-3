
declare @mtid int
declare @selectedDate datetime

set @selectedDate = '11/10/2013'

--print @@datefirst
if not ( @@DATEFIRST = 7 )
	set datefirst 7

declare @firstDate datetime
declare @lastDate datetime

if ( DATEPART( dw, @selectedDate) = 1 )
begin
	set @firstDate = @selectedDate
end	
else
begin
	set @firstDate = CONVERT( DATE, DATEADD( wk, DATEDIFF(wk,0,@selectedDate) - 1 , 0)  )
end	

set @lastDate = DATEADD(d, 6, @firstDate )
print @firstDate
print @lastDate


select @mtid = ManifestTemplateId
from scManifestTemplates
where MTCode = '0995'


exec scDrawEntryByManifest 1, 1, @mtid, @firstDate, @lastDate, @selectedDate


