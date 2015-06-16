set nocount on

declare @CustomExportName nvarchar(50)
declare @CustomExportDescription nvarchar(128)
declare @CustomExportConfigFileName nvarchar(512)

/*----------------------------------------------------------------------*/

set @CustomExportName = 'CustomExportConfigFile_Returns_DTI'		--| Must have CustomExportConfigFile prefix
set @CustomExportDescription = 'CustomExport_Returns_DTI'	--| Displayed in Drop-Down
set @CustomExportConfigFileName = 'CustomExport_Returns_DTI.xml'


/*----------------------------------------------------------------------*/

if exists (
	select 1 
	from syncSystemProperties
	where SysPropertyValue = @CustomExportConfigFileName
)
begin
	update syncSystemProperties
	set SysPropertyName = @CustomExportName
		, SysPropertyDescription = @CustomExportDescription
	where SysPropertyValue = @CustomExportConfigFileName

		if @@rowcount > 0
			print 'Custom Export ''' + @CustomExportDescription + ''' already exists.  Updated config file to ' + @CustomExportConfigFileName
		else
			print 'Custom Export ''' + @CustomExportDescription + ''' already exists with value ''' + @CustomExportConfigFileName + ''''
end
else
begin
	insert into syncSystemProperties ( SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display )
	select 
		max(SystemPropertyId) + 1							as [Id]
		, @CustomExportName									as [Name]
		, @CustomExportDescription							as [Description]  
		, @CustomExportConfigFileName						as [Value]
		, 0													as [Display]
	from syncSystemProperties
	
	if @@rowcount > 0
		print 'Successfully added Custom Export ( ' + @CustomExportDescription + ', ' + @CustomExportConfigFileName + ' )'
end	

select *
from syncSystemProperties
where SysPropertyDescription like '%customexport%'

--delete from syncSystemProperties
--where SystemPropertyId = 89