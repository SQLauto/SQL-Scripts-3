SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[support_Exports]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[support_Exports]
GO


CREATE PROCEDURE dbo.support_Exports
(
	@exportDate datetime = null
)
As
/*=========================================================

==========================================================*/
begin
    set nocount on

	declare @offset int

	select @offset = sysPropertyValue
	from syncSystemProperties
	where sysPropertyName = 'CompanyTimeOffset'

	print @offset

	select 
		convert(varchar, x.LastUpdated, 1) as [ExportDate]
		, x.LastUpdated
		, u.UserName
		, typ.ExportTypeDescription
		, case x.ExchangeStatus
			when 3 then 'SUCCESS'
			when 4 then 'FAILURE'
			end as [Status]
		, b.SLTimeStamp as [ExportStart]
		, e.SLTimeStamp	as [ExportEnd]
		, r.logmessage as [Rows]
		, cast(
			( DATEDIFF(	SECOND
				, dateadd(hour, -1*@offset, b.sltimestamp)
				, dateadd(hour, -1*@offset, e.sltimestamp) ) / 3600 ) as varchar )
			+ 'h ' + 
			cast(
			( DATEDIFF(	SECOND
				, dateadd(hour, -1*@offset, b.sltimestamp)
				, dateadd(hour, -1*@offset, e.sltimestamp) ) % 3600 ) / 60 as varchar )
			+ 'm ' +
			cast(
			( DATEDIFF(	SECOND
				, dateadd(hour, -1*@offset, b.sltimestamp)
				, dateadd(hour, -1*@offset, e.sltimestamp) ) % 60 ) as varchar )
			+ 's ' as [Duration]
		 , f.ExportFile
		 , x.GroupId
--	into #exports	 		
	from (
		select *
		from scDataExchangeControls ex
		where ( 
			( @exportdate is not null and datediff(d, ex.LastUpdated, @exportDate) = 0 )
			or 
			( @exportdate is null and DataExchangeControlId > 0 )
		)
	) as x
	join dd_scExportTypes typ
		on x.ExchangeTypeId = typ.ExportTypeId
	left join users u
		on x.UserId = u.UserId	
	left join (
		select sltimestamp, logmessage, groupid
		from syncsystemlog
		where LogMessage like 'Data Export Started%'
		) as b
		on x.GroupId = b.GroupId
	left join (
		select sltimestamp, logmessage, groupid
		from syncsystemlog
		where LogMessage like 'Data Export Completed%'
		or LogMessage like 'Data Export Failed%'
		or LogMessage like 'DataExport Failed%'
	) as e
		on x.GroupId = e.GroupId
	left join (
		select replace(logmessage, ' total rows written to file.','') as logmessage, groupid
		from syncsystemlog
		where LogMessage like '%total rows written to file.'
	) as r     
	     on x.GroupId = r.GroupId
	left join (
		select sltimestamp, /*replace(logmessage,'Export File: ', '')*/logmessage as [ExportFile], groupid
		from syncsystemlog
		where LogMessage like 'Export File:%'
		) as f
		on x.GroupId = f.GroupId	
	order by x.LastUpdated desc	
end
go

exec dbo.support_Exports '12/19/2012'
	