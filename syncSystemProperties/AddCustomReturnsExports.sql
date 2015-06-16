begin tran
/*
	Add a custom return and custom adjustment export for each publication
*/

set nocount on

declare @CustomExportPropertyName nvarchar(256)
declare @CustomExportDescription nvarchar(256)
declare @CustomExportConfigFileName nvarchar(1024)
declare @pub nvarchar(5)

--|  'CustomExportConfigFile' is expected by the Custom Export web interface 
--|  DO NOT CHANGE!

declare pub_cursor cursor
for 
	select 'DTI'
	--union all select 'DTI'

open pub_cursor
fetch next from pub_cursor into @pub
while @@fetch_status = 0
begin

	set @CustomExportPropertyName = 'CustomExportConfigFile_Returns_' + @pub
	set @CustomExportDescription = 'CustomExport_Returns_' + @pub
	set @CustomExportConfigFileName = 'CustomExport_Returns_' + @pub + '.xml'


	if exists (
		select 1 
		from syncSystemProperties
		where SysPropertyName = @CustomExportPropertyName
	)
	begin
		update syncSystemProperties
		set SysPropertyValue = @CustomExportConfigFileName
			, SysPropertyDescription = @CustomExportDescription
		where SysPropertyName = @CustomExportPropertyName
		and ( SysPropertyValue <> @CustomExportConfigFileName
			or SysPropertyDescription <> @CustomExportDescription )
		
		if @@rowcount > 0
			print 'Custom Export ''' + @CustomExportPropertyName + ''' already exists.  Updated config file to ' + @CustomExportConfigFileName
		else
			print 'Custom Export ''' + @CustomExportPropertyName + ''' already exists with value ''' + @CustomExportConfigFileName + ''''
	end
	else
	begin
		insert into syncSystemProperties ( SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display )
		select 
			max(SystemPropertyId) + 1		as [Id]
			, @CustomExportPropertyName		as [Name]
			, @CustomExportDescription		as [Description]  
			, @CustomExportConfigFileName	as [Value]
			, 0
		from syncSystemProperties
		
		if @@rowcount > 0
			print 'Successfully added Custom Export ( ' + @CustomExportDescription + ', ' + @CustomExportConfigFileName + ' )'
	end	
fetch next from pub_cursor into @pub
end

close pub_cursor
deallocate pub_cursor

select *
from syncSystemProperties
where SysPropertyName like 'CustomExportConfigFile%'

commit tran