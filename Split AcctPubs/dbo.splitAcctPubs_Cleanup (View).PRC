USE [nsdb_ajc_newtrack]
GO
/****** Object:  StoredProcedure [dbo].[splitAcctPubs_Cleanup]    Script Date: 12/20/2011 12:02:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  procedure [dbo].[splitAcctPubs_Cleanup]
as
/*=========================================================
    dbo.splitAcctPubs_Cleanup.PRC
    

	$History:  $

==========================================================*/
begin
	set nocount on

	declare @msg nvarchar(1024)

	select @msg = 'splitAcctPubs_Cleanup:  Procedure started...'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg

	select splits.ManifestTemplateId, splits.ManifestSequenceTemplateId, splits.Frequency, splits.AccountId
		, msi.ManifestSequenceItemId 
		, ap.AccountPubId
		, ap.PublicationId
		, Sequence
		, SplitCount
	into #splitDetails
	from (  
		--|  splits
		select ManifestTemplateId, ManifestSequenceTemplateId, Frequency, AccountId , COUNT(*) as [SplitCount]
		from (
			--|  prelim
			select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, mst.Frequency, ap.AccountId, msi.Sequence  
			from scManifestTemplates mt
			join scManifestSequenceTemplates mst
				on mt.ManifestTemplateId = mst.ManifestTemplateId
			join scManifestSequenceItems msi
				on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
			join scAccountsPubs ap
				on msi.AccountPubId = ap.AccountPubId
			group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, mst.Frequency, ap.AccountId, msi.Sequence
		 ) as [prelim]  
		group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId, Frequency 
		having count(*) > 1 
		) as [splits]
	join scAccountsPubs ap
		on splits.AccountId = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
		and splits.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId

	order by 1, 2, 3

	/*
	select *
	from #splitDetails
	*/

	--|Preview
	select 
		  mt.MTCode
		, mst.Code
		, mst.Frequency
		, a.AcctCode
		, p.PubShortName
		, splitDetails.Sequence as [Sequence (current)]
		, coalesce( v.Sequence,  MinMax.MaxSequence ) as [NewSequence]
		, v.Sequence as [Sequence (scManifestLoad_View)] 
		, MinMax.MaxSequence as [Sequence (Min/Max)]
		, splitDetails.SplitCount
		, splitDetails.ManifestTemplateId, splitDetails.ManifestSequenceTemplateId, splitDetails.ManifestSequenceItemId
		, splitDetails.AccountId, splitDetails.PublicationId, splitDetails.AccountPubID
	into #preview
	from #splitDetails splitDetails
	join scAccounts a
		on splitDetails.AccountId = a.AccountId
	join nsPublications p
		on splitDetails.PublicationId = p.PublicationId
	join scManifestTemplates mt
		on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on splitDetails.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	join (
			--| Get the Min/Max sequences from #splitDetails to be used in case scManifestLoad does not have a Sequence of record
			select ManifestTemplateId, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
			from #splitDetails
			group by ManifestTemplateId, AccountId
		) as MinMax
		on splitDetails.ManifestTemplateId = MinMax.ManifestTemplateId
		and splitDetails.AccountId = MinMax.AccountId
	left join (
		select a.AccountID, p.PublicationID, ld.dropsequence as [Sequence], dbo.scGetDayFrequency(ld.drawdate) as [Frequency]
		from scManifestLoad_View ld
		join scAccounts a
			on ld.AcctCode = a.acctcode
		join nsPublications p
			on ld.publication = p.PubShortName
		) as v
		on 	splitDetails.AccountId = v.AccountID
		--and splitDetails.PublicationId = v.PublicationID
		and splitDetails.Frequency & v.Frequency > 0
		

	--/*
	declare @bkp_name nvarchar(50)
	declare @sql nvarchar(4000)

	set @bkp_name = 'support_DropSequences_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
	+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
	+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)

	set @sql = 'select *
				into ' + @bkp_name + '
				from #preview'
	exec(@sql)			
	--print @sql
	
	--select *
	--into support_DropSequences_Backup_12202011
	--from #preview
	--order by accountid
	--*/

	--/*
	insert into syncSystemLog ( 
		  LogMessage
		, SLTimeStamp
		, ModuleId
		, SeverityId
		, CompanyId
		, [Source]
		--, GroupId 
		)
	select 
		 'Account ''' + AcctCode + ''' on Manifest/Sequence ''' + MTCode + '/' + Code
		  + ''' was split between drop sequences.  Publication '''
		  + PubShortName + ''' was moved to drop sequence ' + cast(NewSequence as varchar)
		  + '.  Old sequence ' + cast([Sequence (current)] as varchar) + '.'
		  + '.  (ManifestTemplates).'
			as [LogMessage]
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 1 as [SeverityId] --|1=Warning
		, 1 as [CompanyId]
		, N'' as [Source]   --|nvarchar(100)
	from #preview	
	where [NewSequence] <> [Sequence (current)]
	
	/*select 
		 'Account ''' + a.AcctCode + ''' on Manifest/Sequence ''' + mt.MTCode + '/' + mst.Code
		  + ''' was split between drop sequences.  Publication '''
		  + p.PubShortName + ''' was moved to drop sequence ' + cast(MaxSequence as varchar)
		  + '.  Old sequence ' + cast(splitDetails.Sequence as varchar) + '.'
		  + '.  (ManifestTemplates).'
			as [LogMessage]
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 1 as [SeverityId] --|1=Warning
		, 1 as [CompanyId]
		, N'' as [Source]   --|nvarchar(100)
		--, newid() as [GroupId]
	from #splitDetails splitDetails
	join scAccounts a
		on splitDetails.AccountId = a.AccountId
	join nsPublications p
		on splitDetails.PublicationId = p.PublicationId
	join (
			--| Get the Min/Max sequences from #splitDetails to be used in case scManifestLoad does not have a Sequence of record
			select ManifestTemplateId, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
			from #splitDetails
			group by ManifestTemplateId, AccountId
		) as MinMax
		on splitDetails.ManifestTemplateId = MinMax.ManifestTemplateId
		and splitDetails.AccountId = MinMax.AccountId
	join scManifestTemplates mt
		on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on splitDetails.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	where splitDetails.Sequence <> MaxSequence	
	order by MTCode--a.AcctCode, p.PubShortName
	*/
	
	update scManifestSequenceItems
	set Sequence = new.NewSequence
	from scManifestSequenceItems msi
	join #preview new
		on msi.ManifestSequenceItemId = new.ManifestSequenceItemId
	where Sequence <> new.NewSequence
	print cast(@@rowcount as varchar) + ' sequence item records updated'
	--*/
		
	--| Cleanup
	drop table #splitDetails
	drop table #preview

	select @msg = 'splitAcctPubs_Cleanup:  Procedure completed.'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg

end
