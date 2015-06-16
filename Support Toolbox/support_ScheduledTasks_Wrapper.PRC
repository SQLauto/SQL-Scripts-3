IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ScheduledTasks_Wrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ScheduledTasks_Wrapper]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ScheduledTasks_Wrapper]
AS
/*
	[dbo].[support_ScheduledTasks_Wrapper]
	
	$History:  $
*/
BEGIN
	set nocount on
	
	--|  Declarations
	declare @msg nvarchar(1024)
	
	set @msg = 'support_ScheduledTasks_Wrapper procedure starting...'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
    
    declare @backup nvarchar(500)
    exec support_scDefaultDraws_Snapshot @bkp_name=@backup

    set @msg = 'scDefaultDraws snapshot captured in [' +  @backup + ']'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

	
	--|  cleanup
	set @msg = 'Starting snapshot cleanup...'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
 
	
	declare @sql nvarchar(1000)

	declare dropTable_Cursor cursor
	for
		select [name]
		from sysobjects
		where name like 'scDefaultDraws_Snapshot%'
		and type = 'U'
		and datediff(d, getdate(), crdate)  < -7
		--and datediff(d, '4/6/2013', crdate)  < 0

	open dropTable_Cursor 
	fetch next from dropTable_Cursor into @sql
	while @@fetch_status = 0
	begin
		set @sql = 'drop table ' + @sql
		exec(@sql)
		fetch next from dropTable_Cursor into @sql
	end	

	close dropTable_Cursor
	deallocate dropTable_Cursor

	set @msg = 'Snapshot cleanup completed successfully.'
    print @msg
    exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
	


END
GO	

GRANT EXECUTE ON [dbo].[support_ScheduledTasks_Wrapper] TO [nsUser]
GO