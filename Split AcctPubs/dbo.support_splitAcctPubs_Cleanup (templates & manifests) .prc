IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_splitAcctPubs_Cleanup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_splitAcctPubs_Cleanup]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create  procedure [dbo].[support_splitAcctPubs_Cleanup]
	@minmax nvarchar(3) = 'max'  --[min|max]
as
/*=========================================================
    dbo.support_splitAcctPubs_Cleanup.PRC
    
	Note:  If this is run just prior to running the Manifest Sequence Finalizer it should 
			not be necessary to clean up splits in the Manifest tables

	$History:  $

==========================================================*/
begin
	set nocount on

	declare @msg nvarchar(1024)
	declare @rowcount int

	set @msg = 'support_splitAcctPubs_Cleanup:  Procedure started...'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
	
	select splits.ManifestTemplateId, splits.ManifestSequenceTemplateId, splits.AccountId
		, msi.ManifestSequenceItemId 
		, ap.AccountPubId
		, ap.PublicationId
		, Sequence
	into #splitDetails_Templates
	from (  
		--|  splits
		select ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
		from (
			--|  prelim
			select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence  
			from scManifestTemplates mt
			join scManifestSequenceTemplates mst
				on mt.ManifestTemplateId = mst.ManifestTemplateId
			join scManifestSequenceItems msi
				on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
			join scAccountsPubs ap
				on msi.AccountPubId = ap.AccountPubId
			group by mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, ap.AccountId, msi.Sequence
		 ) as [prelim]  
		group by ManifestTemplateId, ManifestSequenceTemplateId, AccountId 
		having count(*) > 1 
		) as [splits]
	join scAccountsPubs ap
		on splits.AccountId = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubId = msi.AccountPubId
		and splits.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	order by 1, 2, 3


	select splitDetails.ManifestTemplateId, splitDetails.ManifestSequenceTemplateId, splitDetails.AccountId, splitDetails.PublicationId
		, splitDetails.ManifestSequenceItemId
		, splitDetails.Sequence
		, case @minmax	
			when 'min' then MinMax.MinSequence
			when 'max' then MinMax.MaxSequence
			else MinMax.MinSequence 
			end as [NewSequence]
	into #preview_Templates
	from #splitDetails_Templates splitDetails
	join scAccounts a
		on splitDetails.AccountId = a.AccountId
	join nsPublications p
		on splitDetails.PublicationId = p.PublicationId
	join scManifestTemplates mt
		on splitDetails.ManifestTemplateId = mt.ManifestTemplateId
	join (
			--| Get the Min/Max sequences from #splitDetails to be used in case scManifestLoad does not have a Sequence of record
			select ManifestTemplateId, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
			from #splitDetails_Templates
			group by ManifestTemplateId, AccountId
		) as MinMax
		on splitDetails.ManifestTemplateId = MinMax.ManifestTemplateId
		and splitDetails.AccountId = MinMax.AccountId
	select @rowcount = @@ROWCOUNT
		
	set @msg = 'Found ' + CAST(@rowcount as varchar) + ' accounts with publications with different sequences (Manifest Templates)'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
		
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
		 'Account ''' + a.AcctCode + ''' on Manifest/Sequence ''' + mt.MTCode + '/' + mst.Code
		 	  + ''' was split between drop sequences.  Publication ''' + p.PubShortName + ''' was moved to drop sequence ' 
			 + cast(prv.NewSequence as varchar)
			+ ' (' + @minmax + ')'
			+ '.  Old sequence ' + cast(prv.Sequence as varchar) + '.'
			+ '.  (ManifestTemplates).'
			as [LogMessage]
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 1 as [SeverityId] --|1=Warning
		, 1 as [CompanyId]
		, N'' as [Source]   --|nvarchar(100)
		--, newid() as [GroupId]
	from #preview_Templates prv
	join scAccounts a
		on prv.AccountId = a.AccountId
	join nsPublications p
		on prv.PublicationId = p.PublicationId
	join scManifestTemplates mt
		on prv.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
	where prv.Sequence <> prv.NewSequence
	order by MTCode, a.AcctCode, p.PubShortName

	update scManifestSequenceItems
	set Sequence = new.NewSequence
	from scManifestSequenceItems msi
	join #preview_Templates new
		on msi.ManifestSequenceItemId = new.ManifestSequenceItemId
	where msi.Sequence <> new.NewSequence

	set @msg = cast(@@rowcount as varchar) + ' sequence item records updated'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg
		
	--| Cleanup
	drop table #splitDetails_Templates
	drop table #preview_Templates

	
	--|  Get the minimum date that contains splits to limit scope
	declare @mfstdate datetime
	select @mfstdate = MIN(manifestdate)
	from (
		select ManifestId, ManifestSequenceTemplateId, AccountId
		from (
			--|  prelim
			select  m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
			from scManifests m
			join scManifestSequences ms
				on m.ManifestId = ms.ManifestId
			join scAccountsPubs ap
				on ms.AccountPubId = ap.AccountPubId
			group by m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
		 ) as [prelim]  
		group by ManifestId, ManifestSequenceTemplateId, AccountId 
		having count(*) > 1 
	) splits
	join scmanifests m
		 on splits.ManifestID = m.ManifestID


	if (@mfstdate is not null)
	begin
		select splits.ManifestId, splits.ManifestSequenceTemplateId, splits.AccountId
			, ap.AccountPubId
			, ap.PublicationId
			, Sequence
		into #splitDetails_Manifests
		from (  
			--|  splits
			select ManifestId, ManifestSequenceTemplateId, AccountId
			from (
				--|  prelim
				select  m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
				from scManifests m
				join scManifestSequences ms
					on m.ManifestId = ms.ManifestId
				join scAccountsPubs ap
					on ms.AccountPubId = ap.AccountPubId
				where m.ManifestDate >= @mfstdate
				group by m.ManifestId, ManifestSequenceTemplateId, ap.AccountId, ms.Sequence  
			 ) as [prelim]  
			group by ManifestId, ManifestSequenceTemplateId, AccountId 
			having count(*) > 1 
			) as [splits]
		join scAccountsPubs ap
			on splits.AccountId = ap.AccountId
		join scManifestSequences ms
			on ap.AccountPubId = ms.AccountPubId
			and splits.ManifestSequenceTemplateId = ms.ManifestSequenceTemplateId
			and splits.ManifestId = ms.ManifestId
		order by 1, 2, 3

		--|  Assume splits in manifest templates have been fixed
		;with cteTemplates
		as (
			select mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, Frequency, ap.AccountPubId, msi.Sequence  
			from scManifestTemplates mt
			join scManifestSequenceTemplates mst
				on mt.ManifestTemplateId = mst.ManifestTemplateId
			join scManifestSequenceItems msi
				on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
			join scAccountsPubs ap
				on msi.AccountPubId = ap.AccountPubId
			join #splitDetails_Manifests splits
				on splits.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		)
		--| Preview
		select tmp.*
			, msi.Sequence as [TemplateSequence]
			--, MinMax.MinSequence, MinMax.MaxSequence
			, case @minmax	
					when 'min' then MinMax.MinSequence
					when 'max' then MinMax.MaxSequence
					else MinMax.MinSequence 
					end as [MinMaxSequence]
		into #preview_Manifests
		from #splitDetails_Manifests tmp
		left join scManifestSequenceItems msi
			on tmp.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
			and tmp.AccountPubId = msi.AccountPubId
		join (
			select ManifestID, AccountId, min(Sequence) as [MinSequence], max(Sequence) as [MaxSequence]
			from #splitDetails_Manifests
			group by ManifestID, AccountId
			) as MinMax
			on tmp.ManifestID = MinMax.ManifestID
			and tmp.AccountId = MinMax.AccountId
	
		select @rowcount = @@ROWCOUNT

		set @msg = 'Found ' + cast(@rowcount as varchar) + ' accounts with publications with different sequences (Historical Manifests)'
		print @msg
		exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg

		--
		--select *
		--from #preview

		--|Friendly Preview
		/*
		select prv.ManifestId, m.ManifestDate, m.MfstCode, prv.AccountId, a.AcctCode, prv.PublicationId, p.PubShortName, prv.Sequence, prv.[TemplateSequence]
			, prv.MinMaxSequence
		from #preview prv
		join scManifests m
			on prv.ManifestId = m.ManifestId
		join scManifestSequenceTemplates mst
			on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		join scAccounts a
			on prv.AccountId = a.AccountId
		join nsPublications p
			on prv.PublicationId = p.PublicationId
		where prv.Sequence <> coalesce(prv.TemplateSequence, prv.MinMaxSequence)
		order by a.AcctCode, m.MfstCode, m.ManifestDate, p.PubShortName
		*/

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
			 'Account ''' + a.AcctCode + ''' on Manifest ''' + m.MfstCode + ' for ''' + CONVERT(varchar, m.ManifestDate, 1)
			  + ''' was split between drop sequences.  Publication ''' + p.PubShortName + ''' was moved to drop sequence ' + cast( coalesce(prv.TemplateSequence, prv.MinMaxSequence) as varchar)
			  + case when prv.TemplateSequence is null then ' (' + @minmax + ')' else ' (template)' end 
			  + '.  Old sequence ' + cast(prv.Sequence as varchar) + '.'
				as [LogMessage]
			, getdate() as [SLTimeStamp]
			, 2 as [ModuleId]	--|2=SingleCopy
			, 1 as [SeverityId] --|1=Warning
			, 1 as [CompanyId]
			, N'' as [Source]   --|nvarchar(100)
			--, newid() as [GroupId]
		from #preview_Manifests prv
		join scManifests m
			on prv.ManifestId = m.ManifestId
		join scManifestSequenceTemplates mst
			on prv.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		join scAccounts a
			on prv.AccountId = a.AccountId
		join nsPublications p
			on prv.PublicationId = p.PublicationId
		where prv.Sequence <> coalesce(prv.TemplateSequence, prv.MinMaxSequence)
		order by m.ManifestDate, m.MfstCode, a.AcctCode, p.PubShortName

		update scManifestSequences
		set Sequence = coalesce(new.[TemplateSequence], new.MinMaxSequence)
		from scManifests m
		join scManifestSequences ms
			on m.ManifestId = ms.ManifestId
		join #preview_Manifests new
			on m.ManifestId = new.ManifestId
			and ms.ManifestSequenceTemplateId = new.ManifestSequenceTemplateId
			and ms.AccountPubId = new.AccountPubId
		where new.Sequence <> coalesce(new.TemplateSequence, new.MinMaxSequence)	
		print cast(@@rowcount as varchar) + ' sequence records updated'

		drop table #preview_Manifests
		drop table #splitDetails_Manifests
	end


	select @msg = 'support_splitAcctPubs_Cleanup:  Procedure completed.'
	print @msg
	exec syncSystemLog_Insert @moduleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg

end

GO


