/*
	reset data export
*/

	select *
	from (
		select SysPropertyValue as [Running]
		from syncSystemProperties 
		where SysPropertyName = 'DataExportRunning'
		) as running
	join (
		select SysPropertyValue as [Requested]
		from syncSystemProperties 
		where SysPropertyName = 'RunDataExport'
		) as requested
	on 1 = 1
	
	update syncSystemProperties
	set SysPropertyValue = 'false'
	where SysPropertyName = 'DataExportRunning'


	update syncSystemProperties
	set SysPropertyValue = 'false'
	where SysPropertyName = 'RunDataExport'

	select *
	from (
		select SysPropertyValue as [Running]
		from syncSystemProperties 
		where SysPropertyName = 'DataExportRunning'
		) as running
	join (
		select SysPropertyValue as [Requested]
		from syncSystemProperties 
		where SysPropertyName = 'RunDataExport'
		) as requested
	on 1 = 1
