if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scRemoveImportDuplicates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scRemoveImportDuplicates]
GO

CREATE PROCEDURE [dbo].[scRemoveImportDuplicates]
	@logToMessages int = 1	
AS
/*=========================================================
	scRemoveImportDuplicates

	Removes duplicates from scManifestLoad table, where
	a duplicate is two or more records with the same DrawDate,
	AcctCode and PublicationId.

	Each version must be customized for a specific customer or
	circ system.
	
	This version is for PBS/DTI.

	$History: /Gazette/Customer Specific/PBS/Database/sprocs/dbo.scRemoveImportDuplicates.PRC $
-- 
-- ****************** Version 2 ****************** 
-- User: kerry   Date: 2010-02-03   Time: 11:41:33-05:00 
-- Updated in: /Gazette/Customer Specific/PBS/Database/sprocs 
-- Case 12221 - Add detailed logging 
-- 
-- ****************** Version 1 ****************** 
-- User: kerry   Date: 2009-10-16   Time: 17:43:54-04:00 
-- Updated in: /Gazette/Customer Specific/PBS/Database/sprocs 
-- Case 6616 - Removal of duplicates in manifest file during import 

==========================================================*/
BEGIN
	set nocount on
	
	declare @date nvarchar(10)
	declare @acct nvarchar(8)
	declare @pub nvarchar(8)
	declare @draw nvarchar(8)
	declare @dupCount int
	declare @dupSets int
	declare @totalDupCount int
	declare @counter int
	declare @msg nvarchar(4000)
	declare @msg_detailed nvarchar(4000)
	
	declare @groupId int
	select @groupId = GroupId from groups where GroupName = 'System Administrators'
	
	declare @fromId int
	select @fromId = UserId from Users where UserName = 'support@syncronex.com'
		
	declare @nowTime datetime, @compareTime datetime
	set @nowTime = getDate()
	set @compareTime = dateadd(Month, -2, @nowTime)


	set @msg = 'scRemoveImportDuplicates: Procedure started'
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	print @msg

	select @dupSets = count(*), @totalDupCount = isnull( sum([DupCount]), 0 )
	from (
		select <column_draw_date, sysname, draw_date>, <column_acct_code, sysname, acct_code>, <column_publication, sysname, publication>, count(*) as [DupCount]
		from scManifestLoad
		group by <column_draw_date, sysname, draw_date>, <column_acct_code, sysname, acct_code>, <column_publication, sysname, publication>
		having count(*) > 1
		) dups
	
	if @totalDupCount = 0
	begin
		set @msg = ' No duplicates encountered.'
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg		
		print @msg		
	end
	else
	begin
		set @msg_detailed = 
			case @dupSets 
				when 1 then ' ' + cast(@dupSets as nvarchar) + ' set'
				else ' ' + cast(@dupSets as nvarchar) + ' sets'
				end
			+ ' of duplicates found (' + cast(@totalDupCount as nvarchar) + ' records).'

		print @msg_detailed
		
		set @msg_detailed = @msg_detailed + '  Duplicate Accounts: '
		
		print ' Deleting duplicates...'
		declare dup_cursor cursor
		for 
			select <column_draw_date, sysname, draw_date>, <column_acct_code, sysname, acct_code>, <column_publication, sysname, publication>, count(*) as [DupCount]
			from scManifestLoad
			group by <column_draw_date, sysname, draw_date>, <column_acct_code, sysname, acct_code>, <column_publication, sysname, publication>
			having count(*) > 1
		
		open dup_cursor
		fetch next from dup_cursor into @date, @acct, @pub, @dupCount
		while @@fetch_status = 0
		begin
			while @dupCount > 1
			begin
				set rowcount 1
		
				select @draw = <column_draw_amount, sysname, draw_amount>
				from scManifestLoad
				where <column_draw_date, sysname, draw_date> = @date
				and <column_acct_code, sysname, acct_code> = @acct
				and <column_publication, sysname, publication> = @pub
		
				delete from scManifestLoad
				where <column_draw_date, sysname, draw_date> = @date
				and <column_acct_code, sysname, acct_code> = @acct
				and <column_publication, sysname, publication> = @pub
				and <column_draw_amount, sysname, draw_amount> = @draw
		
				set rowcount 0
				
				--|  Insert a detailed msg into syncSystemLog about the duplicate removed
				set @msg = '  Duplicate removed from scManifestLoad.  Details: AcctCode=''' + @acct + ''''
						+ ', Pub=''' + @pub + ''''
						+ ', DrawDate=''' + @date + '''' 
						+ ', DrawAmount=''' + @draw + '''' 
				exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
				print @msg

				--|  Build a msg containing a comma-seperated list of the accounts being deleted.  
				--|    The max length of the message is 3000 so we check to see if we have enough 
				--|    room to add the current detail plus extra to add a final summary message.
				if len( @msg_detailed + ', ' + @acct) <= 2950
				begin
					if right( rtrim(@msg_detailed), 1 ) = ':'  --|  ':' indicates first account
						set @msg_detailed = @msg_detailed + @acct
					else
						set @msg_detailed = @msg_detailed + ', ' + @acct
				end
				else
				begin
					--|  Log the current message and reset the string
					if ( @logToMessages = 1 )
					begin
						-- Post a message
						--   From: admin@SingleCopy.com
						--   To: (Everyone) group
						--   Priority: High (3)
						--   Status: None (3)
						--   Type: Issue (2)
						--   State: Unread (1)
						
						exec nsMessages_INSERTNOTALREADY 'Duplicates in import', @msg_detailed, 1, 0, 1, @nowTime, 3, 3, 2, 1, @compareTime, 0
					end					
					
					set @msg_detailed = '  Duplicate Accounts (cont''d): ' +  @acct 
				end
		
				set @dupCount = @dupCount - 1
				set @counter = isnull(@counter,0) + 1
			end
			fetch next from dup_cursor into @date, @acct, @pub, @dupCount
		end
		
		close dup_cursor
		deallocate dup_cursor

		set @msg = ' Summary:  ' + cast(@counter as varchar) + ' duplicate ' + case @counter when 1 then 'record' else 'records' end + ' removed.'
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg		
		print @msg

		set @msg_detailed = @msg_detailed + '.  See the System Log for more details.'
		
		if ( @logToMessages = 1 )
		begin
			-- Post a message
			--   From: support@syncronex.com
			--   To: 'System Administrators'
			--   Priority: High (3)
			--   Status: None (3)
			--   Type: Issue (2)
			--   State: Unread (1)
			
			exec nsMessages_INSERTNOTALREADY 'Duplicates in import', @msg_detailed, @fromId, 0, @groupId, @nowTime, 3, 3, 2, 1, @compareTime, 0
		end
	end

	set @msg = 'scRemoveImportDuplicates: Procedure completed successfully'
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	print @msg

END

GRANT EXECUTE ON [dbo].[scRemoveImportDuplicates] TO [nsUser]
GO
