if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchSyncSystemLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchSyncSystemLog]
GO

create  procedure dbo.SearchSyncSystemLog
	@logmessage nvarchar(2048)
	,@start datetime = null
	,@stop datetime = null
as
/*=========================================================
    SearchSyncSystemLog
    
	$History: $

==========================================================*/
begin

set nocount on

set @start = 
	case when ( @start is null ) then convert( nvarchar, current_timestamp, 1 )
	else convert( nvarchar, @start, 1 )
	end

set @stop = 
	case when ( @stop is null ) then convert( nvarchar, dateadd( d, 1, current_timestamp ), 1 )
	else convert( nvarchar, dateadd( d, 1, @stop ), 1 )
	end


select sltimestamp, logmessage
from syncsystemlog
where logmessage like '%' + @logmessage + '%'
and sltimestamp between @start and @stop
order by sltimestamp desc

end
GO

GRANT EXEC ON [dbo].[SearchSyncSystemLog] TO nsUser
GO

exec SearchSyncSystemLog 'dup', '2/24/2010'