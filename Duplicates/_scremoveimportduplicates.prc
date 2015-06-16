USE [NSDB_CHI]
GO

/****** Object:  StoredProcedure [dbo].[scRemoveImportDuplicates]    Script Date: 01/13/2011 13:29:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scRemoveImportDuplicates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scRemoveImportDuplicates]
GO

USE [NSDB_CHI]
GO

/****** Object:  StoredProcedure [dbo].[scRemoveImportDuplicates]    Script Date: 01/13/2011 13:29:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
	declare @acctCode nvarchar(8)
	declare @pubShortName nvarchar(8)
	declare @dupCount int
	declare @dupSets int
	declare @totalDupCount int
	declare @counter int
	declare @zeroDrawCounter int
	declare @zeroDrawsRemovedCounter int
	declare @msg nvarchar(4000)
	declare @msg_detailed nvarchar(4000)
	
	declare @everyoneGroupId int
	select @everyoneGroupId = GroupId from groups where GroupName = '(System Administrators)'
	
	declare @nowTime datetime, @compareTime datetime
	set @nowTime = getDate()
	set @compareTime = dateadd(Month, -2, @nowTime)


	set @msg = 'scRemoveImportDuplicates: Procedure started'
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	print @msg

	select @dupSets = count(*), @totalDupCount = isnull( sum([DupCount]), 0 )
	from (
		select DrawDate, AcctCode, PubShortName, count(*) as [DupCount]
		from scManifestLoad
		group by DrawDate, AcctCode, PubShortName
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
			select DrawDate, AcctCode, PubShortName, count(*) as [DupCount]
			from scManifestLoad
			group by DrawDate, AcctCode, PubShortName
			having count(*) > 1
		
		open dup_cursor
		fetch next from dup_cursor into @date, @acctCode, @pubShortName, @dupCount
		while @@fetch_status = 0
		begin
			while @dupCount > 1
			begin
				select @zeroDrawCounter = COUNT(*)
				from scManifestLoad
				where DrawDate = @date
				and AcctCode = @acctCode
				and PubShortName = @pubShortName
				and Draw = 0
				
				if @zeroDrawCounter = 1
				begin
					delete from scManifestLoad
					where DrawDate = @date
					and AcctCode = @acctCode
					and PubShortName = @pubShortName
					and Draw = 0
					
					set @zeroDrawsRemovedCounter = isnull(@zeroDrawsRemovedCounter,0) + 1
				end
				else
				begin
					set rowcount 1
			
					delete from scManifestLoad
					where DrawDate = @date
					and AcctCode = @acctCode
					and PubShortName = @pubShortName
			
					set rowcount 0
				end	
				
				--|  Insert a detailed msg into syncSystemLog about the duplicate removed
				set @msg = '  Duplicate removed from scManifestLoad.  Details: AcctCode=''' 
						+ @acctCode + ''', Pub=''' + @pubShortName + ''''
						+ ', DrawDate=''' + @date + '''' 
				exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
				print @msg

				--|  Build a msg containing a comma-seperated list of the accounts being deleted.  
				--|    The max length of the message is 3000 so we check to see if we have enough 
				--|    room to add the current detail plus extra to add a final summary message.
				if len( @msg_detailed + ', ' + @acctCode) <= 2950
				begin
					if right( rtrim(@msg_detailed), 1 ) = ':'  --|  ':' indicates first account
						set @msg_detailed = @msg_detailed + @acctCode
					else
						set @msg_detailed = @msg_detailed + ', ' + @acctCode
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
						
						exec nsMessages_INSERTNOTALREADY 'Duplicates in import', @msg_detailed, 1, 0, 2, @nowTime, 3, 3, 2, 1, @compareTime, 0
					end					
					
					set @msg_detailed = '  Duplicate Accounts (cont''d): ' +  @acctCode 
				end
		
				set @dupCount = @dupCount - 1
				set @counter = isnull(@counter,0) + 1
			end
			fetch next from dup_cursor into @date, @acctCode, @pubShortName, @dupCount
		end
		
		close dup_cursor
		deallocate dup_cursor

		set @msg = ' Summary:  ' + cast(isnull(@counter,0) as varchar) + ' duplicate ' + case isnull(@counter,0) when 1 then 'record' else 'records' end + ' removed.'
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg		
		print @msg

		set @msg_detailed = @msg_detailed + '.  See the System Log for more details.'
		
		if ( @logToMessages = 1 )
		begin
			-- Post a message
			--   From: admin@SingleCopy.com
			--   To: (Everyone) group
			--   Priority: High (3)
			--   Status: None (3)
			--   Type: Issue (2)
			--   State: Unread (1)
			
			exec nsMessages_INSERTNOTALREADY 'Duplicates in import', @msg_detailed, 1, 0, 2, @nowTime, 3, 3, 2, 1, @compareTime, 0
		end
	end

	set @msg = 'scRemoveImportDuplicates: ' + cast(@zeroDrawsRemovedCounter as varchar) + ' zero draw records removed.'
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	print @msg


	set @msg = 'scRemoveImportDuplicates: Procedure completed successfully'
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	print @msg

END

GRANT EXECUTE ON [dbo].[scRemoveImportDuplicates] TO [nsUser]



GO

